//
//  VatView.swift
//  AbbyIOS
//
//  Created by Adam Brows on 11/04/2026.
//
import SwiftUI

struct VatView: View{
    @StateObject private var vatController = VatController()
    
    var body: some View{
        
        VStack{
            Text("Total VAT: £\(String(vatController.totalVat))")
                .font(.largeTitle)
                .padding()
        }
        .onAppear(){
            Task{ await vatController.getVatTotal()}
        }
    
    }
}
