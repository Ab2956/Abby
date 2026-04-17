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
        ZStack{
            Color("BackgroundColour")
                .ignoresSafeArea()
            
            VStack{
                Text("VAT")
                    .font(.title)
                    
                Text("Total VAT: £\(String(vatController.totalVat))")
                    .font(.largeTitle)
                    .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top)
                .cornerRadius(12)
            .onAppear(){
                Task{ await vatController.getVatTotal()}
            }
            
        }
    }
}
