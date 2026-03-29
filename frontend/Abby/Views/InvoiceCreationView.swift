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
            // Customer Details
            Section("Customer Details") {
                TextField("Customer Name", text: $controller.invoice.customer.customer_name)
                TextField("Customer Address", text: $controller.invoice.customer.customer_address)
            }

            // Supplier Details
            Section("Supplier Details") {
                TextField("Supplier Name", text: $controller.invoice.supplier.supplier_name)
                TextField("Supplier Address", text: $controller.invoice.supplier.supplier_address)
                TextField("Supplier VAT Number", text: $controller.invoice.supplier.supplier_vat_number)
                TextField("Supplier Contact (Optional)", text: Binding(
                    get: { controller.invoice.supplier.supplier_contact ?? "" },
                    set: { controller.invoice.supplier.supplier_contact = $0.isEmpty ? nil : $0 }
                ))
            }

            // Invoice Details
            Section("Invoice Details") {
                TextField("Invoice Number", text: $controller.invoice.invoice_number)
                DatePicker("Invoice Date", selection: $controller.invoice.invoice_date, displayedComponents: .date)
            }

            // Items
            Section {
                ForEach($controller.invoice.items) { $item in
                    VStack(spacing: 8) {
                        TextField("Description", text: $item.description)
                        HStack {
                            TextField("Qty", value: $item.quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 60)

                            TextField("Unit Price (£)", value: $item.unit_price, format: .currency(code: "GBP"))
                                .keyboardType(.decimalPad)

                            Spacer()

                            Text("£\(item.total_price, specifier: "%.2f")")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        Picker("VAT Rate", selection: $item.vat_rate) {
                            Text("No VAT (0%)").tag(0.0)
                            Text("Reduced (5%)").tag(5.0)
                            Text("Standard (20%)").tag(20.0)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    if controller.invoice.items.count > 1 {
                        controller.invoice.items.remove(atOffsets: offsets)
                    }
                }

                Button {
                    controller.invoice.items.append(InvoiceItem(description: "", quantity: 1, unit_price: 0, vat_rate: 20, total_price: 0))
                } label: {
                    Label("Add Item", systemImage: "plus.circle.fill")
                }
            } header: {
                Text("Items")
            }

            // Totals
            Section("Totals") {
                HStack {
                    Text("Total Amount")
                    Spacer()
                    Text("£\(controller.invoice.total_amount, specifier: "%.2f")")
                }
                HStack {
                    Text("VAT Amount")
                    Spacer()
                    Text("£\(controller.invoice.vat_amount ?? 0, specifier: "%.2f")")
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
        !controller.invoice.customer.customer_name.isEmpty &&
        !controller.invoice.supplier.supplier_name.isEmpty &&
        !controller.invoice.invoice_number.isEmpty &&
        controller.invoice.items.contains { !$0.description.isEmpty && $0.quantity > 0 && $0.unit_price > 0 }
    }
}

#Preview {
    NavigationStack {
        InvoiceCreationView()
    }
}
