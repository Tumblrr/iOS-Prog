//
//  ContentView.swift
//  Delivery Service Management System
//
//  Created by Nguyễn Hoàng Bảo Hân on 26/10/26.
//
import SwiftUI
import Combine

// MARK: - ViewModel
class DeliveryViewModel: ObservableObject {
    @Published var allOrders: [DeliveryOrder] = []
    @Published var selectedFilter: String = "All"
    
    private let dataService = DeliveryDataService()
    let filters = ["All", "Standard", "Express", "Same-Day"]
    
    init() { loadSampleData() }
    
    func loadSampleData() {
        let customers = [
            (name: "Nguyen Hoang Bao Han", address: "Honas Floor 21"),
            (name: "Phan Tran Tan Dat", address: "Honas Floor 15"),
            (name: "Le Van Ly", address: "Honas Floor 26")
        ]
        
        // Bao Han - Standard
        dataService.addOrder(StandardDelivery(id: "ORD-1001", customerName: customers[0].name, deliveryAddress: customers[0].address, orderValue: 1500000, orderMonth: 10, orderYear: 2026, status: "Delivered"))
        
        // Tan Dat - Express
        dataService.addOrder(ExpressDelivery(id: "ORD-1002", customerName: customers[1].name, deliveryAddress: customers[1].address, orderValue: 850000, orderMonth: 10, orderYear: 2026, status: "Pending"))
        
        // Van Ly - Same-Day
        dataService.addOrder(SameDayDelivery(id: "ORD-1003", customerName: customers[2].name, deliveryAddress: customers[2].address, orderValue: 2200000, orderMonth: 10, orderYear: 2026, status: "Pending"))
        
        // Extra past orders
        dataService.addOrder(StandardDelivery(id: "ORD-0955", customerName: customers[0].name, deliveryAddress: customers[0].address, orderValue: 400000, orderMonth: 9, orderYear: 2026, status: "Delivered"))
        dataService.addOrder(ExpressDelivery(id: "ORD-0960", customerName: customers[2].name, deliveryAddress: customers[2].address, orderValue: 1200000, orderMonth: 9, orderYear: 2026, status: "Delivered"))

        refreshData()
    }
    
    func refreshData() {
        allOrders = dataService.getAllOrders()
    }
    
    var filteredOrders: [DeliveryOrder] {
        if selectedFilter == "All" { return allOrders }
        return allOrders.filter { order in
            if selectedFilter == "Standard" && order is StandardDelivery { return true }
            if selectedFilter == "Express" && order is ExpressDelivery { return true }
            if selectedFilter == "Same-Day" && order is SameDayDelivery { return true }
            return false
        }
    }
    
    var totalFeeRevenue: Double {
        allOrders.reduce(0) { $0 + $1.calculateDeliveryFee() }
    }
    
    func getServiceStats(for type: String) -> (count: Int, total: Double) {
        let specificOrders = allOrders.filter { order in
            if type == "Standard" { return order is StandardDelivery }
            if type == "Express" { return order is ExpressDelivery }
            if type == "Same-Day" { return order is SameDayDelivery }
            return false
        }
        return (specificOrders.count, specificOrders.reduce(0) { $0 + $1.calculateDeliveryFee() })
    }
}

// MARK: - Main View
struct ContentView: View {
    @StateObject private var viewModel = DeliveryViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. Dashboard Total Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TOTAL DELIVERY REVENUE")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(viewModel.totalFeeRevenue, specifier: "%.0f") VND")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total Orders")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(viewModel.allOrders.count)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("System Status")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Online")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(20)
                    .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // 2. Services Grid
                    Text("Delivery Methods")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        let stdStats = viewModel.getServiceStats(for: "Standard")
                        DeliveryServiceCard(icon: "box.truck", iconColor: .blue, title: "Standard", count: stdStats.count, feeTotal: stdStats.total)
                        
                        let expStats = viewModel.getServiceStats(for: "Express")
                        DeliveryServiceCard(icon: "hare.fill", iconColor: .orange, title: "Express", count: expStats.count, feeTotal: expStats.total)
                        
                        let sameStats = viewModel.getServiceStats(for: "Same-Day")
                        DeliveryServiceCard(icon: "bolt.car.fill", iconColor: .red, title: "Same-Day", count: sameStats.count, feeTotal: sameStats.total)
                    }
                    .padding(.horizontal)
                    
                    // 3. Filter & List Header
                    HStack {
                        Text("Order History")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.filters, id: \.self) { filter in
                                Text(filter)
                                    .font(.caption).bold()
                                    .padding(.horizontal, 16).padding(.vertical, 8)
                                    .background(viewModel.selectedFilter == filter ? Color.indigo : Color(UIColor.systemGray5))
                                    .foregroundColor(viewModel.selectedFilter == filter ? .white : .gray)
                                    .cornerRadius(20)
                                    .onTapGesture { withAnimation { viewModel.selectedFilter = filter } }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 4. Order List
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredOrders) { order in
                            NavigationLink(destination: OrderDetailView(order: order)) {
                                OrderRow(order: order)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Logistics")
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Detail View
struct OrderDetailView: View {
    let order: DeliveryOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Customer Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("**Name:** \(order.customerName)")
                    Text("**Address:** \(order.deliveryAddress)")
                    Text("**Order ID:** \(order.id)")
                    Text("**Order Value:** \(order.orderValue, specifier: "%.0f") VND")
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            
            GroupBox("Delivery Details") {
                VStack(alignment: .leading, spacing: 8) {
                    if order is StandardDelivery {
                        Text("**Method:** Standard Delivery")
                    } else if order is ExpressDelivery {
                        Text("**Method:** Express Delivery")
                    } else if order is SameDayDelivery {
                        Text("**Method:** Same-Day Delivery")
                    }
                    Text("**Est. Time:** \(order.getEstimatedTime())")
                    Text("**Fee:** \(order.calculateDeliveryFee(), specifier: "%.0f") VND")
                    HStack {
                        Text("**Status:**")
                        Text(order.status)
                            .font(.caption).bold()
                            .foregroundColor(order.status == "Delivered" ? .green : .orange)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(order.status == "Delivered" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                            .cornerRadius(5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Order Details")
    }
}

// MARK: - Reusable UI Components
struct DeliveryServiceCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let count: Int
    let feeTotal: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor).padding(8)
                .background(iconColor.opacity(0.2)).clipShape(Circle())
            Text(title).font(.caption).foregroundColor(.gray)
            Text("\(count) orders").font(.caption2).foregroundColor(.gray)
            Text("\(feeTotal, specifier: "%.0f") VND").font(.caption).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding().background(Color.white).cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct OrderRow: View {
    let order: DeliveryOrder
    
    var serviceDetails: (icon: String, color: Color, title: String) {
        if order is StandardDelivery { return ("box.truck", .blue, "Standard") }
        if order is ExpressDelivery { return ("hare.fill", .orange, "Express") }
        return ("bolt.car.fill", .red, "Same-Day")
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: serviceDetails.icon)
                .foregroundColor(serviceDetails.color)
                .frame(width: 40, height: 40)
                .background(serviceDetails.color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.customerName).font(.subheadline).bold()
                Text("\(serviceDetails.title) - \(order.id)")
                    .font(.caption).foregroundColor(.gray)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(order.calculateDeliveryFee(), specifier: "%.0f") đ")
                    .font(.subheadline).foregroundColor(.black)
                Text(order.status)
                    .font(.caption2).bold()
                    .foregroundColor(order.status == "Delivered" ? .green : .orange)
            }
        }
        .padding().background(Color.white).cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
