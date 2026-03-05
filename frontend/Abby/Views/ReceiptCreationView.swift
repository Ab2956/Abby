//
//  ReceiptCreationView.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI

struct ReceiptCreationView: View {
    @StateObject private var controller = ReceiptController()
    @State private var showSuccess = false

    // Local text bindings for amount fields (String ↔ Double)
    @State private var totalAmountText = ""
    @State private var vatAmountText = ""

    private let paymentMethods = ["Cash", "Card", "Bank Transfer", "Cheque", "Other"]

    private let categories = [
        "Uncategorised",
        "Office supplies",
        "Phone & internet",
        "Software & subscriptions",
        "Fuel",
        "Parking",
        "Train tickets",
        "Taxi",
        "Rent",
        "Business rates",
        "Electricity",
        "Stock",
        "Raw materials",
        "Employee wages",
        "Accountant fees",
        "Legal fees",
        "Google Ads",
        "Website costs",
        "Client entertainment",
        "Building repairs",
        "Equipment repairs",
        "Bank charges",
        "Postage",
        "Other",
    ]

    var body: some View {
        Form {
            // Transaction Type
            Section {
                Picker("Transaction Type", selection: $controller.manualReceipt.isIncome) {
                    Text("Expense").tag(false)
                    Text("Income").tag(true)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Type")
            }

            // Basic Details
            Section("Details") {
                TextField("Vendor / Paid to", text: $controller.manualReceipt.vendor)

                TextField("Description", text: $controller.manualReceipt.description)

                DatePicker("Date", selection: $controller.manualReceipt.date, displayedComponents: .date)
            }

            // Amounts
            Section("Amounts") {
                HStack {
                    Text("£")
                        .foregroundColor(.secondary)
                    TextField("Total Amount", text: $totalAmountText)
                        .keyboardType(.decimalPad)
                        .onChange(of: totalAmountText) {
                            controller.manualReceipt.totalAmount = Double(totalAmountText) ?? 0
                        }
                }

                HStack {
                    Text("£")
                        .foregroundColor(.secondary)
                    TextField("VAT Amount (0 if none)", text: $vatAmountText)
                        .keyboardType(.decimalPad)
                        .onChange(of: vatAmountText) {
                            controller.manualReceipt.vatAmount = Double(vatAmountText) ?? 0
                        }
                }

                if controller.manualReceipt.totalAmount > 0 {
                    HStack {
                        Text("Net Amount")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("£\(controller.manualReceipt.netAmount, specifier: "%.2f")")
                            .fontWeight(.medium)
                    }
                }
            }

            // Category & Payment
            Section("Classification") {
                Picker("Category", selection: $controller.manualReceipt.category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }

                Picker("Payment Method", selection: $controller.manualReceipt.paymentMethod) {
                    ForEach(paymentMethods, id: \.self) { method in
                        Text(method).tag(method)
                    }
                }
            }

            // Notes
            Section("Notes (Optional)") {
                TextEditor(text: $controller.manualReceipt.notes)
                    .frame(minHeight: 60)
            }

            // Save
            Section {
                Button {
                    Task {
                        await controller.createReceipt()
                        if controller.errorMessage == nil {
                            showSuccess = true
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        if controller.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(controller.isLoading ? "Saving..." : "Save Receipt")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(formValid ? Color.orange : Color.gray)
                .foregroundColor(.white)
                .disabled(!formValid || controller.isLoading)
            }
        }
        .navigationTitle("Create Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Receipt Saved", isPresented: $showSuccess) {
            Button("OK") {
                controller.resetCreation()
                totalAmountText = ""
                vatAmountText = ""
            }
        } message: {
            Text("Your cash receipt has been recorded successfully.")
        }
        .alert("Error", isPresented: .init(
            get: { controller.errorMessage != nil },
            set: { if !$0 { controller.errorMessage = nil } }
        )) {
            Button("OK") { }
        } message: {
            Text(controller.errorMessage ?? "")
        }
    }

    // MARK: - Computed

    private var formValid: Bool {
        !controller.manualReceipt.vendor.isEmpty && !totalAmountText.isEmpty && Double(totalAmountText) != nil
    }
}

#Preview {
    NavigationStack {
        ReceiptCreationView()
    }
}
