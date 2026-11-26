import SwiftUI
import Foundation
import Combine


struct ContentView: View {
    @StateObject private var manager = RentalManager()
    @State private var selectedVehicleId = "C01"
    @State private var selectedCustomerId = "C003"
    @State private var rentalDaysText = "2"
    @State private var statusMessage = "Ready."
    @State private var isErrorMessage = false

    // Sheets for FR1 & FR2
    @State private var showAddVehicleSheet = false
    @State private var vehicleToEdit: Vehicle?
    @State private var showAddCustomerSheet = false
    @State private var customerToEdit: Customer?
    @State private var customerForHistory: Customer?

    private var pickerRefreshKey: String {
        let rentalPart = manager.rentals.map { "\($0.id)-\($0.status.rawValue)" }.joined(separator: ",")
        let vehiclePart = manager.vehicles.map { "\($0.id)-\($0.brand)-\($0.model)-\($0.dailyRate)-\($0.isAvailable)" }.joined(separator: ",")
        let customerPart = manager.customers.map { "\($0.id)-\($0.name)" }.joined(separator: ",")
        return "\(rentalPart)|\(vehiclePart)|\(customerPart)"
    }

    var body: some View {
        NavigationView {
            List {
                // FR3 & FR4: New Rental
                Section("New Rental") {
                    Picker("Vehicle", selection: $selectedVehicleId) {
                        ForEach(manager.vehicles) { v in
                            Text("\(v.id) - \(v.brand) \(v.model) (\(v.isAvailable ? "Available" : "Rented"))")
                                .tag(v.id)
                        }
                    }
                    .id(pickerRefreshKey)

                    Picker("Customer", selection: $selectedCustomerId) {
                        ForEach(manager.customers) { c in
                            Text("\(c.id) - \(c.name)").tag(c.id)
                        }
                    }
                    .id(pickerRefreshKey)

                    HStack {
                        Text("Duration (days):")
                        TextField("Days", text: $rentalDaysText)
                            .keyboardType(.numberPad)
                    }

                    Button("Confirm Rental") {
                        let days = Int(rentalDaysText) ?? 0
                        do {
                            let rec = try manager.rentVehicle(vehicleId: selectedVehicleId, customerId: selectedCustomerId, days: days)
                            statusMessage = "Rental \(rec.id) confirmed | Total: $\(String(format: "%.2f", rec.totalCost))"
                            isErrorMessage = false
                        } catch {
                            statusMessage = error.localizedDescription
                            isErrorMessage = true
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundColor(isErrorMessage ? .red : .green)
                }

                // FR1: Vehicle Management
                Section {
                    ForEach(manager.vehicles) { v in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(v.detailedDescription())
                                .font(.subheadline)
                            HStack(spacing: 16) {
                                Button("Edit Info") {
                                    vehicleToEdit = v
                                }
                                .font(.caption)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Vehicles (\(manager.vehicles.count))")
                        Spacer()
                        Button("+ Add Vehicle") {
                            showAddVehicleSheet = true
                        }
                        .font(.caption)
                    }
                }

                // FR2: Customer Management
                Section {
                    ForEach(manager.customers) { c in
                        let activeCount = c.rentalHistory.filter { $0.status == .active }.count
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(c.id) - \(c.name)")
                                .bold()
                            Text("Phone: \(c.phone) | Email: \(c.email)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Active Rentals: \(activeCount) | Total History: \(c.rentalHistory.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack(spacing: 16) {
                                Button("Edit Contact") {
                                    customerToEdit = c
                                }
                                .font(.caption)

                                Button("Rental History") {
                                    customerForHistory = c
                                }
                                .font(.caption)
                            }
                            .padding(.top, 2)
                        }
                    }
                } header: {
                    HStack {
                        Text("Customers (\(manager.customers.count))")
                        Spacer()
                        Button("+ Register") {
                            showAddCustomerSheet = true
                        }
                        .font(.caption)
                    }
                }

                // FR5: Rental Information Display & Return
                Section("Rental Records (\(manager.rentals.count))") {
                    ForEach(manager.rentals) { r in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(r.id) - \(r.vehicle.brand) \(r.vehicle.model) | \(r.status.rawValue)")
                                .bold()
                            Text("Customer: \(r.customer.name) | \(r.rentalDays) days | Total: $\(String(format: "%.2f", r.totalCost))")
                                .font(.caption)
                        }
                        if r.status == .active {
                            Button("Return Vehicle") {
                                do {
                                    try manager.returnVehicle(rentalId: r.id)
                                    statusMessage = "Vehicle returned for rental \(r.id)."
                                    isErrorMessage = false
                                } catch {
                                    statusMessage = error.localizedDescription
                                    isErrorMessage = true
                                }
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Vehicle Rental System")
            .onAppear {
                if manager.vehicles.isEmpty {
                    manager.seedSampleData()
                }
            }
            .sheet(isPresented: $showAddVehicleSheet) {
                AddVehicleView { newVehicle in
                    manager.addVehicle(newVehicle)
                    statusMessage = "Added vehicle '\(newVehicle.id)'."
                    isErrorMessage = false
                }
            }
            .sheet(item: $vehicleToEdit) { vehicle in
                EditVehicleView(vehicle: vehicle) { brand, model, rate, seats, carFee, cc, range, bikeFee in
                    do {
                        try manager.updateVehicle(
                            id: vehicle.id,
                            brand: brand,
                            model: model,
                            dailyRate: rate,
                            seatingCapacity: seats,
                            serviceFee: carFee,
                            engineCC: cc,
                            batteryRangeKm: range,
                            batteryServiceFee: bikeFee
                        )
                        statusMessage = "Updated vehicle '\(vehicle.id)'."
                        isErrorMessage = false
                    } catch {
                        statusMessage = error.localizedDescription
                        isErrorMessage = true
                    }
                }
            }
            .sheet(isPresented: $showAddCustomerSheet) {
                AddCustomerView { newCustomer in
                    manager.registerCustomer(newCustomer)
                    statusMessage = "Registered customer '\(newCustomer.name)'."
                    isErrorMessage = false
                }
            }
            .sheet(item: $customerToEdit) { customer in
                EditCustomerContactView(customer: customer) { phone, email in
                    do {
                        try manager.updateCustomerContact(id: customer.id, phone: phone, email: email)
                        statusMessage = "Updated contact for '\(customer.name)'."
                        isErrorMessage = false
                    } catch {
                        statusMessage = error.localizedDescription
                        isErrorMessage = true
                    }
                }
            }
            .sheet(item: $customerForHistory) { customer in
                CustomerHistoryView(customer: customer)
            }
        }
    }
}

// MARK: - FR1 Sheets

private struct AddVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var typeIndex = 0 // 0: Car, 1: Motorcycle, 2: E-Bike
    @State private var id = ""
    @State private var brand = ""
    @State private var model = ""
    @State private var dailyRateText = "50"
    @State private var seatingText = "5"
    @State private var serviceFeeText = "20"
    @State private var engineCCText = "150"
    @State private var batteryRangeText = "75"
    @State private var batteryFeeText = "3"

    let onSave: (Vehicle) -> Void

    var body: some View {
        NavigationView {
            Form {
                Picker("Vehicle Type", selection: $typeIndex) {
                    Text("Car").tag(0)
                    Text("Motorcycle").tag(1)
                    Text("Electric Bicycle").tag(2)
                }

                TextField("Vehicle ID (e.g. C03)", text: $id)
                TextField("Brand", text: $brand)
                TextField("Model", text: $model)
                TextField("Daily Rate ($)", text: $dailyRateText)
                    .keyboardType(.decimalPad)

                if typeIndex == 0 {
                    TextField("Seating Capacity", text: $seatingText)
                        .keyboardType(.numberPad)
                    TextField("Service Fee ($)", text: $serviceFeeText)
                        .keyboardType(.decimalPad)
                } else if typeIndex == 1 {
                    TextField("Engine Capacity (cc)", text: $engineCCText)
                        .keyboardType(.numberPad)
                } else {
                    TextField("Battery Range (km)", text: $batteryRangeText)
                        .keyboardType(.numberPad)
                    TextField("Battery Service Fee ($/day)", text: $batteryFeeText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let cleanId = id.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
                        let rate = Double(dailyRateText) ?? 20.0
                        guard !cleanId.isEmpty, !cleanBrand.isEmpty, !cleanModel.isEmpty else { return }

                        let vehicle: Vehicle
                        if typeIndex == 0 {
                            vehicle = Car(
                                id: cleanId,
                                brand: cleanBrand,
                                model: cleanModel,
                                dailyRate: rate,
                                seatingCapacity: Int(seatingText) ?? 5,
                                serviceFee: Double(serviceFeeText) ?? 20.0
                            )
                        } else if typeIndex == 1 {
                            vehicle = Motorcycle(
                                id: cleanId,
                                brand: cleanBrand,
                                model: cleanModel,
                                dailyRate: rate,
                                engineCC: Int(engineCCText) ?? 150
                            )
                        } else {
                            vehicle = ElectricBicycle(
                                id: cleanId,
                                brand: cleanBrand,
                                model: cleanModel,
                                dailyRate: rate,
                                batteryRangeKm: Int(batteryRangeText) ?? 75,
                                batteryServiceFee: Double(batteryFeeText) ?? 3.0
                            )
                        }
                        onSave(vehicle)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct EditVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    let vehicle: Vehicle
    @State private var brand: String
    @State private var model: String
    @State private var dailyRateText: String
    @State private var seatingText: String
    @State private var serviceFeeText: String
    @State private var engineCCText: String
    @State private var batteryRangeText: String
    @State private var batteryFeeText: String

    let onSave: (String?, String?, Double?, Int?, Double?, Int?, Int?, Double?) -> Void

    init(vehicle: Vehicle, onSave: @escaping (String?, String?, Double?, Int?, Double?, Int?, Int?, Double?) -> Void) {
        self.vehicle = vehicle
        self.onSave = onSave
        _brand = State(initialValue: vehicle.brand)
        _model = State(initialValue: vehicle.model)
        _dailyRateText = State(initialValue: String(format: "%.2f", vehicle.dailyRate))
        _seatingText = State(initialValue: (vehicle as? Car).map { "\($0.seatingCapacity)" } ?? "5")
        _serviceFeeText = State(initialValue: (vehicle as? Car).map { String(format: "%.2f", $0.serviceFee) } ?? "20.0")
        _engineCCText = State(initialValue: (vehicle as? Motorcycle).map { "\($0.engineCC)" } ?? "150")
        _batteryRangeText = State(initialValue: (vehicle as? ElectricBicycle).map { "\($0.batteryRangeKm)" } ?? "75")
        _batteryFeeText = State(initialValue: (vehicle as? ElectricBicycle).map { String(format: "%.2f", $0.batteryServiceFee) } ?? "3.0")
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Brand", text: $brand)
                TextField("Model", text: $model)
                TextField("Daily Rate ($)", text: $dailyRateText)
                    .keyboardType(.decimalPad)

                if vehicle is Car {
                    TextField("Seating Capacity", text: $seatingText)
                        .keyboardType(.numberPad)
                    TextField("Service Fee ($)", text: $serviceFeeText)
                        .keyboardType(.decimalPad)
                } else if vehicle is Motorcycle {
                    TextField("Engine Capacity (cc)", text: $engineCCText)
                        .keyboardType(.numberPad)
                } else if vehicle is ElectricBicycle {
                    TextField("Battery Range (km)", text: $batteryRangeText)
                        .keyboardType(.numberPad)
                    TextField("Battery Service Fee ($/day)", text: $batteryFeeText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit \(vehicle.id)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            brand,
                            model,
                            Double(dailyRateText),
                            Int(seatingText),
                            Double(serviceFeeText),
                            Int(engineCCText),
                            Int(batteryRangeText),
                            Double(batteryFeeText)
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - FR2 Sheets

private struct AddCustomerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var id = ""
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""

    let onSave: (Customer) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Customer ID (e.g. C005)", text: $id)
                TextField("Full Name", text: $name)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }
            .navigationTitle("Register Customer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let cleanId = id.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !cleanId.isEmpty, !cleanName.isEmpty else { return }
                        onSave(Customer(id: cleanId, name: cleanName, phone: cleanPhone, email: cleanEmail))
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct EditCustomerContactView: View {
    @Environment(\.dismiss) private var dismiss
    let customer: Customer
    @State private var phone: String
    @State private var email: String

    let onSave: (String?, String?) -> Void

    init(customer: Customer, onSave: @escaping (String?, String?) -> Void) {
        self.customer = customer
        self.onSave = onSave
        _phone = State(initialValue: customer.phone)
        _email = State(initialValue: customer.email)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }
            .navigationTitle("Edit \(customer.name)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(phone, email)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct CustomerHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    let customer: Customer

    var body: some View {
        NavigationView {
            List {
                if customer.rentalHistory.isEmpty {
                    Text("No rental history for \(customer.name).")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(customer.rentalHistory) { rec in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(rec.id) - \(rec.vehicle.brand) \(rec.vehicle.model) | \(rec.status.rawValue)")
                                .bold()
                            Text("Duration: \(rec.rentalDays) days | Total: $\(String(format: "%.2f", rec.totalCost))")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("\(customer.name) History")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
