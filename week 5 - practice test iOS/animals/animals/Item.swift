//
//  Item.swift
//  animals
//
//  Created by Nguyễn Hoàng Bảo Hân on 19/10/26.
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
