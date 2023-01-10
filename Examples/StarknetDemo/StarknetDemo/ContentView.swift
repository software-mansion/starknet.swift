//
//  ContentView.swift
//  StarknetDemo
//
//  Created by Bartosz Rybarski on 10/01/2023.
//

import SwiftUI
import Starknet

struct ContentView: View {
    @State var balance = ""
    @State var mintAmount = ""
    
    let provider = StarknetProvider(starknetChainId: .testnet, url: "http://localhost:5050/rpc")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("My address")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("0x123456789")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Balance")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Fetching balance...", text: $balance)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(true)
                
                Button("Refetch") {
                    
                }
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Mint tokens")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Amount", text: $mintAmount)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Mint") {
                    
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
