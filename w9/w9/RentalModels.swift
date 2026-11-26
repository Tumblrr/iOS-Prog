import Foundation
import Combine

enum RentalError: Error, LocalizedError {
    case vehicleNotFound(String)
    case customerNotFound(String)
    case vehicleUnavailable(String)
    case invalidRentalDays(Int)
    case rentalNotFound(String)
    case rentalAlreadyReturned(String)

    var errorDescription: String? {
        switch self {
        case .vehicleNotFound(let id):
            return "Vehicle with ID '\(id)' was not found."
        case .customerNotFound(let id):
            return "Customer with ID '\(id)' was not found."
        case .vehicleUnavailable(let id):
            return "Vehicle '\(id)' is currently rented and unavailable."
        case .invalidRentalDays(let days):
            return "Invalid rental duration (\(days) days). Must be greater than 0."
        case .rentalNotFound(let id):
            return "Rental record with ID '\(id)' was not found."
        case .rentalAlreadyReturned(let id):
            return "Rental record '\(id)' has already been returned."
        }
    }
}

enum RentalStatus: String {
    case active = "Active"
    case returned = "Returned"
}

class Vehicle: Identifiable {
    let id: String
    var brand: String
    var model: String
    var dailyRate: Double
    private(set) var isAvailable: Bool

    init(id: String, brand: String, model: String, dailyRate: Double, isAvailable: Bool = true) {
        self.id = id
        self.brand = brand
        self.model = model
        self.dailyRate = max(0, dailyRate)
        self.isAvailable = isAvailable
    }

    func markAsRented() throws {
        guard isAvailable else {
            throw RentalError.vehicleUnavailable(id)
        }
        isAvailable = false
    }

    func markAsReturned() {
        isAvailable = true
    }

    func updateInfo(brand: String? = nil, model: String? = nil, dailyRate: Double? = nil) {
        if let brand = brand, !brand.isEmpty { self.brand = brand }
        if let model = model, !model.isEmpty { self.model = model }
        if let dailyRate = dailyRate, dailyRate > 0 { self.dailyRate = dailyRate }
    }

    // Polymorphism: overridden by specialized vehicle subclasses
    func calculateRentalCost(days: Int) -> Double {
        return dailyRate * Double(days)
    }

    func detailedDescription() -> String {
        let statusText = isAvailable ? "Available" : "Rented"
        return "[\(id)] \(brand) \(model) - $\(String(format: "%.2f", dailyRate))/day (\(statusText))"
    }
}

final class Car: Vehicle {
    var seatingCapacity: Int
    var serviceFee: Double

    init(id: String, brand: String, model: String, dailyRate: Double, seatingCapacity: Int, serviceFee: Double = 25.0, isAvailable: Bool = true) {
        self.seatingCapacity = max(2, seatingCapacity)
        self.serviceFee = max(0, serviceFee)
        super.init(id: id, brand: brand, model: model, dailyRate: dailyRate, isAvailable: isAvailable)
    }

    func updateCarDetails(brand: String? = nil, model: String? = nil, dailyRate: Double? = nil, seatingCapacity: Int? = nil, serviceFee: Double? = nil) {
        super.updateInfo(brand: brand, model: model, dailyRate: dailyRate)
        if let seats = seatingCapacity, seats >= 2 { self.seatingCapacity = seats }
        if let fee = serviceFee, fee >= 0 { self.serviceFee = fee }
    }

    override func calculateRentalCost(days: Int) -> Double {
        let base = dailyRate * Double(days)
        let multiplier = seatingCapacity > 5 ? 1.15 : 1.0
        return (base * multiplier) + serviceFee
    }

    override func detailedDescription() -> String {
        return "Car \(super.detailedDescription()) | \(seatingCapacity) seats | Service Fee: $\(String(format: "%.2f", serviceFee))"
    }
}

final class Motorcycle: Vehicle {
    var engineCC: Int
    var engineDailySurcharge: Double

    init(id: String, brand: String, model: String, dailyRate: Double, engineCC: Int, isAvailable: Bool = true) {
        self.engineCC = max(50, engineCC)
        self.engineDailySurcharge = Self.surcharge(forCC: self.engineCC)
        super.init(id: id, brand: brand, model: model, dailyRate: dailyRate, isAvailable: isAvailable)
    }

    private static func surcharge(forCC cc: Int) -> Double {
        if cc >= 250 { return 12.0 }
        if cc >= 150 { return 5.0 }
        return 2.0
    }

    func updateMotorcycleDetails(brand: String? = nil, model: String? = nil, dailyRate: Double? = nil, engineCC: Int? = nil) {
        super.updateInfo(brand: brand, model: model, dailyRate: dailyRate)
        if let cc = engineCC, cc >= 50 {
            self.engineCC = cc
            self.engineDailySurcharge = Self.surcharge(forCC: cc)
        }
    }

    override func calculateRentalCost(days: Int) -> Double {
        return (dailyRate + engineDailySurcharge) * Double(days)
    }

    override func detailedDescription() -> String {
        return "Motorcycle \(super.detailedDescription()) | \(engineCC)cc | Engine Surcharge: $\(String(format: "%.2f", engineDailySurcharge))/day"
    }
}

final class ElectricBicycle: Vehicle {
    var batteryRangeKm: Int
    var batteryServiceFee: Double

    init(id: String, brand: String, model: String, dailyRate: Double, batteryRangeKm: Int, batteryServiceFee: Double = 3.0, isAvailable: Bool = true) {
        self.batteryRangeKm = max(10, batteryRangeKm)
        self.batteryServiceFee = max(0, batteryServiceFee)
        super.init(id: id, brand: brand, model: model, dailyRate: dailyRate, isAvailable: isAvailable)
    }

    func updateEBikeDetails(brand: String? = nil, model: String? = nil, dailyRate: Double? = nil, batteryRangeKm: Int? = nil, batteryServiceFee: Double? = nil) {
        super.updateInfo(brand: brand, model: model, dailyRate: dailyRate)
        if let range = batteryRangeKm, range >= 10 { self.batteryRangeKm = range }
        if let fee = batteryServiceFee, fee >= 0 { self.batteryServiceFee = fee }
    }

    override func calculateRentalCost(days: Int) -> Double {
        let longRangeFee = batteryRangeKm >= 80 ? 2.0 * Double(days) : 0.0
        return (dailyRate + batteryServiceFee) * Double(days) + longRangeFee
    }

    override func detailedDescription() -> String {
        return "E-Bike \(super.detailedDescription()) | Range: \(batteryRangeKm)km | Battery Fee: $\(String(format: "%.2f", batteryServiceFee))/day"
    }
}
