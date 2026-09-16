//
//  ContentView.swift
//  StudentCard
//
//  Created by Nguyễn Hoàng Bảo Hân on 16/9/26.
//
import SwiftUI

struct ContentView: View {
    // Khai báo biến/hằng số theo yêu cầu
    let studentName: String = "Nguyễn Hoàng Bảo Hân"
    let studentID: String = "SESEIU24008"
    var gpa: Double = 2.8
    let status: String = "Active"
    
    var body: some View {
        // 1. ZSTACK NGOÀI CÙNG: Để chứa ảnh nền và chiếc thẻ
        ZStack {
            
            // Lớp dưới cùng: Ảnh nền toàn màn hình
            Image("pic")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Lớp nổi lên trên: Chiếc thẻ sinh viên (HStack)
            HStack(spacing: 16) {
                
                // Avatar (ZStack nhỏ)
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "graduationcap.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
                
                // VStack chứa các dòng thông tin chữ
                VStack(alignment: .leading, spacing: 6) {
                    
                    // Hàng chứa Tên và Trạng thái (Badge)
                    HStack {
                        Text(studentName)
                            .font(.title3)
                            .bold()
                        
                        Spacer() // Đẩy Badge sang góc phải
                        
                        Text(status)
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(10)
                    }
                    
                    Text("Student ID: \(studentID)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                        Text("GPA: \(String(format: "%.1f", gpa))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            // Các modifier để tạo hình dáng chiếc thẻ
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            
        } // Kết thúc ZStack ngoài cùng
    }
}

#Preview {
    ContentView()
}
