//
//  Item.swift
//  Class Management System)
//
//  Created by Nguyễn Hoàng Bảo Hân on 5/10/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
