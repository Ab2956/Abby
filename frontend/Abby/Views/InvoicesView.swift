import SwiftUI

struct InvoicesView: View {
    @StateObject private var service = InvoiceServices.shared
    @State private var selectedInvoice: Invoice?
    @State private var showDetail = false

    var body: some View {
        List(service.invoices) { invoice in
            Button(action: {
                selectedInvoice = invoice
                showDetail = true
            }) {
                HStack {
                    Text(invoice.id ?? "-")
                        .fontWeight(.medium)
                    Spacer()
                    Text(invoice.invoiceDate, style: .date)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Invoices")
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

// InvoiceDetailView
struct InvoiceDetailView: View {
    let invoice: Invoice
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invoice #\(invoice.id ?? "-")")
                .font(.title2)
                .fontWeight(.bold)
            Text("Date: \(invoice.invoiceDate, style: .date)")
            Text("Client: \(invoice.clientName)")
            Divider()
            ForEach(invoice.lineItems) { item in
                HStack {
                    Text(item.description)
                    Spacer()
                    Text("Qty: \(item.quantity, specifier: "%.0f")")
                    Text("£\(item.unitPrice, specifier: "%.2f")")
                }
            }
            Divider()
            HStack {
                Text("Subtotal:")
                Spacer()
                Text("£\(invoice.subtotal, specifier: "%.2f")")
            }
            HStack {
                Text("VAT:")
                Spacer()
                Text("£\(invoice.totalVAT, specifier: "%.2f")")
            }
            HStack {
                Text("Total:")
                Spacer()
                Text("£\(invoice.grandTotal, specifier: "%.2f")")
            }
            Spacer()
        }
        .padding()
    }
}