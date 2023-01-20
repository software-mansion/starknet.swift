//
//  ContentView.swift
//  StarknetDemo
//
//  Created by Bartosz Rybarski on 10/01/2023.
//

import SwiftUI
import Starknet


struct ContentView: View {
    @EnvironmentObject var accountsStore: AccountsStore
    
    @State var transferAmount = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("What is your account?", selection: $accountsStore.currentAccountIndex) {
                ForEach(accountsStore.accounts.indices, id: \.self) {
                    Text(accountsStore.accounts[$0].address.toHex().prefix(8) + "...")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Balance")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(String(accountsStore.balance, radix: 10))
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Transfer tokens")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Amount...", text: $transferAmount)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Send") {
                    accountsStore.transferTokens(amountString: transferAmount)
                }
                .disabled(accountsStore.loading)
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
