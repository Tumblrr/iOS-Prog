import SwiftUI

struct ContentView: View {
    @StateObject private var system = PayrollViewModel()
    var body: some View {
        NavigationView {
            List(system.employees) { employee in
                NavigationLink(destination: EmployeeDetailView(employee: employee)) {
                    VStack(alignment: .leading) {
                        Text(employee.name).font(.headline)
                        Text("ID: \(employee.employeeID) - Pay: $\(String(format: "%.2f", employee.calculateMonthlyPay()))").font(.caption).foregroundColor(.gray)
                    }
                }
            }.navigationTitle("Payroll System")
        }
    }
}

struct EmployeeDetailView: View {
    @ObservedObject var employee: Employee
    @State private var alertMessage = ""
    @State private var showAlert = false
    var body: some View {
        VStack(spacing: 20) {
            Text(employee.name).font(.largeTitle).bold()
            Text("Employee ID: \(employee.employeeID)").foregroundColor(.secondary)
            Divider()
            
            if let ft = employee as? FullTimeEmployee {
                Text("Type: Full-Time")
                Text("Base Salary: $\(String(format: "%.2f", ft.monthlySalary))")
                Text("Bonus: $\(String(format: "%.2f", ft.bonus))")
                Button(action: { ft.addBonus(amount: 500) }) {
                    Text("Add $500 Bonus").modifier(ActionButtonStyle(color: .blue))
                }
            } else if let pt = employee as? PartTimeEmployee {
                Text("Type: Part-Time")
                Text("Hourly Rate: $\(String(format: "%.2f", pt.hourlyRate))")
                Text("Hours Worked: \(String(format: "%.1f", pt.hoursWorked)) hrs")
                Button(action: { try? pt.logHours(10) }) {
                    Text("Log 10 Hours").modifier(ActionButtonStyle(color: .blue))
                }
                Button(action: {
                    do { try pt.logHours(-5) }
                    catch { alertMessage = error.localizedDescription; showAlert = true }
                }) {
                    Text("Log -5 Hours (Invalid)").modifier(ActionButtonStyle(color: .red))
                }
            } else if let ct = employee as? ContractEmployee {
                Text("Type: Contract")
                Text("Contract Value: $\(String(format: "%.2f", ct.contractAmount))")
                Text(ct.isCompleted ? "Status: Completed ✅" : "Status: Pending ⏳")
                Button(action: { ct.markAsCompleted() }) {
                    Text("Mark as Completed").modifier(ActionButtonStyle(color: .green))
                }
            }
            
            Spacer()
            Text("Final Payable Amount:").font(.headline)
            Text("$\(String(format: "%.2f", employee.calculateMonthlyPay()))")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.green)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct ActionButtonStyle: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity).padding().background(color).foregroundColor(.white).cornerRadius(10)
    }
}
