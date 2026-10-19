import SwiftUI
import Combine

// MARK: - Student Class
class Student: Identifiable {
    let id: String
    var name: String
    var age: Int
    
    init(id: String, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }
    
    func displayInfo() -> String {
        return "ID: \(id) | Name: \(name) | Age: \(age)"
    }
}

// MARK: - Subject Class
class Subject: Identifiable {
    let id: String
    var name: String
    var credits: Int
    
    init(id: String, name: String, credits: Int) {
        self.id = id
        self.name = name
        self.credits = credits
    }
}

class StudentRecord: Identifiable {
    let id = UUID()
    var student: Student
    var subject: Subject
    var mark: Double {
        didSet {
            if mark < 0 { mark = 0 }
            if mark > 10 { mark = 10 }
        }
    }
    
    init(student: Student, subject: Subject, mark: Double) {
        self.student = student
        self.subject = subject
        self.mark = min(max(mark, 0.0), 10.0)
    }
    
    func isPassed() -> Bool {
        return mark >= 5.0
    }
}

class AcademicManager: ObservableObject {
    @Published var students: [Student] = []
    @Published var subjects: [Subject] = []
    @Published var records: [StudentRecord] = []
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        let s1 = Student(id: "SESEIU24008", name: "Nguyễn Hoàng Bảo Hân", age: 20)
        let s2 = Student(id: "SESEIU24017", name: "Nguyễn Thiên Phong", age: 20)
        let s3 = Student(id: "SESEIU24021", name: "Dương Ngọc Anh Thư", age: 20)
        let s4 = Student(id: "SESEIU24029", name: "Nguyễn Trần Anh Tuấn", age: 20)
        
        students = [s1, s2, s3, s4]
        
        let sub1 = Subject(id: "SUB1", name: "Spacecraft Systems", credits: 4)
        let sub2 = Subject(id: "SUB2", name: "Orbital Mechanics", credits: 3)
        let sub3 = Subject(id: "SUB3", name: "Aerodynamics", credits: 4)
        let sub4 = Subject(id: "SUB4", name: "SwiftUI Programming", credits: 3)
        
        subjects = [sub1, sub2, sub3, sub4]
        
        records = [
            StudentRecord(student: s1, subject: sub1, mark: 8.5),
            StudentRecord(student: s1, subject: sub2, mark: 9.0),
            StudentRecord(student: s2, subject: sub1, mark: 6.5),
            StudentRecord(student: s2, subject: sub3, mark: 4.5),
            StudentRecord(student: s3, subject: sub2, mark: 7.5),
            StudentRecord(student: s3, subject: sub4, mark: 8.0),
            StudentRecord(student: s4, subject: sub3, mark: 5.5),
            StudentRecord(student: s4, subject: sub4, mark: 3.5)
        ]
    }
    
    func calculateWeightedAverage(for student: Student) -> Double {
        let studentRecords = records.filter { $0.student.id == student.id }
        guard !studentRecords.isEmpty else { return 0.0 }
        
        let totalScoreProduct = studentRecords.reduce(0.0) { $0 + ($1.mark * Double($1.subject.credits)) }
        let totalCredits = studentRecords.reduce(0) { $0 + $1.subject.credits }
        
        guard totalCredits > 0 else { return 0.0 }
        return totalScoreProduct / Double(totalCredits)
    }
    
    func getAcademicRanking(for student: Student) -> String {
        let avg = calculateWeightedAverage(for: student)
        let studentRecords = records.filter { $0.student.id == student.id }
        
        if studentRecords.isEmpty { return "No Records" }
        
        if avg >= 8.5 {
            return "Excellent"
        } else if avg >= 7.0 {
            return "Good"
        } else if avg >= 5.0 {
            return "Average"
        } else {
            return "Fail"
        }
    }
}
