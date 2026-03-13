//
//  HomePageView.swift
//  Abby
//
//  Created by Adam Brows on 07/12/2025.
//

import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: HomeDestination
}

enum HomeDestination: Hashable {
    case invoiceUpload
    case invoiceCreation
    case receiptUpload
    case receiptCreation
    case mtdSubmissions
    case obligations
}

struct HomePageView: View {
    @ObservedObject var loginController:
    LoginController
    @State private var selectedTab = "home"

    private let menuItems: [MenuItem] = [
        MenuItem(
            title: "Upload Invoice",
            subtitle: "Scan or upload an invoice file",
            icon: "doc.viewfinder",
            color: .blue,
            destination: .invoiceUpload
        ),
        MenuItem(
            title: "Create Invoice",
            subtitle: "Create a new invoice manually",
            icon: "doc.badge.plus",
            color: .indigo,
            destination: .invoiceCreation
        ),
        MenuItem(
            title: "Upload Receipt",
            subtitle: "Scan a cash payment receipt",
            icon: "camera.viewfinder",
            color: .green,
            destination: .receiptUpload
        ),
        MenuItem(
            title: "Create Receipt",
            subtitle: "Enter a cash payment manually",
            icon: "square.and.pencil",
            color: .orange,
            destination: .receiptCreation
        ),
        MenuItem(
            title: "MTD Submissions",
            subtitle: "View and submit quarterly updates",
            icon: "chart.bar.doc.horizontal",
            color: .purple,
            destination: .mtdSubmissions
        ),
        MenuItem(
            title: "Obligations",
            subtitle: "Check HMRC deadlines and obligations",
            icon: "calendar.badge.clock",
            color: .red,
            destination: .obligations
        ),
    ]

    var body: some View {
        NavigationStack {
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 6) {

                        Text("Your Accounting Buddy")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    // Menu Grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                        ],
                        spacing: 16
                    ) {
                        ForEach(menuItems) { item in
                            NavigationLink(value: item.destination) {
                                MenuCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        loginController.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        print("settings")
                    }label:{
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .principal){
                    Image("abbyLogo")
                        .resizable()
                        .padding(30)
                        .frame(width: 250, height: 200)
                }
            }
            .toolbar{
                ToolbarItemGroup(placement: .bottomBar){
                    Button{
                        print("Invoices")
                    }
                    label:{
                        Image(systemName: "doc.text")
                    }
                    Spacer()
                    
                    Button{
                        print("Receipts")
                    }label:{
                        Image(systemName: "receipt")
                        
                    }
                    
                    Spacer()
                    Button{
                        print("House")
                    }label:{
                        Image(systemName: selectedTab == "home" ? "house.fill" : "house")
                            .foregroundColor(selectedTab == "home" ? .blue : .gray)
                    }
                    
                    Spacer()
                    Button{
                        print("VAT")
                    }
                    label:{
                        Image(systemName: "percent")
                        
                    }
                    
                    Spacer()
                    Button{
                        print("Profile")
                        
                    } label:{
                        Image(systemName: "person")
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .invoiceUpload:
                    InvoiceUploadView()
                case .invoiceCreation:
                    InvoiceCreationView()
                case .receiptUpload:
                    ReceiptUploadView()
                case .receiptCreation:
                    ReceiptCreationView()
                case .mtdSubmissions:
                    MTDSubmissionsView()
                case .obligations:
                    ObligationsView()
                }
            }
        }
    }
}

// MARK: - Menu Card

struct MenuCard: View {
    let item: MenuItem

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(item.color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(item.subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    HomePageView(loginController: LoginController())
}
