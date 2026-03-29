//
//  InvoiceCreationView.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI

struct InvoiceCreationView: View {
    @StateObject private var controller = InvoiceController()
    @State private var showSuccess = false

    var body: some View {
        Form {
            // Client Details
            Section("Client Details") {
                TextField("Client Name", text: $controller.invoice.customer)
                TextField("Client Email", text: $controller.invoice.clientEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }

            // Dates
            Section("Dates") {
                DatePicker("Invoice Date", selection: $controller.invoice.invoiceDate, displayedComponents: .date)
                DatePicker("Due Date", selection: $controller.invoice.dueDate, displayedComponents: .date)
            }

            // Line Items
            Section {
                ForEach($controller.invoice.lineItems) { $item in
                    VStack(spacing: 8) {
                        TextField("Description", text: $item.description)
                        HStack {
                            TextField("Qty", value: $item.quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 60)

                            TextField("Unit Price (£)", value: $item.unitPrice, format: .currency(code: "GBP"))
                                .keyboardType(.decimalPad)

                            Spacer()

                            Text("£\(item.total, specifier: "%.2f")")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }

                        Picker("VAT Rate", selection: $item.vatRate) {
                            Text("No VAT (0%)").tag(0.0)
                            Text("Reduced (5%)").tag(5.0)
                            Text("Standard (20%)").tag(20.0)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    if controller.invoice.lineItems.count > 1 {
                        controller.invoice.lineItems.remove(atOffsets: offsets)
                    }
                }

                Button {
                    controller.invoice.lineItems.append(InvoiceItem())
                } label: {
                    Label("Add Item", systemImage: "plus.circle.fill")
                }
            } header: {
                Text("Line Items")
            }

            // Notes
            Section("Notes (Optional)") {
                TextEditor(text: $controller.invoice.notes)
                    .frame(minHeight: 60)
            }

            // Totals
            Section("Totals") {
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text("£\(controller.invoice.subtotal, specifier: "%.2f")")
                }
                HStack {
                    Text("VAT")
                    Spacer()
                    Text("£\(controller.invoice.totalVAT, specifier: "%.2f")")
                }
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text("£\(controller.invoice.grandTotal, specifier: "%.2f")")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }

            // Save Button
            Section {
                Button {
                    Task {
                        await controller.createInvoice()
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
                        Text(controller.isLoading ? "Saving..." : "Create Invoice")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(formValid ? Color.indigo : Color.gray)
                .foregroundColor(.white)
                .disabled(!formValid || controller.isLoading)
            }
        }
        .navigationTitle("Create Invoice")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Invoice Created", isPresented: $showSuccess) {
            Button("OK") { controller.resetCreation() }
        } message: {
            Text("Your invoice has been created successfully.")
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

    private var formValid: Bool {
        !controller.invoice.customer.isEmpty &&
        controller.invoice.items.contains { !$0.description.isEmpty && $0.quantity > 0 && $0.unitPrice > 0 }
    }
}

#Preview {
    NavigationStack {
        InvoiceCreationView()
    }
}
