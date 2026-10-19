//
//  Models.swift
//  Fish Management App
//
//  Created by Nguyễn Hoàng Bảo Hân on 19/10/26.
//
import Foundation
import SwiftUI

class Fish: Identifiable {
    var id: Int
    private var name: String
    private var color: String
    private var price: Double
    
    
    init(id: Int, name: String, color: String, price: Double) {
        self.id = id
        self.name = name
        self.color = color
        self.price = price
    }
    
    func getInfo() -> String {
        return "\(id)-\(name)-\(color)-\(price)"
    }
    
    func setName(_ newName: String) {
        self.name = newName
    }
    
    func getColor() -> Color {
        switch color.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "orange": return .orange
        case "silver": return .gray
        default: return .black
        }
    }
}
