//
//  Models.swift
//  Library System
//
//  Created by Nguyễn Hoàng Bảo Hân on 9/11/26.
//

import Foundation
import SwiftUI
import Combine

enum LibraryError: Error, LocalizedError {
    case alreadyBorrowed
    case notCurrentlyBorrowed
    case emptyField(String)
    case invalidNumber(String)
    case invalidYear
    case duplicateID
    case invalidDate

    var errorDescription: String? {
        switch self {
        case .alreadyBorrowed: return "This equipment is currently on loan."
        case .notCurrentlyBorrowed: return "This equipment is not currently on loan."
        case .emptyField(let field): return "The field '\(field)' cannot be empty."
        case .invalidNumber(let field): return "The field '\(field)' must be a valid positive number."
        case .invalidYear: return "Invalid purchase year. Must be a realistic past or current year."
        case .duplicateID: return "Equipment ID already exists in the system."
        case .invalidDate: return "Expected return date must be in the future."
        }
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

class Equipment: Identifiable, ObservableObject {
    let id: String
    let purchaseYear: Int

    @Published private(set) var name: String
    @Published private(set) var manufacturer: String

    @Published private(set) var isAvailable: Bool = true
    @Published private(set) var currentBorrower: String?
    @Published private(set) var borrowDate: Date?
    @Published private(set) var expectedReturnDate: Date?

    init(id: String, name: String, manufacturer: String, purchaseYear: Int) throws {
        let cleanID = id.trimmed.uppercased()
        guard !cleanID.isEmpty else { throw LibraryError.emptyField("ID Code") }
        try Equipment.validateBasicInfo(name: name, manufacturer: manufacturer)

        let currentYear = Calendar.current.component(.year, from: Date())
        guard purchaseYear >= 1990 && purchaseYear <= currentYear else { throw LibraryError.invalidYear }

        self.id = cleanID
        self.name = name.trimmed
        self.manufacturer = manufacturer.trimmed
        self.purchaseYear = purchaseYear
    }

    static func validateBasicInfo(name: String, manufacturer: String) throws {
        guard !name.trimmed.isEmpty else { throw LibraryError.emptyField("Name") }
        guard !manufacturer.trimmed.isEmpty else { throw LibraryError.emptyField("Manufacturer") }
    }

    func updateBasicInfo(name: String, manufacturer: String) throws {
        try Equipment.validateBasicInfo(name: name, manufacturer: manufacturer)
        self.name = name.trimmed
        self.manufacturer = manufacturer.trimmed
    }

    func borrow(by borrower: String, borrowDate: Date, expectedReturn: Date) throws {
        guard isAvailable else { throw LibraryError.alreadyBorrowed }
        guard !borrower.trimmed.isEmpty else { throw LibraryError.emptyField("Borrower Name") }

        let startOfBorrow = Calendar.current.startOfDay(for: borrowDate)
        let startOfReturn = Calendar.current.startOfDay(for: expectedReturn)
        guard startOfReturn > startOfBorrow else { throw LibraryError.invalidDate }

        self.currentBorrower = borrower.trimmed
        self.borrowDate = borrowDate
        self.expectedReturnDate = expectedReturn
        self.isAvailable = false
    }

    func returnEquipment() throws {
        guard !isAvailable else { throw LibraryError.notCurrentlyBorrowed }
        self.currentBorrower = nil
        self.borrowDate = nil
        self.expectedReturnDate = nil
        self.isAvailable = true
    }
}

class Laptop: Equipment {
    @Published private(set) var processor: String
    @Published private(set) var memoryGB: Int
    @Published private(set) var storageGB: Int

    init(id: String, name: String, manufacturer: String, purchaseYear: Int, processor: String, memoryGB: Int, storageGB: Int) throws {
        try Laptop.validateSpecs(processor: processor, memoryGB: memoryGB, storageGB: storageGB)

        self.processor = processor.trimmed
        self.memoryGB = memoryGB
        self.storageGB = storageGB
        try super.init(id: id, name: name, manufacturer: manufacturer, purchaseYear: purchaseYear)
    }

    static func validateSpecs(processor: String, memoryGB: Int, storageGB: Int) throws {
        guard !processor.trimmed.isEmpty else { throw LibraryError.emptyField("Processor") }
        guard memoryGB > 0 else { throw LibraryError.invalidNumber("Memory (GB)") }
        guard storageGB > 0 else { throw LibraryError.invalidNumber("Storage (GB)") }
    }

    func updateSpecs(processor: String, memoryGB: Int, storageGB: Int) throws {
        try Laptop.validateSpecs(processor: processor, memoryGB: memoryGB, storageGB: storageGB)
        self.processor = processor.trimmed
        self.memoryGB = memoryGB
        self.storageGB = storageGB
    }
}

class Tablet: Equipment {
    @Published private(set) var screenSize: Double
    @Published private(set) var batteryCapacity: Int
    @Published private(set) var supportsDigitalPen: Bool

    init(id: String, name: String, manufacturer: String, purchaseYear: Int, screenSize: Double, batteryCapacity: Int, supportsDigitalPen: Bool) throws {
        try Tablet.validateSpecs(screenSize: screenSize, batteryCapacity: batteryCapacity)

        self.screenSize = screenSize
        self.batteryCapacity = batteryCapacity
        self.supportsDigitalPen = supportsDigitalPen
        try super.init(id: id, name: name, manufacturer: manufacturer, purchaseYear: purchaseYear)
    }

    static func validateSpecs(screenSize: Double, batteryCapacity: Int) throws {
        guard screenSize > 0 else { throw LibraryError.invalidNumber("Screen Size") }
        guard batteryCapacity > 0 else { throw LibraryError.invalidNumber("Battery Capacity") }
    }

    func updateSpecs(screenSize: Double, batteryCapacity: Int, supportsDigitalPen: Bool) throws {
        try Tablet.validateSpecs(screenSize: screenSize, batteryCapacity: batteryCapacity)
        self.screenSize = screenSize
        self.batteryCapacity = batteryCapacity
        self.supportsDigitalPen = supportsDigitalPen
    }
}

class DigitalCamera: Equipment {
    @Published private(set) var sensorResolutionMP: Double
    @Published private(set) var lensType: String
    @Published private(set) var supportsVideo: Bool

    init(id: String, name: String, manufacturer: String, purchaseYear: Int, sensorResolutionMP: Double, lensType: String, supportsVideo: Bool) throws {
        try DigitalCamera.validateSpecs(sensorResolutionMP: sensorResolutionMP, lensType: lensType)

        self.sensorResolutionMP = sensorResolutionMP
        self.lensType = lensType.trimmed
        self.supportsVideo = supportsVideo
        try super.init(id: id, name: name, manufacturer: manufacturer, purchaseYear: purchaseYear)
    }

    static func validateSpecs(sensorResolutionMP: Double, lensType: String) throws {
        guard sensorResolutionMP > 0 else { throw LibraryError.invalidNumber("Sensor Resolution") }
        guard !lensType.trimmed.isEmpty else { throw LibraryError.emptyField("Lens Type") }
    }

    func updateSpecs(sensorResolutionMP: Double, lensType: String, supportsVideo: Bool) throws {
        try DigitalCamera.validateSpecs(sensorResolutionMP: sensorResolutionMP, lensType: lensType)
        self.sensorResolutionMP = sensorResolutionMP
        self.lensType = lensType.trimmed
        self.supportsVideo = supportsVideo
    }
}
