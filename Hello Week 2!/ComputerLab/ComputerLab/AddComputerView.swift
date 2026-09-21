//
//  AddComputerView.swift
//  ComputerLab
//
//  Created by Nguyễn Hoàng Bảo Hân on 21/9/26.
//

import SwiftUI

struct AddComputerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var computers: [Computer]
    
    @State private var computerName: String = ""
    @State private var location: String = "Lab A"
    @State private var isAvailable: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "desktopcomputer")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            TextField("Enter computer name (e.g. PC06)", text: $computerName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Enter location (e.g. Lab A)", text: $location)
                .textFieldStyle(.roundedBorder)
            
            Toggle("Available", isOn: $isAvailable)
            
            Button(action: {
                // Kiểm tra nếu tên không rỗng thì mới thêm
                if !computerName.isEmpty {
                    let newComputer = Computer(name: computerName, location: location, isAvailable: isAvailable)
                    computers.append(newComputer)
                    dismiss() // Tự động quay về màn hình trước
                }
            }) {
                Text("Add")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Add Computer")
        .navigationBarBackButtonHidden(false)
    }
}

