//
//  PaymentsListApp.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 21.10.2021.
//

import SwiftUI

@main
struct PaymentsListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserViewModel())
        }
    }
}
