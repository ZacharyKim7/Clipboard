//
//  TestView.swift
//  Clipboard
//
//  Created by Matija Benko on 9/2/24.
//

import SwiftUI
import StoreKit

//struct TestView: View {
//    @StateObject var storeVM = StoreVM()
//    var body: some View {
//        VStack {
//            // what the fuck is this
//            if let subscriptionGroupStatus = storeVM.subscriptionGroupStatus {
//                if subscriptionGroupStatus == .expired || subscriptionGroupStatus == .revoked {
//                    Text("Welcome back, give the subscription another try.")
//                    //display products
//                }
//            }
//            if storeVM.purchasedSubscriptions.isEmpty {
//                SubscriptionView()
//
//            } else {
//                Text("Premium Content")
//            }
//        }
//        .environmentObject(storeVM)
//    }
//}
//
//struct TestView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestView()
//    }
//}

//
//  ContentView.swift
//  storekit-2-demo-app
//
//  Created by Aisultan Askarov on 11.01.2024.
//

struct TestView: View {
    // MARK: - Properties
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionManager
    
    @State private var selectedProduct: Product? = nil
    private let features: [String] = ["50 copies", "Color customization", "Shortcut customization", "Layout customization"]
    
    // MARK: - Layout
    var body: some View {
        Group {
            if entitlementManager.hasPro {
                HasSubscriptionView
            } else {
                subscriptionOptionsView
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .onAppear {
                        Task {
                            await subscriptionsManager.loadProducts()
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Views
    private var HasSubscriptionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "crown.fill")
                .foregroundStyle(.yellow)
                .font(Font.system(size: 100))
            
            Text("You've unlocked CopyCat Pro!")
                .font(.system(size: 30.0, weight: .bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .ignoresSafeArea(.all)
    }
    
    private var subscriptionOptionsView: some View {
        VStack(alignment: .center, spacing: 12.5) {
            if !subscriptionsManager.products.isEmpty {
//                Spacer()
                proAccessView
                featuresView
                VStack(spacing: 2.5) {
                    productsListView
                    purchaseSection
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .ignoresSafeArea(.all)
            }
        }
    }
    
    private var proAccessView: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "dollarsign.circle.fill")
                .foregroundStyle(.tint)
                .font(Font.system(size: 80))
            
            Text("Unlock CopyCat Pro")
                .font(.system(size: 33.0, weight: .bold))
//                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
            
            Text("Get access to all of our features")
                .font(.system(size: 17.0, weight: .semibold))
//                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
    }
    
    private var featuresView: some View {
        List(features, id: \.self) { feature in
            HStack(alignment: .center) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 22.5, weight: .medium))
                    .foregroundStyle(.blue)
                
                Text(feature)
                    .font(.system(size: 17.0, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.leading)
            }
            .listRowSeparator(.hidden)
            .frame(height: 35)
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .padding(.vertical, 20)
    }
    
    private var productsListView: some View {
        VStack(alignment: .leading, spacing: 8.5) {
            HStack {
                Text("Get full access for just")
                    .font(.system(size: 14.0, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.leading)

                Text(subscriptionsManager.products[0].displayPrice)
                    .font(.system(size: 14.0, weight: .bold, design: .rounded)) // Adjust the font style if needed
                    .foregroundColor(.blue) // Change this to your desired color
            }
        }
    }
    
    private var purchaseSection: some View {
        VStack(alignment: .center, spacing: 15) {
            purchaseButtonView
            
            Button("Restore Purchases") {
                Task {
                    await subscriptionsManager.restorePurchases()
                }
            }
            .font(.system(size: 14.0, weight: .regular))
            .frame(height: 15, alignment: .center)
        }
    }
    
    private var purchaseButtonView: some View {
        Button(action: {
            let product = subscriptionsManager.products[0]
            Task {
                await subscriptionsManager.buyProduct(product)
            }
        }) {
            Text("Purchase")
                .foregroundStyle(.white)
                .font(.system(size: 16.5, weight: .semibold))
                .padding(5)
        }
        .padding(.horizontal, 20)
        .frame(height: 46)
    }
}
