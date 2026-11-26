import Foundation
import Combine

final class RentalManager: ObservableObject {
    @Published private(set) var vehicles: [Vehicle] = []
    @Published private(set) var customers: [Customer] = []
    @Published private(set) var rentals: [RentalRecord] = []
    private var rentalCounter: Int = 1

    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        objectWillChange.send()
    }

    func updateVehicle(
        id: String,
        brand: String? = nil,
        model: String? = nil,
        dailyRate: Double? = nil,
        seatingCapacity: Int? = nil,
        serviceFee: Double? = nil,
        engineCC: Int? = nil,
        batteryRangeKm: Int? = nil,
        batteryServiceFee: Double? = nil
    ) throws {
        guard let vehicle = vehicles.first(where: { $0.id == id }) else {
            throw RentalError.vehicleNotFound(id)
        }

        if let car = vehicle as? Car {
            car.updateCarDetails(brand: brand, model: model, dailyRate: dailyRate, seatingCapacity: seatingCapacity, serviceFee: serviceFee)
        } else if let moto = vehicle as? Motorcycle {
            moto.updateMotorcycleDetails(brand: brand, model: model, dailyRate: dailyRate, engineCC: engineCC)
        } else if let ebike = vehicle as? ElectricBicycle {
            ebike.updateEBikeDetails(brand: brand, model: model, dailyRate: dailyRate, batteryRangeKm: batteryRangeKm, batteryServiceFee: batteryServiceFee)
        } else {
            vehicle.updateInfo(brand: brand, model: model, dailyRate: dailyRate)
        }

        objectWillChange.send()
    }

    func registerCustomer(_ customer: Customer) {
        customers.append(customer)
        objectWillChange.send()
    }

    func updateCustomerContact(id: String, phone: String? = nil, email: String? = nil) throws {
        guard let customer = customers.first(where: { $0.id == id }) else {
            throw RentalError.customerNotFound(id)
        }
        customer.updateContact(phone: phone, email: email)
        objectWillChange.send()
    }

    @discardableResult
    func rentVehicle(vehicleId: String, customerId: String, days: Int) throws -> RentalRecord {
        guard let vehicle = vehicles.first(where: { $0.id == vehicleId }) else {
            throw RentalError.vehicleNotFound(vehicleId)
        }
        guard let customer = customers.first(where: { $0.id == customerId }) else {
            throw RentalError.customerNotFound(customerId)
        }
        guard days > 0 else {
            throw RentalError.invalidRentalDays(days)
        }

        try vehicle.markAsRented()
        let totalCost = vehicle.calculateRentalCost(days: days)
        let rentalId = String(format: "RNT%03d", rentalCounter)
        rentalCounter += 1

        let record = RentalRecord(
            id: rentalId,
            vehicle: vehicle,
            customer: customer,
            rentalDays: days,
            totalCost: totalCost,
            status: .active
        )

        rentals.append(record)
        customer.recordRental(record)
        objectWillChange.send()
        return record
    }

    func returnVehicle(rentalId: String) throws {
        guard let record = rentals.first(where: { $0.id == rentalId }) else {
            throw RentalError.rentalNotFound(rentalId)
        }
        guard record.status == .active else {
            throw RentalError.rentalAlreadyReturned(rentalId)
        }

        record.markReturned()
        record.vehicle.markAsReturned()
        objectWillChange.send()
    }

    func seedSampleData() {
        vehicles.removeAll()
        customers.removeAll()
        rentals.removeAll()
        rentalCounter = 1

        let sampleVehicles: [Vehicle] = [
            Car(id: "C01", brand: "Toyota", model: "Camry", dailyRate: 60.0, seatingCapacity: 5, serviceFee: 20.0),
            Car(id: "C02", brand: "Kia", model: "Carnival", dailyRate: 85.0, seatingCapacity: 7, serviceFee: 30.0),
            Motorcycle(id: "M01", brand: "Honda", model: "PCX 160", dailyRate: 20.0, engineCC: 160),
            Motorcycle(id: "M02", brand: "Yamaha", model: "MT-07", dailyRate: 45.0, engineCC: 689),
            ElectricBicycle(id: "EB01", brand: "VinFast", model: "EvoLite", dailyRate: 10.0, batteryRangeKm: 70, batteryServiceFee: 2.0),
            ElectricBicycle(id: "EB02", brand: "Specialized", model: "Turbo Vado", dailyRate: 15.0, batteryRangeKm: 95, batteryServiceFee: 3.0)
        ]
        sampleVehicles.forEach { addVehicle($0) }

        registerCustomer(Customer(id: "C001", name: "Huy Tran", phone: "0901234567", email: "huy.tran@gmail.com"))
        registerCustomer(Customer(id: "C002", name: "Dat Phan", phone: "0912345678", email: "dat.phan@gmail.com"))
        registerCustomer(Customer(id: "C003", name: "Khoa Le", phone: "0923456789", email: "khoa.le@gmail.com"))
        registerCustomer(Customer(id: "C004", name: "Quoc Anh", phone: "0934567890", email: "quoc.anh@gmail.com"))

        do {
            try rentVehicle(vehicleId: "C02", customerId: "C001", days: 3)
            try rentVehicle(vehicleId: "M01", customerId: "C002", days: 2)
        } catch {
            print(error.localizedDescription)
        }
    }
}
