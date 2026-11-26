//
//  Models.swift
//  task 5 - assignment 2 - week 7
//
//  Created by Nguyễn Hoàng Bảo Hân on 2/11/26.
//

import SwiftUI
import Combine
import Foundation

// MARK: - Core Architecture
class Employee: Identifiable, ObservableObject {
    let id = UUID()
    let employeeID: String
    let name: String
    
    init(employeeID: String, name: String) {
        self.employeeID = employeeID
        self.name = name
    }
    
    func calculateMonthlyPay() -> Double {
        return 0.0
    }
}

// MARK: - Subclasses
class FullTimeEmployee: Employee {
    let monthlySalary: Double
    @Published private(set) var bonus: Double = 0.0
    
    init(employeeID: String, name: String, monthlySalary: Double) {
        self.monthlySalary = monthlySalary
        super.init(employeeID: employeeID, name: name)
    }
    
    func addBonus(amount: Double) {
        bonus += amount
    }
    
    override func calculateMonthlyPay() -> Double {
        return monthlySalary + bonus
    }
}

class PartTimeEmployee: Employee {
    let hourlyRate: Double
    @Published private(set) var hoursWorked: Double = 0.0
    
    init(employeeID: String, name: String, hourlyRate: Double) {
        self.hourlyRate = hourlyRate
        super.init(employeeID: employeeID, name: name)
    }
    
    func logHours(_ hours: Double) throws {
        guard hours >= 0 else {
            throw PayrollError.negativeWorkingHours
        }
        hoursWorked += hours
    }
    
    override func calculateMonthlyPay() -> Double {
        return hourlyRate * hoursWorked
    }
}

class ContractEmployee: Employee {
    let contractAmount: Double
    @Published private(set) var isCompleted: Bool = false
    
    init(employeeID: String, name: String, contractAmount: Double) {
        self.contractAmount = contractAmount
        super.init(employeeID: employeeID, name: name)
    }
    
    func markAsCompleted() {
        isCompleted = true
    }
    
    override func calculateMonthlyPay() -> Double {
        return isCompleted ? contractAmount : 0.0
    }
}

// MARK: - Error Handling
enum PayrollError: Error, LocalizedError {
    case negativeWorkingHours
    
    var errorDescription: String? {
        switch self {
        case .negativeWorkingHours:
            return "Operation Rejected: Recorded working hours cannot be negative."
        }
    }
}

// MARK: - ViewModel (Local Sample Data)
class PayrollViewModel: ObservableObject {
    @Published var employees: [Employee] = [
        FullTimeEmployee(employeeID: "FT-101", name: "Bamboo Nguyen", monthlySalary: 30000.0),
        PartTimeEmployee(employeeID: "PT-201", name: "Christian Nguyen", hourlyRate: 70000.0),
        ContractEmployee(employeeID: "CT-301", name: "Hector Nguyen", contractAmount: 1500.0)
    ]
}
