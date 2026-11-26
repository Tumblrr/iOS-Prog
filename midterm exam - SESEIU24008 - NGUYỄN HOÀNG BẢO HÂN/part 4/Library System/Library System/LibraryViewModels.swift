//
//  LibraryViewModels.swift
//  Library System
//
//  Created by Nguyễn Hoàng Bảo Hân on 9/11/26.
//

import Foundation
import SwiftUI
import Combine

enum EquipmentType: Int, CaseIterable, Identifiable {
    case laptop, tablet, camera

    var id: Int { rawValue }
    var title: String {
        switch self {
        case .laptop: return "Laptop"
        case .tablet: return "Tablet"
        case .camera: return "Camera"
        }
    }
}

struct EquipmentForm {
    var type: EquipmentType = .laptop
    var id = ""
    var name = ""
    var manufacturer = ""
    var purchaseYear = ""

    var processor = ""
    var memory = ""
    var storage = ""
    
    var screenSize = ""
    var battery = ""
    var hasPen = false
    
    var resolution = ""
    var lens = ""
    var video = false
}

extension EquipmentForm {
    init(item: Equipment) {
        self.init()
        id = item.id
        name = item.name
        manufacturer = item.manufacturer
        purchaseYear = "\(item.purchaseYear)"

        if let laptop = item as? Laptop {
            type = .laptop
            processor = laptop.processor
            memory = "\(laptop.memoryGB)"
            storage = "\(laptop.storageGB)"
        } else if let tablet = item as? Tablet {
            type = .tablet
            screenSize = "\(tablet.screenSize)"
            battery = "\(tablet.batteryCapacity)"
            hasPen = tablet.supportsDigitalPen
        } else if let camera = item as? DigitalCamera {
            type = .camera
            resolution = "\(camera.sensorResolutionMP)"
            lens = camera.lensType
            video = camera.supportsVideo
        }
    }
}

class LibraryViewModel: ObservableObject {
    @Published private(set) var equipmentList: [Equipment] = []

    init() {
        loadSampleData()
    }

    func registerEquipment(_ equipment: Equipment) throws {
        if equipmentList.contains(where: { $0.id == equipment.id }) {
            throw LibraryError.duplicateID
        }
        equipmentList.append(equipment)
    }

    func register(form: EquipmentForm) throws {
        guard let year = Int(form.purchaseYear.trimmed) else { throw LibraryError.invalidYear }

        let item: Equipment
        switch form.type {
        case .laptop:
            item = try Laptop(id: form.id, name: form.name, manufacturer: form.manufacturer,
                              purchaseYear: year, processor: form.processor,
                              memoryGB: LibraryViewModel.parseInt(form.memory, field: "Memory (GB)"),
                              storageGB: LibraryViewModel.parseInt(form.storage, field: "Storage (GB)"))
        case .tablet:
            item = try Tablet(id: form.id, name: form.name, manufacturer: form.manufacturer,
                              purchaseYear: year,
                              screenSize: LibraryViewModel.parseDouble(form.screenSize, field: "Screen Size"),
                              batteryCapacity: LibraryViewModel.parseInt(form.battery, field: "Battery Capacity"),
                              supportsDigitalPen: form.hasPen)
        case .camera:
            item = try DigitalCamera(id: form.id, name: form.name, manufacturer: form.manufacturer,
                                     purchaseYear: year,
                                     sensorResolutionMP: LibraryViewModel.parseDouble(form.resolution, field: "Sensor Resolution"),
                                     lensType: form.lens, supportsVideo: form.video)
        }
        try registerEquipment(item)
    }

    func update(_ item: Equipment, with form: EquipmentForm) throws {
        try Equipment.validateBasicInfo(name: form.name, manufacturer: form.manufacturer)

        if let laptop = item as? Laptop {
            try laptop.updateSpecs(processor: form.processor,
                                   memoryGB: LibraryViewModel.parseInt(form.memory, field: "Memory (GB)"),
                                   storageGB: LibraryViewModel.parseInt(form.storage, field: "Storage (GB)"))
        } else if let tablet = item as? Tablet {
            try tablet.updateSpecs(screenSize: LibraryViewModel.parseDouble(form.screenSize, field: "Screen Size"),
                                   batteryCapacity: LibraryViewModel.parseInt(form.battery, field: "Battery Capacity"),
                                   supportsDigitalPen: form.hasPen)
        } else if let camera = item as? DigitalCamera {
            try camera.updateSpecs(sensorResolutionMP: LibraryViewModel.parseDouble(form.resolution, field: "Sensor Resolution"),
                                   lensType: form.lens, supportsVideo: form.video)
        }
        
        try item.updateBasicInfo(name: form.name, manufacturer: form.manufacturer)
        objectWillChange.send()
    }

    func borrowEquipment(_ equipment: Equipment, borrower: String, borrowDate: Date, expectedReturn: Date) throws {
        try equipment.borrow(by: borrower, borrowDate: borrowDate, expectedReturn: expectedReturn)
        objectWillChange.send()
    }

    func returnEquipment(_ equipment: Equipment) throws {
        try equipment.returnEquipment()
        objectWillChange.send()
    }

    private static func parseInt(_ text: String, field: String) throws -> Int {
        guard let value = Int(text.trimmed), value > 0 else { throw LibraryError.invalidNumber(field) }
        return value
    }

    private static func parseDouble(_ text: String, field: String) throws -> Double {
        guard let value = Double(text.trimmed), value > 0 else { throw LibraryError.invalidNumber(field) }
        return value
    }

    private func loadSampleData() {
        do {
            let laptop = try Laptop(id: "L01", name: "MacBook Pro 14\"", manufacturer: "Apple", purchaseYear: 2023, processor: "M2 Pro", memoryGB: 16, storageGB: 512)
            let tablet = try Tablet(id: "T01", name: "iPad Air", manufacturer: "Apple", purchaseYear: 2022, screenSize: 10.9, batteryCapacity: 7600, supportsDigitalPen: true)
            let camera = try DigitalCamera(id: "C01", name: "Canon EOS 90D", manufacturer: "Canon", purchaseYear: 2021, sensorResolutionMP: 32.5, lensType: "EF-S 18-135mm", supportsVideo: true)

            equipmentList.append(contentsOf: [laptop, tablet, camera])
        } catch {
            print(error)
        }
    }
}
