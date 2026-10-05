import SwiftUI

struct Student: Identifiable {
    var id: String
    var name: String
    var gpa: Double
}

struct ContentView: View {
    @State private var students: [Student] = [
        Student(id: "S001", name: "Anh", gpa: 8.5),
        Student(id: "S002", name: "Han", gpa: 9.0),
        Student(id: "S003", name: "Khoa", gpa: 7.8),
        Student(id: "S004", name: "Phuong", gpa: 9.2),
        Student(id: "S005", name: "Mai", gpa: 8.0)
    ]
    
    @State private var searchText: String = ""
    
    @State private var showingAddAlert = false
    @State private var showingEditAlert = false
    @State private var inputName = ""
    @State private var inputGPA = ""
    @State private var editingStudentId: String? = nil
    
    @State private var sortDescending = false
    @State private var filterGoodStudents = false
    @State private var showHighestOnly = false
    
    var processedStudents: [Student] {
        var result = students
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if filterGoodStudents {
            result = result.filter { $0.gpa >= 8.0 }
        }
        
        if showHighestOnly, let maxGPA = result.max(by: { $0.gpa < $1.gpa })?.gpa {
            result = result.filter { $0.gpa == maxGPA }
        }
        
        if sortDescending {
            result.sort { $0.gpa > $1.gpa }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Text("Student Manager")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                    Text("A better class, a brighter tomorrow")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search student by name...", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                
                List {
                    ForEach(processedStudents) { student in
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
                            
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .contentShape(Rectangle())                         .onTapGesture {
                            editingStudentId = student.id
                            inputName = student.name
                            inputGPA = String(student.gpa)
                            showingEditAlert = true
                        }
                    }
                    .onDelete(perform: deleteStudent) 
                }
                .listStyle(.plain)
                
                VStack(spacing: 12) {
                    Button(action: {
                        inputName = ""
                        inputGPA = ""
                        showingAddAlert = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Student")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Text("Total students: \(processedStudents.count)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.bottom)
            }
            .toolbar {
                Menu {
                    Toggle("Sắp xếp GPA giảm dần", isOn: $sortDescending)
                    Toggle("Chỉ hiện GPA >= 8.0", isOn: $filterGoodStudents)
                    Toggle("Tìm sinh viên GPA cao nhất", isOn: $showHighestOnly)
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title3)
                }
            }
            .alert("Add New Student", isPresented: $showingAddAlert) {
                TextField("Tên sinh viên", text: $inputName)
                TextField("Điểm GPA", text: $inputGPA)
                    .keyboardType(.decimalPad)
                
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    let newGPA = Double(inputGPA) ?? 0.0
                    let newId = UUID().uuidString
                    students.append(Student(id: newId, name: inputName, gpa: newGPA))
                }
            }
            .alert("Edit Student Info", isPresented: $showingEditAlert) {
                TextField("Tên sinh viên", text: $inputName)
                TextField("Điểm GPA", text: $inputGPA)
                    .keyboardType(.decimalPad)
                
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if let id = editingStudentId, let index = students.firstIndex(where: { $0.id == id }) {
                        students[index].name = inputName
                        students[index].gpa = Double(inputGPA) ?? students[index].gpa
                    }
                }
            }
        }
    }
    
    func deleteStudent(at offsets: IndexSet) {
        for index in offsets {
            let studentToDelete = processedStudents[index]
            students.removeAll { $0.id == studentToDelete.id }
        }
    }
}

#Preview {
    ContentView()
}
