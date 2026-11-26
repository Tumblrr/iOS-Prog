//
//  Views.swift
//  Library System
//
//  Created by Nguyễn Hoàng Bảo Hân on 9/11/26.
//

import SwiftUI

struct EquipmentRow: View {
    @ObservedObject var item: Equipment

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name).font(.headline)
                Text(getCategory(for: item) + " - " + item.manufacturer)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(item.isAvailable ? "Available" : "On Loan")
                .foregroundColor(item.isAvailable ? .green : .red)
                .font(.caption)
        }
    }

    private func getCategory(for item: Equipment) -> String {
        if item is Laptop { return "Laptop" }
        if item is Tablet { return "Tablet" }
        if item is DigitalCamera { return "Camera" }
        return "Equipment"
    }
}

struct EquipmentListView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var showingAddScreen = false

    var body: some View {
        NavigationStack {
            List(viewModel.equipmentList) { item in
                NavigationLink(destination: EquipmentDetailView(equipment: item, viewModel: viewModel)) {
                    EquipmentRow(item: item)
                }
            }
            .navigationTitle("Library Equipment")
            .toolbar {
                Button(action: { showingAddScreen = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddScreen) {
                EquipmentManagementView(viewModel: viewModel, mode: .add)
            }
        }
    }
}

struct EquipmentDetailView: View {
    @ObservedObject var equipment: Equipment
    @ObservedObject var viewModel: LibraryViewModel

    @State private var showingEditScreen = false
    @State private var showingBorrowSheet = false
    @State private var borrowerName = ""
    @State private var expectedReturn = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    @State private var alertMessage = ""
    @State private var showingAlert = false

    @State private var borrowError = ""
    @State private var showingBorrowError = false

    var body: some View {
        Form {
            Section(header: Text("General Information")) {
                LabeledContent("ID", value: equipment.id)
                LabeledContent("Name", value: equipment.name)
                LabeledContent("Manufacturer", value: equipment.manufacturer)
                LabeledContent("Purchase Year", value: "\(equipment.purchaseYear)")
                LabeledContent("Status", value: equipment.isAvailable ? "Available" : "On Loan")
            }

            if let laptop = equipment as? Laptop {
                Section(header: Text("Laptop Specifications")) {
                    LabeledContent("Processor", value: laptop.processor)
                    LabeledContent("Memory", value: "\(laptop.memoryGB) GB")
                    LabeledContent("Storage", value: "\(laptop.storageGB) GB")
                }
            } else if let tablet = equipment as? Tablet {
                Section(header: Text("Tablet Specifications")) {
                    LabeledContent("Screen Size", value: String(format: "%.1f\"", tablet.screenSize))
                    LabeledContent("Battery", value: "\(tablet.batteryCapacity) mAh")
                    LabeledContent("Digital Pen", value: tablet.supportsDigitalPen ? "Supported" : "No")
                }
            } else if let camera = equipment as? DigitalCamera {
                Section(header: Text("Camera Specifications")) {
                    LabeledContent("Resolution", value: "\(String(format: "%.1f", camera.sensorResolutionMP)) MP")
                    LabeledContent("Lens Type", value: camera.lensType)
                    LabeledContent("Video", value: camera.supportsVideo ? "Supported" : "No")
                }
            }

            if !equipment.isAvailable {
                Section(header: Text("Borrowing Info")) {
                    LabeledContent("Borrower", value: equipment.currentBorrower ?? "")
                    if let bDate = equipment.borrowDate {
                        LabeledContent("Borrow Date", value: bDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let rDate = equipment.expectedReturnDate {
                        LabeledContent("Expected Return", value: rDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }

            Section {
                if equipment.isAvailable {
                    Button("Borrow Equipment") {
                        showingBorrowSheet = true
                    }
                    .foregroundColor(.blue)
                } else {
                    Button("Return Equipment") {
                        handleReturn()
                    }
                    .foregroundColor(.red)
                }

                Button("Edit Information") {
                    showingEditScreen = true
                }
            }
        }
        .navigationTitle(equipment.name)
        .sheet(isPresented: $showingBorrowSheet) {
            NavigationStack {
                Form {
                    TextField("Borrower Name", text: $borrowerName)
                    LabeledContent("Borrow Date", value: Date().formatted(date: .abbreviated, time: .omitted))
                    DatePicker("Expected Return", selection: $expectedReturn, in: Date()..., displayedComponents: .date)
                }
                .navigationTitle("Borrow Equipment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingBorrowSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm") { handleBorrow() }
                    }
                }
                .alert("Notice", isPresented: $showingBorrowError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(borrowError)
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Notice", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingEditScreen) {
            EquipmentManagementView(viewModel: viewModel, mode: .edit(equipment))
        }
    }

    private func handleBorrow() {
        do {
            try viewModel.borrowEquipment(equipment, borrower: borrowerName, borrowDate: Date(), expectedReturn: expectedReturn)
            showingBorrowSheet = false
            borrowerName = ""
            showAlert("Equipment borrowed successfully!")
        } catch {
            borrowError = error.localizedDescription
            showingBorrowError = true
        }
    }

    private func handleReturn() {
        do {
            try viewModel.returnEquipment(equipment)
            showAlert("Equipment returned successfully!")
        } catch {
            showAlert(error.localizedDescription)
        }
    }

    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

enum ManagementMode {
    case add
    case edit(Equipment)
}

struct EquipmentManagementView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LibraryViewModel
    let mode: ManagementMode

    @State private var form: EquipmentForm
    @State private var alertMessage = ""
    @State private var showingAlert = false

    init(viewModel: LibraryViewModel, mode: ManagementMode) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.mode = mode
        if case .edit(let item) = mode {
            _form = State(initialValue: EquipmentForm(item: item))
        } else {
            _form = State(initialValue: EquipmentForm())
        }
    }

    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Equipment Type")) {
                    Picker("Type", selection: $form.type) {
                        ForEach(EquipmentType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(isEditMode)
                }

                Section(header: Text("General Info")) {
                    field("ID", "e.g. L02", $form.id, locked: isEditMode)
                    field("Name", "e.g. MacBook", $form.name)
                    field("Manufacturer", "e.g. Apple", $form.manufacturer)
                    field("Year", "e.g. 2024", $form.purchaseYear, keyboard: .numberPad, locked: isEditMode)
                }

                Section(header: Text("Specific Info")) {
                    switch form.type {
                    case .laptop:
                        field("Processor", "e.g. M2", $form.processor)
                        field("Memory (GB)", "e.g. 16", $form.memory, keyboard: .numberPad)
                        field("Storage (GB)", "e.g. 512", $form.storage, keyboard: .numberPad)
                    case .tablet:
                        field("Screen (\")", "e.g. 10.9", $form.screenSize, keyboard: .decimalPad)
                        field("Battery (mAh)", "e.g. 7600", $form.battery, keyboard: .numberPad)
                        Toggle("Supports Digital Pen", isOn: $form.hasPen)
                    case .camera:
                        field("Resolution (MP)", "e.g. 33.0", $form.resolution, keyboard: .decimalPad)
                        field("Lens Type", "e.g. FE 24-70mm", $form.lens)
                        Toggle("Supports Video", isOn: $form.video)
                    }
                }
            }
            .navigationTitle(isEditMode ? "Edit Equipment" : "Register")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .alert("Notice", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func field(_ title: String, _ placeholder: String, _ text: Binding<String>,
                       keyboard: UIKeyboardType = .default, locked: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
        }
        .disabled(locked)
        .foregroundColor(locked ? .gray : .primary)
    }

    private func save() {
        do {
            if case .edit(let item) = mode {
                try viewModel.update(item, with: form)
            } else {
                try viewModel.register(form: form)
            }
            dismiss()
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}
