//
//  models.swift
//  Class definition
//
//  Created by Nguyễn Hoàng Bảo Hân on 19/10/26.
//

import Foundation
import SwiftUI
import Combine

class Subject: Identifiable {
    let id: String
    var name: String
    var credits: Int
    
    init(id: String = UUID().uuidString, name: String, credits: Int) {
        self.id = id
        self.name = name
        self.credits = credits
    }
}

class Teacher: Identifiable {
    let id: String
    var name: String
    var subjects: [Subject]
    init(id: String = UUID().uuidString, name: String, subjects: [Subject] = []) {
        self.id = id
        self.name = name
        self.subjects = subjects
    }
}

class Student: Identifiable {
    let id: String
    var name: String
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}

class StudentSubject: Identifiable {
    let id = UUID()
    var idStudent: String
    var idSubject: String
    var mark: Double
    
    init(idStudent: String, idSubject: String, mark: Double = 0.0) {
        self.idStudent = idStudent
        self.idSubject = idSubject
        self.mark = mark
    }
}

class SchoolManager: ObservableObject {
    @Published var students: [Student] = []
    @Published var subjects: [Subject] = []
    @Published var teachers: [Teacher] = []
    @Published var records: [StudentSubject] = []
    
    init() {
        let s1 = Student(name: "Nguyễn Hoàng Bảo Hân")
        let s2 = Student(name: "Trần Trung Kiên")
        let s3 = Student(name: "Lê Đăng Khoa")
        students = [s1, s2, s3]
        
        let sub1 = Subject(name: "iOS Programming", credits: 4)
        let sub2 = Subject(name: "Database", credits: 3)
        subjects = [sub1, sub2]
        
        records = [
            StudentSubject(idStudent: s1.id, idSubject: sub1.id, mark: 9.0),
            StudentSubject(idStudent: s1.id, idSubject: sub2.id, mark: 8.5),
            StudentSubject(idStudent: s2.id, idSubject: sub1.id, mark: 4.0),
            StudentSubject(idStudent: s3.id, idSubject: sub2.id, mark: 3.5)
        ]
    }
    
    func addStudent(name: String) {
        students.append(Student(name: name))
    }
    
    func addSubject(name: String, credits: Int) {
        subjects.append(Subject(name: name, credits: credits))
    }
    
    func enrollStudent(studentId: String, subjectId: String) {
    
        if !records.contains(where: { $0.idStudent == studentId && $0.idSubject == subjectId }) {
            records.append(StudentSubject(idStudent: studentId, idSubject: subjectId))
        }
    }
    
    func updateMark(studentId: String, subjectId: String, newMark: Double) {
        if let record = records.first(where: { $0.idStudent == studentId && $0.idSubject == subjectId }) {
            record.mark = newMark
            self.objectWillChange.send() // Báo cho UI biết để cập nhật lại giao diện
        }
    }
    
    func calculateGPA(for studentId: String) -> Double {
        let studentRecords = records.filter { $0.idStudent == studentId }
        var totalPoints = 0.0
        var totalCredits = 0
        
        for record in studentRecords {
            if let subject = subjects.first(where: { $0.id == record.idSubject }) {
                totalPoints += record.mark * Double(subject.credits)
                totalCredits += subject.credits
            }
        }
        return totalCredits > 0 ? totalPoints / Double(totalCredits) : 0.0
    }
    
    func getStudentsWithGPAOver8() -> [Student] {
        return students.filter { calculateGPA(for: $0.id) > 8.0 }
    }
    
    func getFailedStudents(for subjectId: String) -> [Student] {
        let failedRecords = records.filter { $0.idSubject == subjectId && $0.mark < 5.0 }
        let failedStudentIds = failedRecords.map { $0.idStudent }
        return students.filter { failedStudentIds.contains($0.id) }
    }
}
