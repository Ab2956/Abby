import SwiftUI

struct ReceiptsView: View {
    var body: some View {
        Text("Receipts")
            .navigationTitle("Receipts")
    }
}

#Preview {
    NavigationStack {
        ReceiptsView()
    }
}