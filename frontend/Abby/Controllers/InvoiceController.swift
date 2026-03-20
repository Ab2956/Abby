//
//  InvoiceController.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI
import PhotosUI

@MainActor
class InvoiceController: ObservableObject {

    // Published state

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Upload state
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedFileURL: URL?
    @Published var selectedFileData: Data?
    @Published var selectedFileName: String?
    @Published var selectedFileMimeType: String?
    @Published var uploadedInvoice: Bool = false

    // Creation state
    @Published var invoice = Invoice()

    var apiService: ApiServices

    init(apiService: ApiServices = .shared) {
        self.apiService = apiService
    }

    // Invoice Upload

    /// Upload an invoice image or PDF to the backend for OCR parsing
    func uploadInvoice(fileData: Data, fileName: String, mimeType: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let response: InvoiceUploadResponse = try await apiService.authenticatedUpload(
                path: "/uploadInvoice",
                fileData: fileData,
                fileName: fileName,
                mimeType: mimeType
            )
            uploadedInvoice = response.success ?? true
            successMessage = response.message ?? "Invoice uploaded successfully"
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Load image data from a PhotosPickerItem and upload it
    func uploadFromPhotoPicker(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "Could not load image data"
                return
            }
            await uploadInvoice(fileData: data, fileName: "invoice.jpg", mimeType: "image/jpeg")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Read file data immediately 
    func loadFileFromURL(_ url: URL) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        var coordinatorError: NSError?
        var loadError: Error?

        NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &coordinatorError) { coordinatedURL in
            do {
                let data = try Data(contentsOf: coordinatedURL)
                self.selectedFileData = data
                self.selectedFileName = coordinatedURL.lastPathComponent
                self.selectedFileMimeType = coordinatedURL.pathExtension.lowercased() == "pdf" ? "application/pdf" : "image/jpeg"
                self.selectedFileURL = url
            } catch {
                loadError = error
            }
        }

        if let error = coordinatorError ?? loadError {
            print("File load error: \(error) for URL: \(url)")
            errorMessage = error.localizedDescription
        }
    }

    /// Upload previously loaded file data
    func uploadSelectedFile() async {
        guard let data = selectedFileData, let name = selectedFileName, let mime = selectedFileMimeType else {
            errorMessage = "No file selected"
            return
        }
        await uploadInvoice(fileData: data, fileName: name, mimeType: mime)
    }

    // Invoice Creation

    /// Create a new invoice by sending it to the backend
    func createInvoice() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let _: ReceiptResponse = try await apiService.authenticatedPost(
                path: "/uploadInvoice",
                body: invoice
            )
            successMessage = "Invoice created successfully"
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Helpers

    func resetUpload() {
        selectedPhotoItem = nil
        selectedFileURL = nil
        selectedFileData = nil
        selectedFileName = nil
        selectedFileMimeType = nil
        uploadedInvoice = false
        errorMessage = nil
        successMessage = nil
    }

    func resetCreation() {
        invoice = Invoice()
        errorMessage = nil
        successMessage = nil
    }
}
