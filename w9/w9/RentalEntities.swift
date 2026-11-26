import Foundation
import Combine

final class Customer: Identifiable {
    let id: String
    var name: String
    var phone: String
    var email: String
    private var internalHistory: [RentalRecord] = []

    var rentalHistory: [RentalRecord] {
        return internalHistory
    }

    init(id: String, name: String, phone: String, email: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
    }

    func updateContact(phone: String? = nil, email: String? = nil) {
        if let phone = phone, !phone.isEmpty { self.phone = phone }
        if let email = email, !email.isEmpty { self.email = email }
    }

    func recordRental(_ record: RentalRecord) {
        internalHistory.append(record)
    }
}

final class RentalRecord: Identifiable {
    let id: String
    let vehicle: Vehicle
    let customer: Customer
    let rentalDays: Int
    let totalCost: Double
    private(set) var status: RentalStatus

    init(id: String, vehicle: Vehicle, customer: Customer, rentalDays: Int, totalCost: Double, status: RentalStatus = .active) {
        self.id = id
        self.vehicle = vehicle
        self.customer = customer
        self.rentalDays = rentalDays
        self.totalCost = totalCost
        self.status = status
    }

    func markReturned() {
        status = .returned
    }
}
