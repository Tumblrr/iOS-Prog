//
//  ContentView.swift
//  Richer Student Profile UI
//
//  Created by Nguyễn Hoàng Bảo Hân on 16/9/26.
//

import SwiftUI

struct ContentView: View {
    // 1. Khai báo các biến dữ liệu (UI Content) theo đúng kiểu dữ liệu yêu cầu
    let studentName: String = "Nguyễn Hoàng Bảo Hân"
    let studentID: String = "SESEIU24008"
    let age: Int = 20
    let gpa: Double = 3.8
    let isStudent: Bool = true
    let motto: String = "\"Better me, a brighter tomorrow!\""
    
    var body: some View {
        TabView {
            // --- TAB 1: PROFILE ---
            ScrollView {
                VStack(spacing: 0) {
                    
                    // 2. ZStack cho Header (Hình nền + Chữ + Nút Cài đặt)
                    ZStack(alignment: .top) {
                        // Background gradient mô phỏng bầu trời
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.teal.opacity(0.1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 200)
                        
                        // Chữ ở trung tâm Header
                        Text("Small Steps\nBig Dreams 🤍")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.blue.opacity(0.8))
                            .padding(.top, 50)
                        
                        // Icon Setting ở góc phải
                        HStack {
                            Spacer()
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    // 3. VStack cho nội dung chính (Căn chỉnh từ trên xuống)
                    VStack(spacing: 20) {
                        
                        // Avatar nằm đè lên Header (dùng offset)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                            .offset(y: -50)
                            .padding(.bottom, -50) // Bù trừ khoảng trống do offset tạo ra
                        
                        // Phần Tên và Châm ngôn phụ
                        VStack(spacing: 5) {
                            Text(studentName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Space Engineering | Always learning, always growing ♡")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // 4. HStack cho các hàng thông tin (Sắp xếp icon và text)
                        VStack(spacing: 15) {
                            HStack(spacing: 15) {
                                InfoCard(icon: "person.fill", title: "Student ID", value: studentID, iconColor: .blue)
                                InfoCard(icon: "birthday.cake.fill", title: "Age", value: "\(age)", iconColor: .pink)
                            }
                            HStack(spacing: 15) {
                                InfoCard(icon: "chart.bar.fill", title: "GPA", value: String(format: "%.1f", gpa), iconColor: .green)
                                InfoCard(icon: "graduationcap.fill", title: "Student", value: isStudent ? "true" : "false", iconColor: .purple)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Khối Motto / Quote
                        HStack {
                            Text(motto)
                                .font(.callout)
                                .italic()
                                .foregroundColor(.orange)
                            Spacer()
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Nút Edit Profile
                        Button(action: {
                            // Xử lý action ở đây
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Edit Profile")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .background(Color.white)
                    // Bo góc phần nội dung trắng để tạo cảm giác "thẻ" đè lên header
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(y: -20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.top)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Profile")
            }
            
            // --- TAB 2: SUBJECTS ---
            Text("Subjects View")
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Subjects")
                }
            
            // --- TAB 3: SETTINGS ---
            Text("Settings View")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

// Component phụ giúp tái sử dụng code cho 4 ô thông tin
struct InfoCard: View {
    var icon: String
    var title: String
    var value: String
    var iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title2)
                .frame(width: 30) // Giữ các icon có kích thước đều nhau
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .bold()
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// Extension hỗ trợ bo góc (cornerRadius) cho các góc cụ thể (chỉ bo phía trên của view trắng)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
