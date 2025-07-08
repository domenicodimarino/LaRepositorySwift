//
//  ShopView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

struct ShopView: View {
    // MARK: - Properties
    @ObservedObject var avatarViewModel: AvatarViewModel
    @StateObject private var shopViewModel: ShopViewModel
    
    @State private var showAlert = false
    @State private var showConfirmation = false
    @State private var showWearConfirmation = false
    @State private var alertMessage = ""
    @State private var selectedItem: ShopItem? = nil
    @State private var justPurchasedItem: ShopItem? = nil
    
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
        // Alert di conferma (prima dell'acquisto)
                .alert("Conferma acquisto", isPresented: $showConfirmation) {
                    Button("No", role: .cancel) {
                        // Non fa nulla, chiude solo l'alert
                    }
                    Button("Sì") {
                        // Procede con l'acquisto quando l'utente conferma
                        proceedWithPurchase()
                    }
                } message: {
                    if let item = selectedItem {
                        Text("Vuoi acquistare \(item.displayName) per \(item.price) monete?")
                    } else {
                        Text("Vuoi acquistare questo articolo?")
                    }
                }
        // Nuovo alert per indossare l'articolo
                .alert("Indossare articolo", isPresented: $showWearConfirmation) {
                    Button("No", role: .cancel) {
                        // Non fa nulla, l'utente può andare all'inventario in seguito
                        alertMessage = "Puoi indossarlo dall'inventario quando vuoi."
                        showAlert = true
                    }
                    Button("Sì") {
                        wearItem()
                    }
                }message: {
                    if let item = justPurchasedItem {
                        Text("Articolo acquistato! Vuoi indossare subito \(item.displayName)?")
                    } else {
                        Text("Articolo acquistato! Vuoi indossarlo subito?")
                    }
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
                    // Ordina gli elementi: prima quelli non posseduti, poi quelli posseduti
                    ForEach(shopViewModel.items(ofType: type).sorted { !$0.isOwned && $1.isOwned }) { item in
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
            
            // Verifica con l'InventoryManager
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
            
            showConfirmation = true
        }
        
        private func proceedWithPurchase() {
            guard let item = selectedItem else { return }
            
            if shopViewModel.buyItem(item) {
                // Forza l'aggiornamento dello stato
                shopViewModel.updateOwnedStatus()
                
                // Salva l'item appena acquistato e mostra l'alert per indossarlo
                justPurchasedItem = item
                showWearConfirmation = true
            } else {
                alertMessage = "Errore durante l'acquisto"
                showAlert = true
            }
        }
        
        // Nuova funzione per indossare l'articolo
        private func wearItem() {
            guard let item = justPurchasedItem else { return }
            
            // Indossa l'articolo in base al suo tipo
            switch item.type {
            case .shirt:
                avatarViewModel.setShirt(item.assetName)
            case .pants:
                avatarViewModel.setPants(item.assetName)
            case .shoes:
                avatarViewModel.setShoes(item.assetName)
            }
        }
}

// Preview per la vista principale
#Preview {
    ShopView(avatarViewModel: AvatarViewModel())
}
