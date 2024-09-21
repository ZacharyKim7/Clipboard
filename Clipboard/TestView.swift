//
//  TestView.swift
//  Clipboard
//
//  Created by Matija Benko on 9/2/24.
//

import SwiftUI
import StoreKit

struct TestView: View {
    @StateObject var storeVM = StoreVM()
    var body: some View {
        VStack {
            if let subscriptionGroupStatus = storeVM.subscriptionGroupStatus {
                if subscriptionGroupStatus == .expired || subscriptionGroupStatus == .revoked {
                    Text("Welcome back, give the subscription another try.")
                }
            }
            if storeVM.purchasedSubscriptions.isEmpty {
                SubscriptionView()
                
            } else {
                Text("Premium Content")
            }
        }
        .environmentObject(storeVM)
    }
}

//struct TestView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestView()
//    }
//}
