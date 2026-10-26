//
//  ContentView.swift
//  Utility Bill Management System
//
//  Created by Nguyễn Hoàng Bảo Hân on 26/10/26.
//
import SwiftUI
import Combine

enum ViewMode { case monthly, yearly }

class BillingViewModel: ObservableObject {
    @Published var viewMode: ViewMode = .monthly
    @Published var selectedFilter: String = "All"
    
    @Published var monthlyBills: [UtilityBill] = []
    @Published var yearlySummaries: [CustomerYearSummary] = []
    
    private let dataService = BillDataService()
    let currentMonth = 10
    let currentYear = 2026
    let filters = ["All", "Electricity", "Water", "Internet"]
    
    init() { loadSampleData() }
    
    func loadSampleData() {
        let customers = [
            (name: "Nguyen Hoang Bao Han", address: "21.17"),
            (name: "Phan Tran Tan Dat", address: "15.10"),
            (name: "Le Van Ly", address: "26.10")
        ]
        
        for month in 6...9 {
            for (index, customer) in customers.enumerated() {
                let kwh = Double(140 + (index * 15) + (month * 2))
                let m3 = Double(18 + (index * 3) + month)
                
                dataService.addBill(ElectricityBill(id: "E-\(month)-0\(index + 1)", customerName: customer.name, customerAddress: customer.address, billingMonth: month, billingYear: 2026, consumptionKWh: kwh, isPaid: true))
                dataService.addBill(WaterBill(id: "W-\(month)-0\(index + 1)", customerName: customer.name, customerAddress: customer.address, billingMonth: month, billingYear: 2026, consumptionM3: m3, isPaid: true))
                dataService.addBill(InternetBill(id: "I-\(month)-0\(index + 1)", customerName: customer.name, customerAddress: customer.address, billingMonth: month, billingYear: 2026, isPaid: true))
            }
        }
        
        dataService.addBill(ElectricityBill(id: "E-10-01", customerName: customers[0].name, customerAddress: customers[0].address, billingMonth: 10, billingYear: 2026, consumptionKWh: 160, isPaid: true))
        dataService.addBill(WaterBill(id: "W-10-01", customerName: customers[0].name, customerAddress: customers[0].address, billingMonth: 10, billingYear: 2026, consumptionM3: 28, isPaid: true))
        dataService.addBill(InternetBill(id: "I-10-01", customerName: customers[0].name, customerAddress: customers[0].address, billingMonth: 10, billingYear: 2026, isPaid: true))
        
        dataService.addBill(ElectricityBill(id: "E-10-02", customerName: customers[1].name, customerAddress: customers[1].address, billingMonth: 10, billingYear: 2026, consumptionKWh: 175, isPaid: false)) // Nợ
        dataService.addBill(WaterBill(id: "W-10-02", customerName: customers[1].name, customerAddress: customers[1].address, billingMonth: 10, billingYear: 2026, consumptionM3: 31, isPaid: true)) // Đã đóng
        dataService.addBill(InternetBill(id: "I-10-02", customerName: customers[1].name, customerAddress: customers[1].address, billingMonth: 10, billingYear: 2026, isPaid: true))
        
        dataService.addBill(ElectricityBill(id: "E-10-03", customerName: customers[2].name, customerAddress: customers[2].address, billingMonth: 10, billingYear: 2026, consumptionKWh: 190, isPaid: false))
        dataService.addBill(WaterBill(id: "W-10-03", customerName: customers[2].name, customerAddress: customers[2].address, billingMonth: 10, billingYear: 2026, consumptionM3: 34, isPaid: false))
        dataService.addBill(InternetBill(id: "I-10-03", customerName: customers[2].name, customerAddress: customers[2].address, billingMonth: 10, billingYear: 2026, isPaid: false))

        refreshData()
    }
    
    func refreshData() {
        monthlyBills = dataService.getBills(forMonth: currentMonth, year: currentYear)
        yearlySummaries = dataService.getYearlySummary(forYear: currentYear)
    }
    
    var filteredMonthlyBills: [UtilityBill] {
        if selectedFilter == "All" { return monthlyBills }
        return monthlyBills.filter { bill in
            if selectedFilter == "Electricity" && bill is ElectricityBill { return true }
            if selectedFilter == "Water" && bill is WaterBill { return true }
            if selectedFilter == "Internet" && bill is InternetBill { return true }
            return false
        }
    }
    
    var dashboardTotalValue: Double {
        if viewMode == .monthly {
            return monthlyBills.reduce(0) { $0 + $1.calculateTotal() }
        } else {
            return dataService.getAllBills().reduce(0) { $0 + $1.calculateTotal() }
        }
    }
    
    var dashboardBillCount: Int {
        viewMode == .monthly ? monthlyBills.count : dataService.getAllBills().count
    }
    
    func getServiceStats(for type: String) -> (count: Int, total: Double) {
        let sourceBills = viewMode == .monthly ? monthlyBills : dataService.getAllBills()
        let specificBills = sourceBills.filter { bill in
            if type == "Electricity" { return bill is ElectricityBill }
            if type == "Water" { return bill is WaterBill }
            if type == "Internet" { return bill is InternetBill }
            return false
        }
        return (specificBills.count, specificBills.reduce(0) { $0 + $1.calculateTotal() })
    }
}

struct ContentView: View {
    @StateObject private var viewModel = BillingViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Picker("View Mode", selection: $viewModel.viewMode) {
                        Text("Monthly").tag(ViewMode.monthly)
                        Text("Yearly").tag(ViewMode.yearly)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.viewMode == .monthly ? "MONTHLY REVENUE" : "YEARLY REVENUE")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(viewModel.dashboardTotalValue, specifier: "%.0f") VND")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total bills")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(viewModel.dashboardBillCount)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Period")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(viewModel.viewMode == .monthly ? "Oct 2026" : "2026")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(20)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    Text("Services Overview")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        let elecStats = viewModel.getServiceStats(for: "Electricity")
                        ServiceCard(icon: "bolt.fill", iconColor: .orange, title: "Electricity", count: elecStats.count, total: elecStats.total)
                        
                        let waterStats = viewModel.getServiceStats(for: "Water")
                        ServiceCard(icon: "drop.fill", iconColor: .blue, title: "Water", count: waterStats.count, total: waterStats.total)
                        
                        let netStats = viewModel.getServiceStats(for: "Internet")
                        ServiceCard(icon: "wifi", iconColor: .purple, title: "Internet", count: netStats.count, total: netStats.total)
                    }
                    .padding(.horizontal)
                    
                    if viewModel.viewMode == .monthly {
                        MonthlyListView(viewModel: viewModel)
                    } else {
                        YearlyListView(viewModel: viewModel)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Dashboard")
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

struct MonthlyListView: View {
    @ObservedObject var viewModel: BillingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Bills")
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Text("+ Add Bill")
                        .font(.caption).bold().foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.blue).cornerRadius(15)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.filters, id: \.self) { filter in
                        Text(filter)
                            .font(.caption).bold()
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(viewModel.selectedFilter == filter ? Color.blue : Color(UIColor.systemGray5))
                            .foregroundColor(viewModel.selectedFilter == filter ? .white : .gray)
                            .cornerRadius(20)
                            .onTapGesture { withAnimation { viewModel.selectedFilter = filter } }
                    }
                }
                .padding(.horizontal)
            }
            
            ForEach(viewModel.filteredMonthlyBills) { bill in
                NavigationLink(destination: BillDetailView(bill: bill)) {
                    BillRow(bill: bill)
                        .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct YearlyListView: View {
    @ObservedObject var viewModel: BillingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customer Database")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(viewModel.yearlySummaries) { summary in
                NavigationLink(destination: CustomerYearDetailView(summary: summary)) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable().frame(width: 40, height: 40)
                            .foregroundColor(.blue.opacity(0.8))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(summary.customerName).font(.subheadline).bold()
                            Text("Total 2026: \(summary.totalYearAmount, specifier: "%.0f") VND")
                                .font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
                    }
                    .padding()
                    .background(Color.white).cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct CustomerYearDetailView: View {
    let summary: CustomerYearSummary
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(summary.bills.sorted(by: { $0.billingMonth > $1.billingMonth })) { bill in
                    NavigationLink(destination: BillDetailView(bill: bill)) {
                        BillRow(bill: bill)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(summary.customerName)
    }
}

struct BillDetailView: View {
    let bill: UtilityBill
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Customer Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("**Name:** \(bill.customerName)")
                    Text("**Address:** \(bill.customerAddress)")
                    Text("**Period:** \(bill.billingMonth)/\(String(bill.billingYear))")
                    HStack {
                        Text("**Status:**")
                        Text(bill.isPaid ? "PAID" : "UNPAID")
                            .font(.caption).bold()
                            .foregroundColor(bill.isPaid ? .green : .red)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(bill.isPaid ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .cornerRadius(5)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            
            GroupBox("Service Details") {
                VStack(alignment: .leading, spacing: 8) {
                    if let electricityBill = bill as? ElectricityBill {
                        Text("**Service:** Electricity")
                        Text("**Consumption:** \(electricityBill.consumptionKWh, specifier: "%.0f") kWh")
                        Text("**Rate:** 2,500 VND/kWh")
                    } else if let waterBill = bill as? WaterBill {
                        Text("**Service:** Water")
                        Text("**Consumption:** \(waterBill.consumptionM3, specifier: "%.0f") m³")
                        Text("**Rate:** 10,000 VND/m³")
                    } else if bill is InternetBill {
                        Text("**Service:** Internet")
                        Text("**Package:** Fixed Monthly")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            
            HStack {
                Text("Total Charge:")
                    .font(.title2).bold()
                Spacer()
                Text("\(bill.calculateTotal(), specifier: "%.0f") VND")
                    .font(.title2).bold().foregroundColor(.blue)
            }
            .padding().background(Color(UIColor.systemGray6)).cornerRadius(10)
        }
        .padding()
        .navigationTitle("Bill Details")
    }
}

struct ServiceCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let count: Int
    let total: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor).padding(8)
                .background(iconColor.opacity(0.2)).clipShape(Circle())
            Text(title).font(.caption).foregroundColor(.gray)
            Text("\(count) bills").font(.caption2).foregroundColor(.gray)
            Text("\(total, specifier: "%.0f") đ").font(.caption).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding().background(Color.white).cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct BillRow: View {
    let bill: UtilityBill
    
    var serviceDetails: (icon: String, color: Color, title: String) {
        if bill is ElectricityBill { return ("bolt.fill", .orange, "Electricity") }
        if bill is WaterBill { return ("drop.fill", .blue, "Water") }
        return ("wifi", .purple, "Internet")
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: serviceDetails.icon)
                .foregroundColor(serviceDetails.color)
                .frame(width: 40, height: 40)
                .background(serviceDetails.color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bill.customerName).font(.subheadline).bold()
                Text("\(serviceDetails.title) - \(bill.billingMonth)/\(String(bill.billingYear))")
                    .font(.caption).foregroundColor(.gray)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(bill.calculateTotal(), specifier: "%.0f") đ")
                    .font(.subheadline).foregroundColor(.black)
                Text(bill.isPaid ? "PAID" : "UNPAID")
                    .font(.caption2).bold()
                    .foregroundColor(bill.isPaid ? .green : .red)
            }
        }
        .padding().background(Color.white).cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
