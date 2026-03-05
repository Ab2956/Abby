//
//  ReceiptController.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI
import PhotosUI

@MainActor
class ReceiptController: ObservableObject {

    // Published state

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Receipt list
    @Published var receipts: [Receipt] = []

    // Upload state
    @Published var receiptImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var scannedReceipt = Receipt()
    @Published var isScanning = false

    // Creation state (manual entry)
    @Published var manualReceipt = Receipt()

    var apiService: ApiServices

    init(apiService: ApiServices = .shared) {
        self.apiService = apiService
    }

    // Receipt Upload (with image)

    /// Upload a receipt image to the backend, then save with user-verified data
    func uploadReceipt() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            // If we have image data, upload as multipart
            if let image = receiptImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                let _: ReceiptResponse = try await apiService.authenticatedUpload(
                    path: "/addRecipt",
                    fileData: imageData,
                    fileName: "receipt.jpg",
                    mimeType: "image/jpeg"
                )
            } else {
                // No image, send receipt data as JSON
                let _: ReceiptResponse = try await apiService.authenticatedPost(
                    path: "/addRecipt",
                    body: scannedReceipt
                )
            }
            successMessage = "Receipt saved successfully"
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Load image from PhotosPickerItem
    func loadImage(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                receiptImage = image
                isScanning = true
                // In future: send to backend OCR endpoint and pre-fill scannedReceipt
                // For now, mark scanning complete after a moment
                try await Task.sleep(nanoseconds: 500_000_000)
                isScanning = false
            }
        } catch {
            errorMessage = "Could not load image"
        }
    }

    // Receipt Creation (manual)

    /// Save a manually created receipt to the backend
    func createReceipt() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let _: ReceiptResponse = try await apiService.authenticatedPost(
                path: "/addRecipt",
                body: manualReceipt
            )
            successMessage = "Receipt saved successfully"
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Fetch Receipts

    /// Fetch all receipts from the backend
    func fetchReceipts() async {
        isLoading = true
        errorMessage = nil

        do {
            receipts = try await apiService.authenticatedGet(path: "/getRecipts")
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Delete Receipt

    /// Delete a receipt by ID
    func deleteReceipt(id: String) async {
        errorMessage = nil

        do {
            try await apiService.authenticatedDelete(path: "/deleteRecipt/\(id)")
            receipts.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Helpers

    func resetUpload() {
        receiptImage = nil
        selectedPhotoItem = nil
        scannedReceipt = Receipt()
        isScanning = false
        errorMessage = nil
        successMessage = nil
    }

    func resetCreation() {
        manualReceipt = Receipt()
        errorMessage = nil
        successMessage = nil
    }
}
