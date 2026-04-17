//
//  SettingsView.swift
//  AbbyIOS
//
//  Created by Adam Brows on 15/03/2026.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var userServices = UserServices.shared
    @AppStorage("appAppearance") private var appAppearance: String = "system"

    @State private var newName: String = ""
    @State private var newVrn: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var successMessage: String?
    @State private var showPasswordSection = false

    var body: some View {
        ZStack {
            Color("BackgroundColour")
                .ignoresSafeArea()

            Form {
                // Appearance slider
                Section(header: Text("App Appearance")) {
                    Picker("Theme", selection: $appAppearance) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                // Change Name
                Section(header: Text("Change User Name")) {
                    TextField("New name", text: $newName)
                        .textContentType(.name)
                        .autocorrectionDisabled()

                    Button {
                        Task {
                            await userServices.updateUserName(newName: newName)
                            if userServices.errorMessage == nil {
                                successMessage = "Name updated"
                                newName = ""
                            }
                        }
                    } label: {
                        Text("Update Name")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty || userServices.isLoading)
                }

                // Change VRN
                Section(header: Text("Change VRN")) {
                    TextField("New VRN", text: $newVrn)
                        .keyboardType(.numberPad)

                    Button {
                        Task {
                            await userServices.updateVrn(newVrn: newVrn)
                            if userServices.errorMessage == nil {
                                successMessage = "VRN updated"
                                newVrn = ""
                            }
                        }
                    } label: {
                        Text("Update VRN")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(newVrn.trimmingCharacters(in: .whitespaces).isEmpty || userServices.isLoading)
                }

                // Change Password
                Section(header: Text("Change Password")) {
                    SecureField("Current password", text: $currentPassword)
                        .textContentType(.password)
                    SecureField("New password", text: $newPassword)
                        .textContentType(.newPassword)
                    SecureField("Confirm new password", text: $confirmPassword)
                        .textContentType(.newPassword)

                    if !confirmPassword.isEmpty && newPassword != confirmPassword {
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button {
                        Task {
                            await userServices.updatePassword(
                                currentPassword: currentPassword,
                                newPassword: newPassword
                            )
                            if userServices.errorMessage == nil {
                                successMessage = "Password updated"
                                currentPassword = ""
                                newPassword = ""
                                confirmPassword = ""
                            }
                        }
                    } label: {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(
                        currentPassword.isEmpty ||
                        newPassword.isEmpty ||
                        newPassword != confirmPassword ||
                        userServices.isLoading
                    )
                }

                // error messages
                if let success = successMessage {
                    Section {
                        Label(success, systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                if let error = userServices.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .onAppear {
            Task { await userServices.fetchUserInfo() }
            newName = userServices.userName
            newVrn = userServices.userVrn
        }
    }

}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

