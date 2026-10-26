//
//  DeliveryDataService.swift
//  Delivery Service Management System
//
//  Created by Nguyễn Hoàng Bảo Hân on 26/10/26.
//

import Foundation

class DeliveryDataService {
    private var orders: [DeliveryOrder] = []
    
    func addOrder(_ order: DeliveryOrder) {
        orders.append(order)
    }
    
    func getAllOrders() -> [DeliveryOrder] {
        return orders
    }
    
    func getOrders(forMonth month: Int, year: Int) -> [DeliveryOrder] {
        return orders.filter { $0.orderMonth == month && $0.orderYear == year }
    }
    
    func calculateTotalDeliveryRevenue() -> Double {
        return orders.reduce(0) { $0 + $1.calculateDeliveryFee() }
    }
}
