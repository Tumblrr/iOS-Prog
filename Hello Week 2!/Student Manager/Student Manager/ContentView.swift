//
//  ContentView.swift
//  Student Manager
//
//  Created by Nguyễn Hoàng Bảo Hân on 21/9/26.
//

import SwiftUI

struct ContentView: View {
    // Dữ liệu mẫu ban đầu
    // Dữ liệu mẫu ban đầu đã được đổi tên
        @State private var students: [Student] = [
            Student(id: "SESEIU24008", name: "Bảo Hân", gpa: 8.5),
            Student(id: "SESEIU22001", name: "Quốc Anh", gpa: 9.2),
            Student(id: "SESEIU19003", name: "Đăng Khoa", gpa: 9.3)
        ]
    @State private var searchText: String = ""
    
    // Biến tính toán để lọc danh sách sinh viên theo từ khóa tìm kiếm
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return students
        } else {
            return students.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Thanh tìm kiếm
                TextField("Search student by name...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                // Danh sách sinh viên
                List {
                    ForEach(filteredStudents) { student in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(student.name)
                                    .font(.headline)
                                Text("GPA: \(String(format: "%.1f", student.gpa))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(student.id)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteStudent) // Tính năng vuốt để xóa
                }
                
                // Nút chuyển sang màn hình Thêm sinh viên
                NavigationLink(destination: AddStudentView(students: $students)) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Student")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                // Đếm tổng số lượng
                Text("Total students: \(students.count)")
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("Student Manager")
        }
    }
    
    // Hàm xử lý việc xóa dữ liệu khỏi mảng
    func deleteStudent(at offsets: IndexSet) {
        students.remove(atOffsets: offsets)
    }
}
