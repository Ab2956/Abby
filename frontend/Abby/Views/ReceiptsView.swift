import SwiftUI

struct ReceiptsView: View {
    @StateObject private var service = BookkeepingServices.shared
    @State private var selectedReceipt: Receipt?
    @State private var showDetail = false
    
    var body: some View {
        Text("Receipts")
            .navigationTitle("Receipts")
        List(service.receipts){
            recepit in Button(action: {
                selectedReceipt = recepit
                showDetail = true
            }) {
                HStack {
                    Text(recepit.date)
                        .fontWeight(.medium)
                    Spacer()
                    
                }
            }
                              
        }
    }
}

#Preview {
    NavigationStack {
        ReceiptsView()
    }
}
