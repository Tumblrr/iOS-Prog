//
//  Richer_Student_Profile_UIApp.swift
//  Richer Student Profile UI
//
//  Created by Nguyễn Hoàng Bảo Hân on 16/9/26.
//
import SwiftUI

struct StudentProfileView: View {
    // 1. Dữ liệu cần hiển thị
    let name = "Nguyễn Hoàng Bảo Hân"
    let mssv = "SESEIU24008"
    let gpa: Double = 3.8
    let status = "Active"
    let age: Int = 20
    let motto = "Per aspera ad astra - Qua gian nan tới các vì sao."
    
    var body: some View {
        VStack(spacing: 0) {
            // Phần cuộn nội dung phía trên
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 2. PHẦN HEADER (ZStack)
                    ZStack(alignment: .bottom) {
                        // Ảnh bìa nằm dưới cùng (Dùng Gradient vũ trụ làm nền mờ)
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 220)
                        // Nếu có ảnh thật, bạn thay bằng: Image("CoverPhoto").resizable().scaledToFill().frame(height: 220).clipped()
                        
                        // Avatar và Thông tin nằm đè lên trên
                        VStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.fill") // Thay bằng Image("Avatar_Của_Bạn")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .foregroundColor(.white)
                                .background(Color.black)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 5)
                            
                            Text(name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(motto)
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .offset(y: 40) // Đẩy khối avatar xuống để cắt ngang viền ảnh bìa
                    }
                    .padding(.bottom, 50) // Nhường chỗ cho offset
                    
                    
                    // 3. PHẦN THÔNG TIN (Card-style dùng VStack & HStack)
                    VStack(spacing: 16) {
                        // Hàng 1
                        HStack {
                            InfoItem(icon: "person.text.rectangle", title: "MSSV", value: mssv)
                            Spacer()
                            InfoItem(icon: "calendar", title: "Tuổi", value: "\(age)")
                        }
                        
                        Divider() // Đường kẻ ngang phân cách
                        
                        // Hàng 2
                        HStack {
                            InfoItem(icon: "graduationcap.fill", title: "GPA", value: String(format: "%.1f", gpa))
                            Spacer()
                            InfoItem(icon: "checkmark.seal.fill", title: "Trạng thái", value: status)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(15) // Bo góc
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // Đổ bóng tạo hiệu ứng thẻ
                    .padding(.horizontal, 20)
                }
            }
            
            // 4. THANH ĐIỀU HƯỚNG CUỐI MÀN HÌNH (Bottom Tabs - HStack)
            HStack {
                Spacer()
                BottomTabButton(icon: "person.fill", title: "Profile", isActive: true)
                Spacer()
                BottomTabButton(icon: "book.closed.fill", title: "Subjects", isActive: false)
                Spacer()
                BottomTabButton(icon: "gearshape.fill", title: "Settings", isActive: false)
                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, 20) // Khoảng không gian an toàn cho tai thỏ/home indicator
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -5)
        }
        .edgesIgnoringSafeArea(.bottom) // Cho phép tab bar tràn xuống đáy
        .background(Color(UIColor.systemGroupedBackground)) // Màu nền tổng thể nhạt để nổi bật thẻ
    }
}

// MARK: - Subviews (Các thành phần nhỏ được tách ra cho code gọn gàng)

// Component hiển thị từng mục thông tin
struct InfoItem: View {
    var icon: String
    var title: String
    var value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}

// Component cho nút bấm ở Bottom Tab
struct BottomTabButton: View {
    var icon: String
    var title: String
    var isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
            Text(title)
                .font(.caption2)
                .fontWeight(isActive ? .bold : .regular)
        }
        .foregroundColor(isActive ? .blue : .gray)
    }
}

#Preview {
    StudentProfileView()
}
