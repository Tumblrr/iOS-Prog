//
//  ContentView.swift
//  Week2 Array
//
//  Created by Nguyễn Hoàng Bảo Hân on 21/9/26.
//

import SwiftUI

// 1. Tạo struct Computer
struct Computer: Identifiable {
    let id = UUID()
    var name: String
    var location: String
    var isAvailable: Bool
}

// 2. Màn hình Home (List View)
struct ContentView: View {
    // Data mẫu ban đầu
    @State private var computers: [Computer] = [
        Computer(name: "iMac 01", location: "LA1.504", isAvailable: true),
        Computer(name: "iMac 02", location: "LA1.504", isAvailable: false)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                List(computers) { computer in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(computer.name)
                                .font(.headline)
                            Text(computer.location)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        // Hiển thị trạng thái bằng chấm màu
                        Circle()
                            .fill(computer.isAvailable ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Nút nhảy sang màn hình Thống kê
                NavigationLink(destination: StatisticsView(computers: computers)) {
                    Text("Xem Thống Kê")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Quản lý Phòng Lab")
            .toolbar {
                // 4. Dùng NavigationLink để nhảy sang màn hình Add
                NavigationLink(destination: AddComputerView(computers: $computers)) {
                    Image(systemName: "plus")
                        .font(.title3)
                }
            }
        }
    }
}

// 3. Màn hình Add Computer
struct AddComputerView: View {
    // Dùng @Binding để đồng bộ data về màn hình Home
    @Binding var computers: [Computer]
    
    // Biến môi trường để đóng màn hình sau khi thêm xong
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var isAvailable: Bool = true
    
    var body: some View {
        Form {
            Section(header: Text("Thông tin máy")) {
                TextField("Tên máy (VD: iMac 03)", text: $name)
                TextField("Vị trí (VD: LA1.504)", text: $location)
                Toggle("Trạng thái (Sẵn sàng)", isOn: $isAvailable)
            }
            
            Button(action: {
                // Tạo máy mới và nhét vào mảng
                let newComputer = Computer(name: name, location: location, isAvailable: isAvailable)
                computers.append(newComputer)
                
                // Tự động quay lại Home, danh sách sẽ tự update
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Thêm máy")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(name.isEmpty || location.isEmpty) // Khóa nút nếu chưa nhập xong
        }
        .navigationTitle("Thêm Máy Mới")
    }
}

// 5. Màn hình Thống kê (Statistics)
struct StatisticsView: View {
    var computers: [Computer]
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "desktopcomputer")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            VStack(spacing: 15) {
                Text("Tổng số máy: \(computers.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("🟢 Sẵn sàng: \(computers.filter { $0.isAvailable }.count)")
                    .font(.headline)
                
                Text("🔴 Đang bận: \(computers.filter { !$0.isAvailable }.count)")
                    .font(.headline)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Thống Kê")
    }
}
