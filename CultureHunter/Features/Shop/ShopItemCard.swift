import SwiftUI

struct ShopItemCard: View {
    let item: ShopItem
    let onBuy: () -> Void
    
    private enum ViewMetrics {
        static let cardWidth: CGFloat = 73
        static let cardHeight: CGFloat = 98
        static let priceHeight: CGFloat = 24
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 3
        static let itemImageSize: CGFloat = 60
    }
    
    var body: some View {
        Button(action: onBuy) {
            itemCardView
        }
        .disabled(item.isOwned)
    }
    
    private var itemCardView: some View {
        ZStack(alignment: .bottom) {
            itemContainer
            priceTag
        }
        .frame(width: ViewMetrics.cardWidth, height: 108)
        .overlay(
            Group {
                if item.isOwned {
                    Image("sold_icon")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding(4)
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                        .onAppear {
                            if UIImage(named: "sold_icon") == nil {
                                print("Immagine 'sold_icon' non trovata, usa un'immagine di sistema")
                            }
                        }
                        .opacity(0.9)
                }
            }, alignment: .topTrailing
        )
    }
    
    private var itemContainer: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: ViewMetrics.cardWidth, height: ViewMetrics.cardHeight)
                .background(
                    item.isOwned
                        ? Color(red: 0.49, green: 0.49, blue: 0.49)
                        : Color(red: 0.85, green: 0.85, blue: 0.85)
                )
                .cornerRadius(ViewMetrics.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: ViewMetrics.cornerRadius)
                        .stroke(.black, lineWidth: ViewMetrics.borderWidth)
                )
            
            Image(item.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: ViewMetrics.itemImageSize, height: ViewMetrics.itemImageSize)
                .opacity(item.isOwned ? 0.8 : 1.0)
        }
    }
    
    private var priceTag: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.92))
                .frame(width: ViewMetrics.cardWidth, height: ViewMetrics.priceHeight)
                .cornerRadius(ViewMetrics.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: ViewMetrics.cornerRadius)
                        .stroke(.black, lineWidth: ViewMetrics.borderWidth)
                )
            
            if item.isOwned {
                Text("Posseduto")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
            } else {
                HStack(spacing: 4) {
                    Image("coin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                    
                    Text("\(item.price)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}
