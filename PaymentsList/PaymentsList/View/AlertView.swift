//
//  AlertView.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 26.10.2021.
//

import SwiftUI

struct AlertView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var isAlert = false
    
    var body: some View {
        Button(action: {
            clickButton()
        }, label: {
            Text("Ok")
                .foregroundColor(Color.white)
                .frame(width: 100)
        })
        .padding()
        .background(Color.blue)
        .cornerRadius(15.0)
        .alert(isPresented: $isAlert, content: {
            Alert(title: Text("Recive Data"),
                  message: Text(" Error \(userViewModel.paymentsError!.localizedDescription)"),
                  primaryButton: .default(Text("Ok"), action: {
                    clickButton()
                  }), secondaryButton: .default(Text("Dismiss")))
        
        })
        
    }

    func clickButton() {
        print("Ok click")
        userViewModel.paymentsError = nil
        self.isAlert = false
    }

}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}
