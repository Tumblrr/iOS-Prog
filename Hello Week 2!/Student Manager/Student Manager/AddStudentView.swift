//
//  AddStudentView.swift
//  Student Manager
//
//  Created by Nguyễn Hoàng Bảo Hân on 21/9/26.
//

import SwiftUI

struct AddStudentView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var students: [Student]
    
    @State private var id: String = ""
    @State private var name: String = ""
    @State private var gpaString: String = "" // Lưu tạm dạng chuỗi để nhập liệu
    
    var body: some View {
        Form {
            Section(header: Text("Student Information")) {
                TextField("Student ID (e.g. S004)", text: $id)
                TextField("Name", text: $name)
                TextField("GPA (0.0 - 10.0)", text: $gpaString)
                    .keyboardType(.decimalPad) // Mở bàn phím số
            }
            
            Button("Add Student") {
                // Ép kiểu chuỗi GPA sang Double và kiểm tra rỗng
                if !id.isEmpty && !name.isEmpty, let gpa = Double(gpaString) {
                    let newStudent = Student(id: id, name: name, gpa: gpa)
                    students.append(newStudent)
                    dismiss() // Tự động đóng màn hình sau khi thêm
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Add New Student")
    }
}
