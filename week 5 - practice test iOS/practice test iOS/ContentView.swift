//
//  ContentView.swift
//  practice test iOS
//
//  Created by Nguyễn Hoàng Bảo Hân on 19/10/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = AcademicManager()
    @State private var selectedRecord: StudentRecord?
    @State private var newMarkString: String = ""
    @State private var showingEditAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Student Academic Summary")) {
                    ForEach(manager.students) { student in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(student.displayInfo())
                                .font(.headline)
                            
                            HStack {
                                Text(String(format: "Weighted Avg: %.2f", manager.calculateWeightedAverage(for: student)))
                                Spacer()
                                Text("Rank: \(manager.getAcademicRanking(for: student))")
                                    .bold()
                                    .foregroundColor(rankingColor(for: manager.getAcademicRanking(for: student)))
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("Course Records (Tap to Update Mark)")) {
                    ForEach(manager.records) { record in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(record.student.name)
                                    .font(.subheadline).bold()
                                Text("\(record.subject.name) (\(record.subject.credits) cr)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(String(format: "Mark: %.1f", record.mark))
                                    .bold()
                                Text(record.isPassed() ? "Passed" : "Failed")
                                    .font(.caption)
                                    .foregroundColor(record.isPassed() ? .green : .red)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRecord = record
                            newMarkString = "\(record.mark)"
                            showingEditAlert = true
                        }
                    }
                }
            }
            .navigationTitle("Student Management")
            .alert("Update Mark (0 - 10)", isPresented: $showingEditAlert) {
                TextField("New Mark", text: $newMarkString)
                    .keyboardType(.decimalPad)
                Button("Save") {
                    if let val = Double(newMarkString), let record = selectedRecord {
                        record.mark = val
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter new score for \(selectedRecord?.student.name ?? "") in \(selectedRecord?.subject.name ?? "")")
            }
        }
    }
    
    func rankingColor(for ranking: String) -> Color {
        switch ranking {
        case "Excellent": return .purple
        case "Good": return .blue
        case "Average": return .orange
        default: return .red
        }
    }
}

#Preview {
    ContentView()
}
