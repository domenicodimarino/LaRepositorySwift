//
//  ShopView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

// Modello per un articolo dello shop
struct ShopItem: Identifiable, Equatable {
    let id = UUID()
    let assetName: String
    let price: Int
    let type: ClothingType
    var isOwned: Bool
    
    // Implementazione efficiente di Equatable
    static func == (lhs: ShopItem, rhs: ShopItem) -> Bool {
        lhs.id == rhs.id
    }
    
    // Computed property per ottenere il nome visualizzabile
    var displayName: String {
        let components = assetName.components(separatedBy: " ")
        if components.count >= 3 {
            let itemType = components[2]
            let color = components.dropFirst(3).joined(separator: " ")
            return "\(itemType) \(color)"
        }
        return assetName
    }
}

// Gestore delle monete e degli acquisti
class ShopViewModel: ObservableObject {
    @Published var items: [ShopItem] = []
    
    private var avatarViewModel: AvatarViewModel
    let inventoryManager = InventoryManager.shared
    
    // Proprietà calcolate
    var coins: Int { avatarViewModel.getCoins() }
    
    // MARK: - Lifecycle
    
    init(avatarViewModel: AvatarViewModel) {
        self.avatarViewModel = avatarViewModel
        loadItems()
    }
    
    // MARK: - Item Management
    
    /// Carica tutti gli item disponibili nello shop
    func loadItems() {
        // Creazione degli array di colori per riutilizzo
        let shirtColors = ["blue", "bluegray", "brown", "charcoal", "forest", "gray",
                          "green", "lavender", "leather", "maroon", "navy", "orange",
                          "pink", "purple", "red", "rose", "sky", "slate", "tan",
                          "teal", "walnut", "yellow"]
        
        let pantsColors = shirtColors
        
        let shoesColors = ["blue", "brown", "gray", "green", "leather", "navy",
                          "pink", "red", "slate", "tan", "yellow"]
        
        // Creazione degli item con una funzione di utilità
        items = createItems(type: .shirt, style: "TShirt", colors: shirtColors) +
                createItems(type: .pants, style: "Pants", colors: pantsColors) +
                createItems(type: .shoes, style: "Basic_Shoes", colors: shoesColors)
        
        updateOwnedStatus()
    }
    
    /// Funzione helper per creare array di item con colori diversi
    private func createItems(type: ClothingType, style: String, colors: [String]) -> [ShopItem] {
        return colors.map { color in
            ShopItem(
                assetName: "\(type.assetPrefix) \(style) \(color)",
                price: 20,
                type: type,
                isOwned: false
            )
        }
    }
    
    /// Aggiorna lo stato di possesso degli item
    func updateOwnedStatus() {
        for i in items.indices {
            items[i].isOwned = inventoryManager.isItemUnlocked(ClothingItem(
                assetName: items[i].assetName,
                type: items[i].type,
                disponibile: true
            ))
        }
    }
    
    /// Tenta l'acquisto di un item
    /// - Parameter item: L'item da acquistare
    /// - Returns: `true` se l'acquisto ha avuto successo, `false` altrimenti
    func buyItem(_ item: ShopItem) -> Bool {
        // Verifica se l'utente possiede già l'item
        if item.isOwned {
            return false
        }
        
        // Prova a spendere le monete
        if !avatarViewModel.spendCoins(item.price) {
            return false
        }
        
        // Sblocca l'item nell'inventario
        inventoryManager.unlockItem(withAssetName: item.assetName)
        
        // Aggiorna lo stato dell'item
        if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index].isOwned = true
            }
        
        return true
    }
    
    /// Restituisce gli item filtrati per tipo
    /// - Parameter type: Il tipo di item da filtrare
    /// - Returns: Array di item del tipo specificato
    func items(ofType type: ClothingType) -> [ShopItem] {
        return items.filter { $0.type == type }
    }
}

struct ShopView: View {
    // MARK: - Properties
    @ObservedObject var avatarViewModel: AvatarViewModel
    @StateObject private var shopViewModel: ShopViewModel
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedItem: ShopItem? = nil
    
    // MARK: - Initialization
    
    init(avatarViewModel: AvatarViewModel) {
        self.avatarViewModel = avatarViewModel
        _shopViewModel = StateObject(wrappedValue: ShopViewModel(avatarViewModel: avatarViewModel))
    }
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                avatarAndInfoSection
                shopSections
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Shop"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            shopViewModel.updateOwnedStatus()
        }
        .onChange(of: avatarViewModel.avatar.coins) { _ in
            // Quando le monete cambiano (dopo un acquisto), aggiorna lo stato degli item
            shopViewModel.updateOwnedStatus()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        Text("Shop")
            .font(.largeTitle)
            .fontWeight(.bold)
            .kerning(0.4)
            .multilineTextAlignment(.center)
            .foregroundColor(.primary)
            .padding(.top)
    }
    
    private var avatarAndInfoSection: some View {
        HStack {
            avatarPreview
            VStack {
                coinDisplay
                weeklyMissionDisplay
            }
        }
    }
    
    private var avatarPreview: some View {
        ZStack(alignment: .bottom) {
            Image("shop")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 131, height: 186)
                .clipped()
                .cornerRadius(16)
            AvatarSpriteKitView(viewModel: avatarViewModel)
                .frame(width: 128, height: 128)
        }
    }
    
    private var coinDisplay: some View {
        HStack {
            Text("Le tue monete: ")
                .font(.body)
                .fontWeight(.semibold)
            Image("coin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 19, height: 15)
                .clipped()
            Text("\(shopViewModel.coins)")
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var weeklyMissionDisplay: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 213, height: 111)
                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                .cornerRadius(21)
                .overlay(
                    RoundedRectangle(cornerRadius: 21)
                        .inset(by: 2.5)
                        .stroke(.black, lineWidth: 5)
                )
            
            VStack {
                Text("Missione settimanale")
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
                
                HStack(spacing: 10) {
                    Image("shirt_mission")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Text("Visita \"Stadio Arechi\" per")
                            .font(.caption)
                        Text("ottenere una maglietta esclusiva")
                            .font(.caption)
                    }
                }
            }
        }
        .frame(width: 213, height: 111)
    }
    
    private var shopSections: some View {
        VStack(spacing: 20) {
            shopSection(title: "Magliette", type: .shirt)
            shopSection(title: "Pantaloni", type: .pants)
            shopSection(title: "Scarpe", type: .shoes)
        }
    }
    
    private func shopSection(title: String, type: ClothingType) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(shopViewModel.items(ofType: type)) { item in
                        ShopItemCard(
                            item: item,
                            onBuy: {
                                selectedItem = item
                                buySelectedItem()
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Actions
    
    private func buySelectedItem() {
        guard let item = selectedItem else { return }
        
        // Verifica DIRETTAMENTE con l'InventoryManager invece di usare il flag locale
        let clothingItem = ClothingItem(
            assetName: item.assetName,
            type: item.type,
            disponibile: true
        )
        
        if shopViewModel.inventoryManager.isItemUnlocked(clothingItem) {
            alertMessage = "Possiedi già questo articolo"
            showAlert = true
            return
        }
        
        if shopViewModel.coins < item.price {
            alertMessage = "Non hai abbastanza monete"
            showAlert = true
            return
        }
        
        if shopViewModel.buyItem(item) {
            // Forza l'aggiornamento dello stato subito dopo l'acquisto
            shopViewModel.updateOwnedStatus()
            alertMessage = "Acquisto completato! Puoi indossare questo articolo dall'inventario"
            showAlert = true
        } else {
            alertMessage = "Errore durante l'acquisto"
            showAlert = true
        }
    }
}

// Card per visualizzare un articolo dello shop
struct ShopItemCard: View {
    // MARK: - Properties
    let item: ShopItem
    let onBuy: () -> Void
    
    // MARK: - Constants
    private enum ViewMetrics {
        static let cardWidth: CGFloat = 73
        static let cardHeight: CGFloat = 98
        static let priceHeight: CGFloat = 24
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 3
        static let itemImageSize: CGFloat = 60
    }
    
    // MARK: - View
    
    var body: some View {
        Button(action: onBuy) {
            itemCardView
        }
    }
    
    private var itemCardView: some View {
        ZStack(alignment: .bottom) {
            itemContainer
            priceTag
        }
        .frame(width: ViewMetrics.cardWidth, height: 108)
    }
    
    private var itemContainer: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray.opacity(0.2))
                .frame(width: ViewMetrics.cardWidth, height: ViewMetrics.cardHeight)
                .cornerRadius(ViewMetrics.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: ViewMetrics.cornerRadius)
                        .stroke(.black, lineWidth: ViewMetrics.borderWidth)
                )
            
            Image(item.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: ViewMetrics.itemImageSize, height: ViewMetrics.itemImageSize)
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

#Preview {
    ShopView(avatarViewModel: AvatarViewModel())
}
