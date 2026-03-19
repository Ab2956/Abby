import SwiftUI  

struct InvoicesView: View {  
    var body: some View {  
        Text("Invoices")  
            .navigationTitle("Invoices")  
    }  
}

#Preview {
    NavigationStack {
        InvoicesView()
    }
}