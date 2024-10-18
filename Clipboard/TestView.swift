//
//  TestView.swift
//  Clipboard
//
//  Created by Matija Benko on 9/2/24.
//

import SwiftUI
import StoreKit

struct TestView: View {
    // MARK: - Properties
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionManager
    
    @State private var selectedProduct: Product? = nil
    private let features: [Text] = [Text("50 copies"), Text("Color customization"), Text("Shortcut customization"), Text("Layout customization")]
    
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
            Image("CopyCat")
                .resizable()
                .scaledToFit()
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
        List(features.indices, id: \.self) { index in
            HStack(alignment: .center) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 22.5, weight: .medium))
                    .foregroundStyle(.blue)
                
                features[index]
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
                Text("a month")
                    .font(.system(size: 14.0, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    private var purchaseSection: some View {
        VStack(alignment: .center, spacing: 15) {
            purchaseButtonView
            
            Button(action: {
                Task {
                    await subscriptionsManager.restorePurchases()
                }
            }) {
                Text("Restore Purchases")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .underline()
            }
            .buttonStyle(.plain)
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
                .font(.headline)
                .padding(.horizontal, 60)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .padding(.top, 20)
    }
}
