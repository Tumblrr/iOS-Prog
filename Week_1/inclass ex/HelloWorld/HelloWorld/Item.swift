//
//  Item.swift
//  HelloWorld
//
//  Created by Nguyễn Hoàng Bảo Hân on 14/9/26.
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
