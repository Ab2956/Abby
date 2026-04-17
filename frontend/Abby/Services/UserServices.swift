
import SwiftUI
import Foundation

struct UserInfoResponse: Codable {
    let email: String?
    let name: String?
    let vrn: String?
    let isConnectedToHmrc: Bool?
}

struct UpdateNameRequest: Codable {
    let name: String
}

struct UpdateVrnRequest: Codable {
    let vrn: String
}

struct UpdatePasswordRequest: Codable {
    let currentPassword: String
    let newPassword: String
}

struct MessageResponse: Codable {
    let message: String?
}

@MainActor
class UserServices: ObservableObject {

    static let shared = UserServices()

    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userVrn: String = ""
    @Published var isConnectedToHmrc: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiService: ApiServices

    init(apiService: ApiServices = .shared) {
        self.apiService = apiService
    }

    /// Fetch user profile from GET /profile
    func fetchUserProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: ProfileResponse = try await apiService.authenticatedGet(path: "/profile")
            userEmail = response.email
            isConnectedToHmrc = response.isConnectedToHmrc
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Fetch full user info from GET /getUserInfo
    func fetchUserInfo() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: UserInfoResponse = try await apiService.authenticatedGet(path: "/getUserInfo")
            userEmail = response.email ?? userEmail
            userName = response.name ?? userName
            userVrn = response.vrn ?? userVrn
            isConnectedToHmrc = response.isConnectedToHmrc ?? isConnectedToHmrc
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Update user name via POST /updateUserName
    func updateUserName(newName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let _: UserInfoResponse = try await apiService.authenticatedPost(
                path: "/updateUserName",
                body: UpdateNameRequest(name: newName)
            )
            userName = newName
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Update VRN via POST /updateVrn
    func updateVrn(newVrn: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let _: UserInfoResponse = try await apiService.authenticatedPost(
                path: "/updateVrn",
                body: UpdateVrnRequest(vrn: newVrn)
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Update password via POST /updatePassword
    func updatePassword(currentPassword: String, newPassword: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let _: MessageResponse = try await apiService.authenticatedPost(
                path: "/updatePassword",
                body: UpdatePasswordRequest(currentPassword: currentPassword, newPassword: newPassword)
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
