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
    
    static func == (lhs: ShopItem, rhs: ShopItem) -> Bool {
        lhs.id == rhs.id
    }
}

// Gestore delle monete e degli acquisti
class ShopViewModel: ObservableObject {
    @Published var items: [ShopItem] = []
    
    private var avatarViewModel: AvatarViewModel
    
    let inventoryManager = InventoryManager.shared
    
    var coins: Int {
        get { avatarViewModel.getCoins() }
    }
    
    init(avatarViewModel: AvatarViewModel) {
            self.avatarViewModel = avatarViewModel
            loadItems()
        }
    
    func loadItems() {
        // Magliette disponibili nello shop
        items = [
            // Magliette
            
            
            ShopItem(assetName: "035 clothes TShirt blue", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt bluegray", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt brown", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt charcoal", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt forest", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt gray", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt green", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt lavender", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt leather", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt maroon", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt navy", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt orange", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt pink", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt purple", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt red", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt rose", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt sky", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt slate", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt tan", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt teal", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt walnut", price: 20, type: .shirt, isOwned: false),
            ShopItem(assetName: "035 clothes TShirt yellow", price: 20, type: .shirt, isOwned: false),
            
            // Pantaloni
            
            /*
             ["blue", "bluegray", "brown",
                               "charcoal", "forest", "gray", "green", "lavender",
                               "leather", "maroon", "navy", "orange", "pink",
                               "purple", "red", "rose", "sky", "slate",
                               "tan", "teal", "walnut", "yellow"]
             */
            ShopItem(assetName: "020 legs Pants blue", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants bluegray", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants brown", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants forest", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants gray", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants green", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants lavender", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants leather", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants maroon", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants navy", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants orange", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants pink", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants purple", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants red", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants rose", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants sky", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants slate", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants tan", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants teal", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants walnut", price: 20, type: .pants, isOwned: false),
            ShopItem(assetName: "020 legs Pants yellow", price: 20, type: .pants, isOwned: false),
            
            
            // Scarpe
            /*
             black blue brown gray green leather navy pink red slate tan white yellow
             */
            ShopItem(assetName: "015 shoes Basic_Shoes blue", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes brown", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes gray", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes green", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes leather", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes navy", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes pink", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes red", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes slate", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes tan", price: 20, type: .shoes, isOwned: false),
            ShopItem(assetName: "015 shoes Basic_Shoes yellow", price: 20, type: .shoes, isOwned: false),
            
        ]
        
        // Aggiorna lo stato di possesso
        updateOwnedStatus()
    }
    
    func updateOwnedStatus() {
        // Controlla quali item sono già posseduti
        for i in 0..<items.count {
            items[i].isOwned = inventoryManager.isItemUnlocked(ClothingItem(
                assetName: items[i].assetName,
                type: items[i].type,
                disponibile: true
            ))
        }
    }
    
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
    
    // Ottieni items filtrati per tipo
    func items(ofType type: ClothingType) -> [ShopItem] {
        return items.filter { $0.type == type }
    }
}

struct ShopView: View {
    @ObservedObject var avatarViewModel: AvatarViewModel
        @StateObject private var shopViewModel: ShopViewModel
        
        @State private var showAlert = false
        @State private var alertMessage = ""
        @State private var selectedItem: ShopItem? = nil
        
        // Un solo initializzatore che accetta il viewModel da fuori
        init(avatarViewModel: AvatarViewModel) {
            self.avatarViewModel = avatarViewModel
            _shopViewModel = StateObject(wrappedValue: ShopViewModel(avatarViewModel: avatarViewModel))
        }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Shop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .kerning(0.4)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.top)
                
                // Avatar, monete e missione settimanale
                HStack {
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
                    VStack {
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
                                    Image("shirt_mission") // Immagine della maglietta esclusiva
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
                }
                
                // Sezione Magliette
                VStack(alignment: .leading) {
                    Text("Magliette")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(shopViewModel.items(ofType: .shirt)) { item in
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
                
                // Sezione Pantaloni
                VStack(alignment: .leading) {
                    Text("Pantaloni")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(shopViewModel.items(ofType: .pants)) { item in
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
                
                // Sezione Scarpe
                VStack(alignment: .leading) {
                    Text("Scarpe")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(shopViewModel.items(ofType: .shoes)) { item in
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
            // Aggiorna lo stato degli item posseduti quando la vista appare
            shopViewModel.updateOwnedStatus()
        }
    }
    
    // Funzione per gestire l'acquisto
    private func buySelectedItem() {
        guard let item = selectedItem else { return }
        
        if item.isOwned {
            // Se l'item è già posseduto, mostra un alert
            alertMessage = "Possiedi già questo articolo"
            showAlert = true
        } else if shopViewModel.coins < item.price {
            // Se non ci sono abbastanza monete, mostra un alert
            alertMessage = "Non hai abbastanza monete"
            showAlert = true
        } else {
            // Tenta l'acquisto
            if shopViewModel.buyItem(item) {
                alertMessage = "Acquisto completato! Puoi indossare questo articolo dall'inventario"
                showAlert = true
            } else {
                alertMessage = "Errore durante l'acquisto"
                showAlert = true
            }
        }
    }
}

// Card per visualizzare un articolo dello shop
struct ShopItemCard: View {
    let item: ShopItem
    let onBuy: () -> Void
    
    var body: some View {
        // Uso uno ZStack per sovrapporre gli elementi
        ZStack(alignment: .bottom) {
            // Contenitore dell'immagine dell'articolo
            ZStack {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: 73, height: 98)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 3)
                    )
                
                Image(item.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            
            // Prezzo o stato dell'articolo - sovrapposto al fondo dell'immagine
            ZStack {
                Rectangle()
                    .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.92))
                    .frame(width: 73, height: 24)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16)

                        .stroke(.black, lineWidth: 3))
                
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
            // Spostamento verso l'alto per sovrapporre il prezzo al bordo inferiore dell'immagine
            //.offset()
        }
        .frame(width: 73, height: 108) // Aggiustiamo l'altezza per tenere conto del prezzo sovrapposto
        .onTapGesture {
            onBuy()
        }
    }
}

#Preview {
    ShopView(avatarViewModel: AvatarViewModel())
}
