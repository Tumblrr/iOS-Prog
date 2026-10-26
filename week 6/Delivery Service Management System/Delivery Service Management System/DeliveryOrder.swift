//
//  DeliveryOrder.swift
//  Delivery Service Management System
//
//  Created by Nguyễn Hoàng Bảo Hân on 26/10/26.
//

import Foundation
class DeliveryOrder: Identifiable {
    public private(set) var id: String
    public private(set) var customerName: String
    public private(set) var deliveryAddress: String
    public private(set) var orderValue: Double
    public private(set) var orderMonth: Int
    public private(set) var orderYear: Int
    public var status: String
    
    init(id: String, customerName: String, deliveryAddress: String, orderValue: Double, orderMonth: Int, orderYear: Int, status: String = "Pending") {
        self.id = id
        self.customerName = customerName
        self.deliveryAddress = deliveryAddress
        self.orderValue = orderValue
        self.orderMonth = orderMonth
        self.orderYear = orderYear
        self.status = status
    }
    
    func calculateDeliveryFee() -> Double { return 0.0 }
    
    func getEstimatedTime() -> String { return "Unknown" }
}

class StandardDelivery: DeliveryOrder {
    private let fixedFee: Double = 20000.0
    
    override func calculateDeliveryFee() -> Double { return fixedFee }
    override func getEstimatedTime() -> String { return "3 - 5 Days" }
}

class ExpressDelivery: DeliveryOrder {
    private let fixedFee: Double = 40000.0
    
    override func calculateDeliveryFee() -> Double { return fixedFee }
    override func getEstimatedTime() -> String { return "1 - 2 Days" }
}

class SameDayDelivery: DeliveryOrder {
    private let fixedFee: Double = 60000.0
    
    override func calculateDeliveryFee() -> Double { return fixedFee }
    override func getEstimatedTime() -> String { return "Same Day" }
}
