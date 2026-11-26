//
//  models.swift
//  task 5 - week 7
//
//  Created by Nguyễn Hoàng Bảo Hân on 2/11/26.
//

import SwiftUI
import Combine
import Foundation

class LibraryResource: Identifiable, ObservableObject {
    let id = UUID()
    let title: String
    
    @Published private(set) var isAvailable: Bool
    
    init(title: String, isAvailable: Bool = true) {
        self.title = title
        self.isAvailable = isAvailable
    }
    
    func borrowResource() throws -> String {
        guard isAvailable else { throw LibraryError.alreadyBorrowed }
        isAvailable = false
        return "Successfully borrowed: \(title). Base fee: $\(calculateFee())"
    }
    
    func returnResource() {
        isAvailable = true
    }
    
    func calculateFee() -> Double { return 0.0 }
}

class PrintedBook: LibraryResource {
    let author: String
    let isbn: String
    let requiresDeposit: Bool
    
    init(title: String, author: String, isbn: String, requiresDeposit: Bool) {
        self.author = author
        self.isbn = isbn
        self.requiresDeposit = requiresDeposit
        super.init(title: title)
    }
    
    override func calculateFee() -> Double { return requiresDeposit ? 15.0 : 0.0 }
}

class AcademicJournal: LibraryResource {
    let volume: Int
    let issue: Int
    let isLibraryOnly: Bool
    
    init(title: String, volume: Int, issue: Int, isLibraryOnly: Bool) {
        self.volume = volume
        self.issue = issue
        self.isLibraryOnly = isLibraryOnly
        super.init(title: title)
    }
    
    override func borrowResource() throws -> String {
        if isLibraryOnly { throw LibraryError.restrictedAccess }
        return try super.borrowResource()
    }
}

enum LibraryError: Error, LocalizedError {
    case alreadyBorrowed
    case restrictedAccess
    
    var errorDescription: String? {
        switch self {
        case .alreadyBorrowed: return "Operation Rejected: This resource is currently unavailable."
        case .restrictedAccess: return "Operation Rejected: This journal is for in-library use only."
        }
    }
}

class LibraryViewModel: ObservableObject {
    @Published var resources: [LibraryResource] = [
        PrintedBook(title: "Space Engineering Fundamentals", author: "John Doe", isbn: "12345", requiresDeposit: true),
        AcademicJournal(title: "Astrophysics Quarterly", volume: 42, issue: 3, isLibraryOnly: true),
        PrintedBook(title: "SwiftUI for Beginners", author: "Jane Smith", isbn: "67890", requiresDeposit: false)
    ]
}
