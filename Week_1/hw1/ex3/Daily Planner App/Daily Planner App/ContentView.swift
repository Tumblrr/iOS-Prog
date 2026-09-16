//
//  ContentView.swift
//  Daily Planner App
//
//  Created by Nguyễn Hoàng Bảo Hân on 16/9/26.
//

import SwiftUI

// 1. Cấu trúc dữ liệu Task (Identifiable để dùng được trong ForEach)
struct Task: Identifiable {
    let id = UUID()
    var title: String
    var category: String
    var isCompleted: Bool
    var time: String
}

struct ContentView: View {
    // 2. Khai báo các biến và mảng dữ liệu với @State để UI tự cập nhật khi thay đổi
    let userName: String = "Tumblrr"
    
    @State private var tasks: [Task] = [
        Task(title: "Review Quantum Mechanics", category: "Study", isCompleted: false, time: "09:00"),
        Task(title: "Road Cycling", category: "Health", isCompleted: true, time: "17:00"),
        Task(title: "SQL Database Lab", category: "Work", isCompleted: false, time: "20:00"),
        Task(title: "Call mah fam", category: "Personal", isCompleted: false, time: "21:00")
    ]
    
    var body: some View {
        TabView {
            // --- TAB 1: TODAY PLANNER ---
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 3. HEADER (Dùng ZStack)
                    ZStack(alignment: .leading) {
                        // Nền Header (Bạn có thể thay bằng Image("ten_anh") nếu muốn)
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.green.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 180)
                        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                        .edgesIgnoringSafeArea(.top)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Good Morning,")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text(userName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Image(systemName: "sun.max.fill")
                                    .foregroundColor(.orange)
                            }
                            
                            Text("\"Discipline today\ncreates a brighter tomorrow.\"")
                                .font(.footnote)
                                .italic()
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    
                    // 4. KHỐI NGÀY THÁNG & ĐỘNG LỰC (HStack)
                    HStack(spacing: 15) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("Mon")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("16")
                                    .font(.title2)
                                    .bold()
                                Text("Sep 2026")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        VStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                            Text("New day\nNew opportunities!")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // 5. TIÊU ĐỀ DANH SÁCH & NÚT ADD TASK
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .foregroundColor(.blue)
                        Text("My Tasks")
                            .font(.title3)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            // Chức năng thêm task giả lập
                            let newTask = Task(title: "New Custom Task", category: "Work", isCompleted: false, time: "22:00")
                            tasks.append(newTask)
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Task")
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 6. DANH SÁCH CÔNG VIỆC (Dùng VStack & ForEach)
                    VStack(spacing: 12) {
                        ForEach($tasks) { $task in
                            TaskRowView(task: $task)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .tabItem {
                Image(systemName: "house.fill")
                Text("Today")
            }
            
            // --- TAB 2 & 3 ---
            Text("Stats View")
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
            
            Text("Settings View")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

// 7. COMPONENT: Dòng hiển thị từng công việc (Task Row)
struct TaskRowView: View {
    @Binding var task: Task // Dùng @Binding để nút checkmark có thể đổi trạng thái của mảng gốc
    
    var body: some View {
        HStack(spacing: 15) {
            // Nút Checkbox
            Button(action: {
                task.isCompleted.toggle()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            
            // Icon danh mục (Tự động đổi theo Category)
            Image(systemName: getIcon(for: task.category))
                .foregroundColor(getColor(for: task.category))
                .font(.title2)
                .frame(width: 30)
            
            // Thông tin task
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    // Gạch ngang chữ nếu đã hoàn thành
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .black)
                
                Text(task.category)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(getColor(for: task.category).opacity(0.15))
                    .foregroundColor(getColor(for: task.category))
                    .cornerRadius(6)
            }
            
            Spacer()
            
            // Thời gian
            Text(task.time)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
    }
    
    // Hàm phụ trợ chọn Icon
    func getIcon(for category: String) -> String {
        switch category {
        case "Study": return "book.closed.fill"
        case "Health": return "dumbbell.fill"
        case "Work": return "laptopcomputer"
        case "Personal": return "person.2.fill"
        default: return "star.fill"
        }
    }
    
    // Hàm phụ trợ chọn Màu sắc
    func getColor(for category: String) -> Color {
        switch category {
        case "Study": return .blue
        case "Health": return .pink
        case "Work": return .orange
        case "Personal": return .green
        default: return .gray
        }
    }
}

// Extension hỗ trợ bo góc tùy chọn (dùng cho Header)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// Giữ nguyên struct RoundedCorner từ bài trước
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
