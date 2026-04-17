//
//  MTDSubmissionsView.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI

struct MTDSubmissionsView: View {
    @StateObject private var controller = MTDController()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "percent")
                        .font(.system(size: 48))
                        .foregroundColor(.purple)

                    Text("MTD VAT Returns")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Submit your quarterly VAT returns to HMRC.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)

                if controller.isLoading {
                    ProgressView("Loading obligations…")
                        .padding()
                }

                // Quarter Cards
                if controller.obligations.isEmpty && !controller.isLoading {
                    Text("No VAT obligations found.\nMake sure your VRN is set and you are connected to HMRC.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        ForEach(Array(controller.obligations.enumerated()), id: \.element.id) { index, _ in
                            VATQuarterCard(
                                quarter: $controller.obligations[index],
                                onSubmit: {
                                    Task { await controller.submitVATReturn(index: index) }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                // Summary
                if !controller.obligations.isEmpty {
                    VStack(spacing: 12) {
                        Text("Summary")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            SummaryBox(title: "Total VAT Due", amount: controller.totalVatDue, color: .red)
                            SummaryBox(title: "VAT Reclaimed", amount: controller.totalVatReclaimed, color: .green)
                        }

                        SummaryBox(title: "Net VAT Due", amount: controller.netVatDue, color: .purple)
                    }
                    .padding(.horizontal)
                }

                if let success = controller.successMessage {
                    Label(success, systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .padding()
                }

                if let error = controller.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("VAT Returns")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await controller.loadObligations() }
        }
    }
}

// MARK: - VAT Quarter Card

struct VATQuarterCard: View {
    @Binding var quarter: VATQuarterViewModel
    let onSubmit: () -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: quarter.status.icon)
                        .foregroundColor(quarter.status.color)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quarter \(quarter.quarter)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("\(quarter.periodStart) – \(quarter.periodEnd)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(quarter.status.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(quarter.status.color)
                        Text("Due: \(quarter.deadline)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
            }
            .buttonStyle(.plain)

            // Expandable content
            if isExpanded {
                Divider()

                VStack(spacing: 12) {
                    VATField(label: "VAT Due on Sales (£)", value: $quarter.vatDueSales)
                    VATField(label: "VAT Due on Acquisitions (£)", value: $quarter.vatDueAcquisitions)
                    VATField(label: "VAT Reclaimed (£)", value: $quarter.vatReclaimedCurrPeriod)
                    VATField(label: "Total Sales ex VAT (£)", value: $quarter.totalValueSalesExVAT)
                    VATField(label: "Total Purchases ex VAT (£)", value: $quarter.totalValuePurchasesExVAT)
                    VATField(label: "Goods Supplied ex VAT (£)", value: $quarter.totalValueGoodsSuppliedExVAT)
                    VATField(label: "Total Acquisitions ex VAT (£)", value: $quarter.totalAcquisitionsExVAT)

                    Divider()

                    HStack {
                        Text("Total VAT Due")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("£\(quarter.totalVatDue, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }

                    HStack {
                        Text("Net VAT Due")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("£\(quarter.netVatDue, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }

                    // Submit button
                    Button {
                        onSubmit()
                    } label: {
                        HStack {
                            if quarter.isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(quarter.status == .submitted ? "Resubmit to HMRC" : "Submit to HMRC")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color("ButtonColour"))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(quarter.isSubmitting)
                }
                .padding()
            }
        }
        .background(Color("CardColour"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - VAT Field Helper

struct VATField: View {
    let label: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            TextField("0.00", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Summary Box

struct SummaryBox: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("£\(amount, specifier: "%.2f")")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("CardColour"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        MTDSubmissionsView()
    }
}
