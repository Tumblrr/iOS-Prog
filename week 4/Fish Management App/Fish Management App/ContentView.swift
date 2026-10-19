//
//  ContentView.swift
//  Fish Management App
//
//  Created by Nguyễn Hoàng Bảo Hân on 19/10/26.
//
import SwiftUI

struct ContentView: View {
    // Dữ liệu mẫu (Sample data)
    @State private var fishes: [Fish] = [
        Fish(id: 1, name: "Neon Fish", color: "Red", price: 20.0),
        Fish(id: 2, name: "Betta Fish", color: "Blue", price: 35.0),
        Fish(id: 3, name: "Goldfish", color: "Orange", price: 25.0),
        Fish(id: 4, name: "Angelfish", color: "Silver", price: 40.0)
    ]
    
    var body: some View {
        NavigationView {
            List(fishes) { fish in
                HStack(spacing: 16) {
                    Image(systemName: "fish.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        // Lấy màu hiển thị cho con cá
                        .foregroundColor(fish.getColor())
                    
                    // Xử lý tách chuỗi từ hàm getInfo() để hiển thị đúng dòng
                    let infoParts = fish.getInfo().components(separatedBy: "-")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Tên cá (phần tử thứ 1 sau khi tách mảng)
                        Text(infoParts[1])
                            .font(.headline)
                        
                        // Màu sắc và Giá tiền (phần tử thứ 2 và 3)
                        Text("\(infoParts[2]) - $\(infoParts[3])")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("My Aquarium")
        }
    }
}

#Preview {
    ContentView()
}
