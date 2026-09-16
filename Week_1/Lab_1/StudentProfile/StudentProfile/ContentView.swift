import SwiftUI

struct ContentView: View {
    // Khai báo các biến lưu trữ thông tin
    var studentName: String = "Nguyễn Hoàng Bảo Hân"
    var studentID: String = "SESEIU24008"
    var age: Int = 20
    var gpa: Double = 2.8
    var isStudent: Bool = true
    
    var body: some View {
            ZStack {
                Image("pic")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            VStack(spacing: 25) {
                // Icon Mũ tốt nghiệp
                Image(systemName: "graduationcap.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                // Tiêu đề
                Text("Student Profile")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.4))
                
                // --- BẮT ĐẦU KHỐI THÔNG TIN (CARD) ---
                VStack(spacing: 16) {
                    
                    // Hàng 1: Name
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("Name")
                            .foregroundColor(.gray)
                        Spacer() // Đẩy giá trị sang sát lề phải
                        Text(studentName)
                            .fontWeight(.medium)
                    }
                    Divider() // Đường kẻ ngang
                    
                    // Hàng 2: Student ID
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("Student ID")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(studentID)
                            .fontWeight(.medium)
                    }
                    Divider()
                    
                    // Hàng 3: Age
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("Age")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(age)")
                            .fontWeight(.medium)
                    }
                    Divider()
                    
                    // Hàng 4: GPA (vẫn giữ định dạng 1 chữ số thập phân)
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("GPA")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.1f", gpa))
                            .fontWeight(.medium)
                    }
                    Divider()
                    
                    // Hàng 5: Student
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green) // Icon màu xanh lá theo mẫu
                            .frame(width: 30)
                        Text("Student")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(isStudent.description)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                // Tạo kiểu Card (Thẻ)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
                // --- KẾT THÚC KHỐI THÔNG TIN ---
                
                Spacer() // Đẩy toàn bộ nội dung lên trên
            }
        }
    }
}

#Preview {
    ContentView()
}
