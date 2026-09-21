//
//  Computer.swift
//  ComputerLab
//
//  Created by Nguyễn Hoàng Bảo Hân on 21/9/26.
//
import Foundation

struct Computer: Identifiable {
    let id = UUID()
    var name: String
    var location: String
    var isAvailable: Bool
}
