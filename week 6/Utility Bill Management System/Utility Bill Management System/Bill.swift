//
//  Bill.swift
//  Utility Bill Management System
//
//  Created by Nguyễn Hoàng Bảo Hân on 26/10/26.
//
import Foundation

class UtilityBill: Identifiable {
    public private(set) var id: String
    public private(set) var customerName: String
    public private(set) var customerAddress: String
    public private(set) var billingMonth: Int
    public private(set) var billingYear: Int
    public var isPaid: Bool
    
    init(id: String, customerName: String, customerAddress: String, billingMonth: Int, billingYear: Int, isPaid: Bool = false) {
        self.id = id
        self.customerName = customerName
        self.customerAddress = customerAddress
        self.billingMonth = billingMonth
        self.billingYear = billingYear
        self.isPaid = isPaid
    }
    
    func calculateTotal() -> Double { return 0.0 }
}

class ElectricityBill: UtilityBill {
    public private(set) var consumptionKWh: Double
    private let ratePerKWh: Double = 2500.0
    
    init(id: String, customerName: String, customerAddress: String, billingMonth: Int, billingYear: Int, consumptionKWh: Double, isPaid: Bool) {
        self.consumptionKWh = consumptionKWh
        super.init(id: id, customerName: customerName, customerAddress: customerAddress, billingMonth: billingMonth, billingYear: billingYear, isPaid: isPaid)
    }
    override func calculateTotal() -> Double { return consumptionKWh * ratePerKWh }
}

class WaterBill: UtilityBill {
    public private(set) var consumptionM3: Double
    private let ratePerM3: Double = 10000.0
    
    init(id: String, customerName: String, customerAddress: String, billingMonth: Int, billingYear: Int, consumptionM3: Double, isPaid: Bool) {
        self.consumptionM3 = consumptionM3
        super.init(id: id, customerName: customerName, customerAddress: customerAddress, billingMonth: billingMonth, billingYear: billingYear, isPaid: isPaid)
    }
    override func calculateTotal() -> Double { return consumptionM3 * ratePerM3 }
}

class InternetBill: UtilityBill {
    private let fixedMonthlyFee: Double = 200000.0
    
    override init(id: String, customerName: String, customerAddress: String, billingMonth: Int, billingYear: Int, isPaid: Bool) {
        super.init(id: id, customerName: customerName, customerAddress: customerAddress, billingMonth: billingMonth, billingYear: billingYear, isPaid: isPaid)
    }
    override func calculateTotal() -> Double { return fixedMonthlyFee }
}
