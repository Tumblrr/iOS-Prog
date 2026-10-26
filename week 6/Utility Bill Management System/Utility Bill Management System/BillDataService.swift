//
//  BillDataService.swift
//  Utility Bill Management System
//
//  Created by Nguyễn Hoàng Bảo Hân on 26/10/26.
//
import Foundation

struct CustomerYearSummary: Identifiable {
    let id = UUID()
    let customerName: String
    let bills: [UtilityBill]
    var totalYearAmount: Double { bills.reduce(0) { $0 + $1.calculateTotal() } }
}

class BillDataService {
    private var bills: [UtilityBill] = []
    
    func addBill(_ bill: UtilityBill) { bills.append(bill) }
    func getAllBills() -> [UtilityBill] { return bills }
    
    func getBills(forMonth month: Int, year: Int) -> [UtilityBill] {
        return bills.filter { $0.billingMonth == month && $0.billingYear == year }
    }
    
    func getYearlySummary(forYear year: Int) -> [CustomerYearSummary] {
        let yearlyBills = bills.filter { $0.billingYear == year }
        let grouped = Dictionary(grouping: yearlyBills, by: { $0.customerName })
        return grouped.map { CustomerYearSummary(customerName: $0.key, bills: $0.value) }
            .sorted { $0.customerName < $1.customerName }
    }
}
