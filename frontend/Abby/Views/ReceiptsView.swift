import SwiftUI

struct ReceiptsView: View {
    @StateObject private var service = BookkeepingServices.shared
    @State private var selectedReceipt: Receipt?
    @State private var showDetail = false
    var controller = ReceiptController()
    
    
    var body: some View {
        List(service.receipts){
            recepit in Button(action: {
                selectedReceipt = recepit
                showDetail = true
            }) {
                HStack {
                    Text(recepit.description)
                        .fontWeight(.medium)
                    Spacer()
                    Text(controller.dateToString(date: recepit.date))
                        .foregroundColor(.secondary)
                }
            }
            
        }
        .navigationTitle("Receipts")
        .onAppear(){
            service.getAllUserReceipts { receipts,error in
                if let receipts = receipts {
                    service.receipts = receipts
                }
            }
            }
        .sheet(item: $selectedReceipt){
            receipt in ReceiptDetailView(receipt: receipt)
        }
    }
}
struct ReceiptDetailView: View {
    let receipt: Receipt
    @Environment(\.dismiss) private var dismiss

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: receipt.date)
    }

    private var currencyFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_GB")
        return f
    }

    private func currency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "£0.00"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Header card
                    VStack(spacing: 8) {
                        Text(receipt.vendor.isEmpty ? "Receipt" : receipt.vendor)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(currency(receipt.totalAmount))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(receipt.isIncome ? .green : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Details section
                    VStack(spacing: 0) {
                        DetailRow(label: "Category", value: receipt.category, icon: "tag.fill")
                        Divider().padding(.leading, 44)
                        DetailRow(label: "Payment", value: receipt.paymentMethod, icon: "creditcard.fill")
                        Divider().padding(.leading, 44)
                        DetailRow(label: "Type", value: receipt.isIncome ? "Income" : "Expense", icon: receipt.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Amounts breakdown
                    VStack(spacing: 0) {
                        DetailRow(label: "Subtotal", value: currency(receipt.netAmount), icon: "plusminus.circle.fill")
                        Divider().padding(.leading, 44)
                        DetailRow(label: "VAT", value: currency(receipt.vatAmount), icon: "percent")
                        Divider().padding(.leading, 44)
                        DetailRow(label: "Total", value: currency(receipt.totalAmount), icon: "sterlingsign.circle.fill")
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Description & Notes
                    if !receipt.description.isEmpty || !receipt.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            if !receipt.description.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Description")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(receipt.description)
                                        .font(.body)
                                }
                            }
                            if !receipt.notes.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(receipt.notes)
                                        .font(.body)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Receipt Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
