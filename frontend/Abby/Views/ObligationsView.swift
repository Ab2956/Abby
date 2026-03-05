//
//  ObligationsView.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI

struct ObligationsView: View {
    @StateObject private var controller = ObligationsController()

    // User's VRN – in production, fetch from stored user profile
    @State private var vrn = ""
    @State private var fromDate = "2025-04-06"
    @State private var toDate = "2026-04-05"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 48))
                        .foregroundColor(.red)

                    Text("Obligations")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("View your HMRC deadlines and submission obligations.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)

                // Filter
                Picker("Filter", selection: $controller.selectedFilter) {
                    ForEach(ObligationFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Summary badges
                HStack(spacing: 12) {
                    ObligationBadge(
                        count: controller.pendingCount,
                        label: "Pending",
                        color: .orange
                    )
                    ObligationBadge(
                        count: controller.overdueCount,
                        label: "Overdue",
                        color: .red
                    )
                    ObligationBadge(
                        count: controller.fulfilledCount,
                        label: "Done",
                        color: .green
                    )
                }
                .padding(.horizontal)

                // Obligation List
                if controller.isLoading {
                    ProgressView("Loading obligations...")
                        .padding()
                } else if controller.filteredObligations.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("No obligations to show")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(controller.filteredObligations) { obligation in
                            ObligationRow(obligation: obligation)
                        }
                    }
                    .padding(.horizontal)
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
        .navigationTitle("Obligations")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await controller.fetchObligations(vrn: vrn, from: fromDate, to: toDate)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            await controller.fetchObligations(vrn: vrn, from: fromDate, to: toDate)
        }
    }
}

// MARK: - Obligation Row

struct ObligationRow: View {
    let obligation: ObligationViewModel

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }

    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            Image(systemName: obligation.status.icon)
                .foregroundColor(obligation.status.color)
                .font(.title2)

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text("Quarterly Update")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(dateFormatter.string(from: obligation.periodStart)) – \(dateFormatter.string(from: obligation.periodEnd))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Text("Due:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(dateFormatter.string(from: obligation.dueDate))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(obligation.status == .overdue ? .red : .primary)
                }
            }

            Spacer()

            // Days remaining
            VStack(alignment: .trailing, spacing: 2) {
                Text(obligation.status.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(obligation.status.color)
                    .clipShape(Capsule())

                if obligation.status == .pending {
                    Text("\(obligation.daysRemaining) days left")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Badge

struct ObligationBadge: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        ObligationsView()
    }
}
