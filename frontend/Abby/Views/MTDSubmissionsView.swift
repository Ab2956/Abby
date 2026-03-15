//
//  MTDSubmissionsView.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI

struct MTDSubmissionsView: View {
    @StateObject private var controller = MTDController()

    private let taxYears = [2024, 2025, 2026]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 48))
                        .foregroundColor(.purple)

                    Text("MTD Submissions")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Submit your quarterly income and expenses to HMRC.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)

                // Tax Year Picker
                Picker("Tax Year", selection: $controller.selectedTaxYear) {
                    ForEach(taxYears, id: \.self) { year in
                        Text("\(String(year))/\(String(year + 1 - 2000))").tag(year)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Quarter Cards
                VStack(spacing: 16) {
                    ForEach(Array(controller.quarters.enumerated()), id: \.element.id) { index, _ in
                        QuarterCard(
                            quarter: $controller.quarters[index],
                            onSubmit: {
                                Task { await controller.submitQuarter(index: index) }
                            }
                        )
                    }
                }
                .padding(.horizontal)

                // Annual Summary
                VStack(spacing: 12) {
                    Text("Annual Summary")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        SummaryBox(title: "Total Income", amount: controller.totalIncome, color: .green)
                        SummaryBox(title: "Total Expenses", amount: controller.totalExpenses, color: .red)
                    }

                    SummaryBox(title: "Net Profit", amount: controller.netProfit, color: .purple)
                }
                .padding(.horizontal)

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
        .navigationTitle("MTD Submissions")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: controller.selectedTaxYear) {
            Task { await controller.loadQuarterData() }
        }
    }
}

// MARK: - Quarter Card

struct QuarterCard: View {
    @Binding var quarter: MTDQuarterViewModel
    let onSubmit: () -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible)
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
                    // Income fields
                    HStack {
                        Text("Turnover (£)")
                            .font(.subheadline)
                        Spacer()
                        TextField("0.00", value: $quarter.turnover, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    HStack {
                        Text("Other Income (£)")
                            .font(.subheadline)
                        Spacer()
                        TextField("0.00", value: $quarter.otherIncome, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    HStack {
                        Text("Total Expenses (£)")
                            .font(.subheadline)
                        Spacer()
                        TextField("0.00", value: $quarter.totalExpenses, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Divider()

                    HStack {
                        Text("Net Profit")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("£\(quarter.netProfit, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .foregroundColor(quarter.netProfit >= 0 ? .green : .red)
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
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(quarter.isSubmitting)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        MTDSubmissionsView()
    }
}
