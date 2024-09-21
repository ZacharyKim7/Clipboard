import StoreKit

class InAppPurchaseManager: NSObject, SKProductsRequestDelegate {
    var products: [SKProduct] = []
    
    func fetchProducts(productIdentifiers: Set<String>) {
        print("yo")
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        print("did this even run")
        for product in products {
            print("Product Identifier: \(product.productIdentifier)")
            print("Product Title: \(product.localizedTitle)")
            print("Product Price: \(product.localizedPrice ?? "N/A")")
            print("Product Description: \(product.localizedDescription)")
            print("---------------")
        }
        
        // Handle invalid products
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid Product Identifier: \(invalidIdentifier)")
        }
    }
}

extension SKProduct {
    var localizedPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

// Usage

