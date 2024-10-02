import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var storeVM: StoreVM
    @State var isPurchased = false

    var body: some View {
        Group {
            if storeVM.isUserPaid() {
                Text("This user is PAID!")
            } else {
                Text("GOOFY")
            }
            Section("Upgrade to Premium") {
                ForEach(storeVM.subscriptions) { product in
                    Button(action: {
                        Task {
                            await buy(product: product)
                        }
                    }) {
                        HStack {
                            Text(product.displayPrice)
                                .font(.title2)  // Increase the font size
                                .padding(.trailing)  // Add padding between text
                            Text(product.description)
                                .font(.title3)
                        }
                        .padding()  // Increase padding around the button
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)  // Adjust width and height
                    .background(Color.blue.opacity(0.1))  // Add a background color to make it more visible
                    .cornerRadius(10)  // Add rounded corners
                }
            }
        }
        .padding()  // Add padding to the entire Group
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Make the view take as much space as possible
    }
    
    func buy(product: Product) async {
        do {
            if try await storeVM.purchase(product) != nil {
                isPurchased = true
            }
        } catch {
            print("purchase failed")
        }
    }
}

//struct SubscriptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionView().environmentObject(StoreVM())
//    }
//}
