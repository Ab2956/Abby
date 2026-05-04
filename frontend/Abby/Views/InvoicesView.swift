import SwiftUI

struct InvoicesView: View {
    @StateObject private var service = InvoiceServices.shared
    @StateObject private var controller = InvoiceController()
    @State private var selectedInvoice: Invoice?
    @State private var showDetail = false
    
    var body: some View {
        ZStack{
            Color("BackgroundColour")
                .ignoresSafeArea()
            List(service.invoices) { invoice in
                Button(action: {
                    selectedInvoice = invoice
                    showDetail = true
                }) {
                    HStack {
                        Text(invoice.invoice_number)
                            .fontWeight(.medium)
                            .foregroundColor(Color("Text"))
                        Spacer()
                        Text(invoice.invoice_date_iso, style: .date)
                            .foregroundColor(.secondary)
                            .fontWeight(.regular)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            if let id = invoice.id {
                                await controller.deleteInvoice(invoiceId: id)
                                if controller.errorMessage == nil {
                                    service.invoices.removeAll { $0.id == id }
                                }
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Invoices").font(.headline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: InvoiceCreationView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                service.fetchAllUserInvoices { invoices, error in
                    if let invoices = invoices {
                        service.invoices = invoices
                    }
                }
            }
            .sheet(item: $selectedInvoice) { invoice in
                InvoiceDetailView(invoice: invoice)
            }
        }
    }
}

// InvoiceDetailView
struct InvoiceDetailView: View {
    let invoice: Invoice
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text(invoice.invoice_number)
                    .font(.title2)
                    .fontWeight(.bold)
                
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color("ItemColour"))
                .cornerRadius(12)
            VStack(alignment: .leading, spacing: 12) {
            Text("Date: \(invoice.invoice_date_iso, style: .date)")
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color("ItemColour"))
                .cornerRadius(12)
            Divider()
            VStack(alignment: .leading, spacing: 12) {
            Text("Client: \(invoice.customer.customer_name)")
            Text("Client Address: \(invoice.customer.customer_address)")
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color("ItemColour"))
            .cornerRadius(12)
            Divider()
            VStack(alignment: .leading, spacing: 12) {
            Text("Supplier: \(invoice.supplier.supplier_name)")
            Text("Supplier Address: \(invoice.supplier.supplier_address)")
            Text("Supplier VAT Number: \(invoice.supplier.supplier_vat_number)")
            if(((invoice.supplier.supplier_contact?.isEmpty) == nil)){
                Text("Supplier Contact: \(invoice.supplier.supplier_contact)")
            }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color("ItemColour"))
                .cornerRadius(12)
            Divider()
            VStack(alignment: .leading, spacing: 12) {
            ForEach(invoice.items) { item in
                HStack {
                    Text(item.description)
                    Spacer()
                    Text("Qty: \(item.quantity, specifier: "%.0f")")
                    Text("£\(item.unit_price, specifier: "%.2f")")
                }
            }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color("ItemColour"))
                .cornerRadius(12)
            Divider()
            VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("VAT:")
                Spacer()
                Text("£\(invoice.vat_amount ?? 0.0, specifier: "%.2f")")
            }
            HStack {
                Text("Total:")
                Spacer()
                Text("£\(invoice.total_amount, specifier: "%.2f")")
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color("ItemColour"))
            .cornerRadius(12)
            Spacer()
        }
        .padding()
    }
}

