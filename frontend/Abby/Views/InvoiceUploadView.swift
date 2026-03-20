//
//  InvoiceUploadView.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI
import PhotosUI

struct InvoiceUploadView: View {
    @StateObject private var controller = InvoiceController()
    @State private var isShowingFilePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)

                    Text("Upload Invoice")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Upload a photo or PDF of an invoice to extract its details automatically.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)

                // Upload Options
                VStack(spacing: 16) {
                    PhotosPicker(selection: $controller.selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text("Choose from Photos")
                                    .fontWeight(.medium)
                                Text("Select an invoice image from your library")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)

                    Button {
                        isShowingFilePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text("Choose File")
                                    .fontWeight(.medium)
                                Text("Upload a PDF or image file")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                // Selected file info
                if let url = controller.selectedFileURL {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(url.lastPathComponent)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button {
                            controller.resetUpload()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }

                // Upload Button
                Button {
                    Task {
                        if let item = controller.selectedPhotoItem {
                            await controller.uploadFromPhotoPicker(item)
                        } else if controller.selectedFileData != nil {
                            await controller.uploadSelectedFile()
                        }
                    }
                } label: {
                    HStack {
                        if controller.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(controller.isLoading ? "Uploading..." : "Upload Invoice")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canUpload ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canUpload)
                .padding(.horizontal)

                // Success
                if let success = controller.successMessage {
                    Label(success, systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .padding()
                }

                // Error
                if let error = controller.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Upload Invoice")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $isShowingFilePicker,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    controller.loadFileFromURL(url)
                }
            case .failure(let error):
                controller.errorMessage = error.localizedDescription
            }
        }
        .onChange(of: controller.selectedPhotoItem) {
            if controller.selectedPhotoItem != nil {
                controller.selectedFileURL = URL(string: "photo://selected-image")
            }
        }
    }

    private var canUpload: Bool {
        (controller.selectedFileURL != nil || controller.selectedPhotoItem != nil) && !controller.isLoading
    }
}

#Preview {
    NavigationStack {
        InvoiceUploadView()
    }
}

#Preview {
    NavigationStack {
        InvoiceUploadView()
    }
}
