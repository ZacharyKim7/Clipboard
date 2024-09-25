//
//  StoreVM.swift
//  Clipboard
//
//  Created by Matija Benko on 9/20/24.
//

import Foundation
import StoreKit

typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

class StoreVM: ObservableObject {
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    
    private let productIds: [String] = ["10", "com.bob.lee"]
    
    var updateListenertask : Task<Void, Error>? = nil
    
    init() {
        
        updateListenertask = listenForTransaction()
        
        Task {
            await requestProducts()
            
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenertask?.cancel()
    }
    
    func listenForTransaction() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transaction that don't come from direct call to purchase()
            for await result in Transaction.updates {
                do {
                    let transaction =  try self.checkVerified(result)
                    
                    // deliever product to user
                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            // request from the app store using the product ids (Hardcoded)
            subscriptions = try await Product.products(for: productIds)
            print(subscriptions)
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    // purchase the product
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verfication):
            // Check whether the transaction is verified. If it isn't throws error
            let transaction = try checkVerified(verfication)
            
            // Transaction is verified, deliever content to user
            await updateCustomerProductStatus()
            
            // Finish transaction
            await transaction.finish()
            
            return transaction
            
        case .userCancelled, .pending:
            return nil
            
        default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether JWS passed StoreKit vertification
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails vertifcation
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified, if it isn't catch failedVerification error
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: {$0.id == transaction.productID}) {
                        purchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
                
                // Finish transaction
                await transaction.finish()
            } catch {
                print("Failed updating product")
            }
        }
    }
    
    @MainActor
    func isUserPaid() -> Bool {
        // Check if there are any purchased subscriptions
        return !purchasedSubscriptions.isEmpty
    }
    
    public enum StoreError: Error {
        case failedVerification
    }
    
}
