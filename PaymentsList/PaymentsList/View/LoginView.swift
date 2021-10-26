//
//  LoginView.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 21.10.2021.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var userViewModel: UserViewModel
    @State var flagShowList = false
    
    var body: some View {
        Form {
          Section() {
            TextField("Username", text: $userViewModel.username)
              .autocapitalization(.none)
          }
          Section() {
            SecureField("Password", text: $userViewModel.password)
          }
          Section {
            Button(action: { userViewModel.login(showList: showList) }) {
              Text("Login")
                frame(alignment: .center)
            }.disabled(!self.userViewModel.isValid)
          }
        }
        .sheet(isPresented: $flagShowList) {
            PaymentsListView()
        }
    }
    
    func showList(_ show: Bool) {
        self.flagShowList = show
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserViewModel())
    }
}
