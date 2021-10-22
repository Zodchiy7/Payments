//
//  PaymentsListView.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 21.10.2021.
//

import SwiftUI

fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct PaymentsListView: View {
    
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        VStack {
            Text("payments count \(userViewModel.payments.count)")
            List{
                ForEach(userViewModel.payments, id: \.self) { payment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(payment.desc)")
                                .lineLimit(3)
                                .font(.title)
                            HStack {
                                Text(formatter.string(from: Date(timeIntervalSince1970: TimeInterval(payment.created))))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("\(payment.amount ) \(payment.currency ?? "")")
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PaymentsListView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsListView()
            .environmentObject(UserViewModel())
    }
}
