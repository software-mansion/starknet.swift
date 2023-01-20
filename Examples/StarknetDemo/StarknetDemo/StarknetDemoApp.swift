//
//  StarknetDemoApp.swift
//  StarknetDemo
//
//  Created by Bartosz Rybarski on 10/01/2023.
//

import SwiftUI
import Starknet

@main
struct StarknetDemoApp: App {
    @StateObject var accountsStore = AccountsStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accountsStore)
                .task {
                    await accountsStore.fetchBalance()
                }
        }
    }
}
