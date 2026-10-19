//
//  ContentView.swift
//  Class definition
//
//  Created by Nguyễn Hoàng Bảo Hân on 19/10/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = SchoolManager()
    
    var body: some View {
        TabView {
            ManageStudentsView(manager: manager)
                .tabItem { Label("Students", systemImage: "person.2.fill") }
            
            ManageSubjectsView(manager: manager)
                .tabItem { Label("Subjects", systemImage: "book.fill") }
            
            EnrollmentAndMarksView(manager: manager)
                .tabItem { Label("Marks", systemImage: "pencil.and.list.clipboard") }
            
            StatisticsView(manager: manager)
                .tabItem { Label("Statistics", systemImage: "chart.bar.xaxis") }
        }
    }
}

struct ManageStudentsView: View {
    @ObservedObject var manager: SchoolManager
    @State private var newStudentName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter student name", text: $newStudentName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        if !newStudentName.isEmpty {
                            manager.addStudent(name: newStudentName)
                            newStudentName = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }.padding()
                
                List(manager.students) { student in
                    Text(student.name)
                }
            }
            .navigationTitle("Manage Students")
        }
    }
}

struct ManageSubjectsView: View {
    @ObservedObject var manager: SchoolManager
    @State private var newSubjectName = ""
    @State private var creditsStr = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Subject name", text: $newSubjectName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Credits", text: $creditsStr)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                    Button("Add") {
                        if !newSubjectName.isEmpty, let credits = Int(creditsStr) {
                            manager.addSubject(name: newSubjectName, credits: credits)
                            newSubjectName = ""
                            creditsStr = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }.padding()
                
                List(manager.subjects) { subject in
                    HStack {
                        Text(subject.name)
                        Spacer()
                        Text("\(subject.credits) credits").foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Manage Subjects")
        }
    }
}

struct EnrollmentAndMarksView: View {
    @ObservedObject var manager: SchoolManager
    @State private var selectedStudentId: String = ""
    @State private var selectedSubjectId: String = ""
    
    @State private var showingEditAlert = false
    @State private var selectedRecord: StudentSubject?
    @State private var newMarkString: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Form đăng ký môn học
                VStack(spacing: 10) {
                    Picker("Select Student", selection: $selectedStudentId) {
                        Text("Select a student...").tag("")
                        ForEach(manager.students) { student in
                            Text(student.name).tag(student.id)
                        }
                    }.pickerStyle(.menu)
                    
                    Picker("Select Subject", selection: $selectedSubjectId) {
                        Text("Select a subject...").tag("")
                        ForEach(manager.subjects) { subject in
                            Text(subject.name).tag(subject.id)
                        }
                    }.pickerStyle(.menu)
                    
                    Button("Enroll Student to Subject") {
                        if !selectedStudentId.isEmpty && !selectedSubjectId.isEmpty {
                            manager.enrollStudent(studentId: selectedStudentId, subjectId: selectedSubjectId)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                List {
                    Section(header: Text("Course Records (Tap to update mark)")) {
                        ForEach(manager.records) { record in
                            let studentName = manager.students.first(where: { $0.id == record.idStudent })?.name ?? "Unknown"
                            let subjectName = manager.subjects.first(where: { $0.id == record.idSubject })?.name ?? "Unknown"
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(studentName).font(.headline)
                                    Text(subjectName).font(.subheadline).foregroundColor(.gray)
                                }
                                Spacer()
                                Text(String(format: "Mark: %.1f", record.mark))
                                    .bold()
                                    .foregroundColor(record.mark >= 5.0 ? .green : .red)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRecord = record
                                newMarkString = "\(record.mark)"
                                showingEditAlert = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Enrollment & Marks")
            .alert("Update Mark", isPresented: $showingEditAlert) {
                TextField("Enter new mark", text: $newMarkString)
                    .keyboardType(.decimalPad)
                Button("Save") {
                    if let val = Double(newMarkString), let record = selectedRecord {
                        manager.updateMark(studentId: record.idStudent, subjectId: record.idSubject, newMark: val)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .onAppear {
            if selectedStudentId.isEmpty { selectedStudentId = manager.students.first?.id ?? "" }
            if selectedSubjectId.isEmpty { selectedSubjectId = manager.subjects.first?.id ?? "" }
        }
    }
}

struct StatisticsView: View {
    @ObservedObject var manager: SchoolManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Students with GPA > 8.0").font(.headline)) {
                    let excellentStudents = manager.getStudentsWithGPAOver8()
                    if excellentStudents.isEmpty {
                        Text("No students achieved GPA > 8.0 yet.")
                            .italic()
                            .foregroundColor(.gray)
                    } else {
                        ForEach(excellentStudents) { student in
                            HStack {
                                Text(student.name)
                                Spacer()
                                Text(String(format: "GPA: %.2f", manager.calculateGPA(for: student.id)))
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Failed Students by Subject").font(.headline)) {
                    ForEach(manager.subjects) { subject in
                        VStack(alignment: .leading) {
                            Text("Subject: \(subject.name)")
                                .font(.subheadline)
                                .bold()
                            
                            let failedStudents = manager.getFailedStudents(for: subject.id)
                            if failedStudents.isEmpty {
                                Text("   ✅ No failed students")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                ForEach(failedStudents) { student in
                                    Text("   ❌ \(student.name)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

#Preview {
    ContentView()
}
