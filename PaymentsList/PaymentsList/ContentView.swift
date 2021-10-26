//
//  ContentView.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 21.10.2021.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        LoginView()
        
        if userViewModel.paymentsError != nil {
            Text("\(userViewModel.paymentsError!.localizedDescription)")
            AlertView()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
