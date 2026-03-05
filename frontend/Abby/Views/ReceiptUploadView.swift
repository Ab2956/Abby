//
//  ReceiptUploadView.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI
import PhotosUI

struct ReceiptUploadView: View {
    @StateObject private var controller = ReceiptController()
    @State private var isShowingCamera = false

    // Local text bindings for amount fields (String ↔ Double)
    @State private var totalAmountText = ""
    @State private var vatAmountText = ""

    private let categories = [
        "Uncategorised",
        "Office supplies",
        "Phone & internet",
        "Fuel",
        "Parking",
        "Train tickets",
        "Rent",
        "Stock",
        "Accountant fees",
        "Advertising",
        "Client entertainment",
        "Equipment repairs",
        "Other",
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 48))
                        .foregroundColor(.green)

                    Text("Upload Receipt")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Take a photo or select an image of a receipt. We'll extract the details automatically.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)

                // Image Preview / Upload Options
                if let image = controller.receiptImage {
                    VStack(spacing: 12) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)

                        Button("Remove Photo") {
                            controller.resetUpload()
                            totalAmountText = ""
                            vatAmountText = ""
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                } else {
                    HStack(spacing: 16) {
                        // Camera
                        Button {
                            isShowingCamera = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                Text("Camera")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 4)
                        }
                        .buttonStyle(.plain)

                        // Photo Library
                        PhotosPicker(selection: $controller.selectedPhotoItem, matching: .images) {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                Text("Library")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }

                // Scanning indicator
                if controller.isScanning {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Extracting receipt details...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                // Extracted / Editable Fields
                if controller.receiptImage != nil {
                    VStack(spacing: 16) {
                        Text("Receipt Details")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Review and correct the details below before saving.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Group {
                            TextField("Vendor / Shop Name", text: $controller.scannedReceipt.vendor)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            DatePicker("Date", selection: $controller.scannedReceipt.date, displayedComponents: .date)
                                .padding(.horizontal, 4)

                            TextField("Total Amount (£)", text: $totalAmountText)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onChange(of: totalAmountText) {
                                    controller.scannedReceipt.totalAmount = Double(totalAmountText) ?? 0
                                }

                            TextField("VAT Amount (£)", text: $vatAmountText)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onChange(of: vatAmountText) {
                                    controller.scannedReceipt.vatAmount = Double(vatAmountText) ?? 0
                                }

                            Picker("Category", selection: $controller.scannedReceipt.category) {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .padding(.horizontal, 4)

                            TextField("Notes (optional)", text: $controller.scannedReceipt.notes)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                }

                // Save Button
                if controller.receiptImage != nil {
                    Button {
                        Task { await controller.uploadReceipt() }
                    } label: {
                        HStack {
                            if controller.isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(controller.isLoading ? "Saving..." : "Save Receipt")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!canSave)
                    .padding(.horizontal)
                }

                // Success
                if controller.successMessage != nil {
                    Label("Receipt saved successfully!", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                if let error = controller.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Upload Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: controller.selectedPhotoItem) {
            if let item = controller.selectedPhotoItem {
                Task { await controller.loadImage(from: item) }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView(image: $controller.receiptImage)
        }
    }

    // MARK: - Helpers

    private var canSave: Bool {
        controller.receiptImage != nil && !totalAmountText.isEmpty && !controller.isLoading
    }
}

// MARK: - Camera View (UIKit bridge)

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        ReceiptUploadView()
    }
}
