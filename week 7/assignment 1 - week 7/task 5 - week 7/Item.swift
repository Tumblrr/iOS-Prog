//
//  Item.swift
//  task 5 - week 7
//
//  Created by Nguyễn Hoàng Bảo Hân on 2/11/26.
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
