//
//  ShopView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

struct ShopView: View {
    @ObservedObject var avatarViewModel: AvatarViewModel
    @ObservedObject var missionViewModel: MissionViewModel
    @StateObject private var shopViewModel: ShopViewModel
    
    @State private var showAlert = false
    @State private var showConfirmation = false
    @State private var showWearConfirmation = false
    @State private var alertMessage = ""
    @State private var selectedItem: ShopItem? = nil
    @State private var justPurchasedItem: ShopItem? = nil
    @State private var missionRewardProcessed = false
    
    init(avatarViewModel: AvatarViewModel, missionViewModel: MissionViewModel) {
        self.avatarViewModel = avatarViewModel
        self.missionViewModel = missionViewModel
        _shopViewModel = StateObject(wrappedValue: ShopViewModel(avatarViewModel: avatarViewModel))
    }
    
    var body: some View {
        VStack {
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
        .alert("Conferma acquisto", isPresented: $showConfirmation) {
            Button("No", role: .cancel) { }
            Button("Sì") {
                proceedWithPurchase()
            }
        } message: {
            if let item = selectedItem {
                Text("Vuoi acquistare \(item.displayName) per \(item.price) monete?")
            } else {
                Text("Vuoi acquistare questo articolo?")
            }
        }
        .alert("Indossare articolo", isPresented: $showWearConfirmation) {
            Button("No", role: .cancel) {
                alertMessage = "Puoi indossarlo dall'inventario quando vuoi."
                showAlert = true
            }
            Button("Sì") {
                wearItem()
            }
        } message: {
            if let item = justPurchasedItem {
                Text("Articolo acquistato! Vuoi indossare subito \(item.displayName)?")
            } else {
                Text("Articolo acquistato! Vuoi indossarlo subito?")
            }
        }
        .onAppear {
            shopViewModel.updateOwnedStatus()
            checkMissionCompletion()
        }
        .onChange(of: missionViewModel.activeMission) { newMission in
            print("Active mission changed: \(newMission?.description ?? "none")")
            missionRewardProcessed = false
            checkMissionCompletion()
        }
        .onReceive(missionViewModel.objectWillChange) { _ in
        }
    }
    
    private func checkMissionCompletion() {
        #if DEBUG
        let simulatePoiVisited = false
        #else
        let simulatePoiVisited = false
        #endif
        
        if !missionRewardProcessed, let reward = missionViewModel.tryCompleteMission(poiVisited: simulatePoiVisited) {
            avatarViewModel.addCoins(reward)
            missionRewardProcessed = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alertMessage = "Missione completata! +\(reward) monete."
                showAlert = true
            }
        }
    }
    
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
                MissionBanner(missionViewModel: missionViewModel)
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
                .accessibilityLabel("Shop background")
            AvatarSpriteKitView(viewModel: avatarViewModel)
                .frame(width: 128, height: 128)
                .accessibilityLabel("Avatar preview")
        }
    }
    
    private var coinDisplay: some View {
        HStack {
            Text("Le tue monete: ")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Image("coin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 19, height: 15)
                .clipped()
                .accessibilityLabel("Coin icon")
            
            Text("\(shopViewModel.coins)")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
    
    private var shopSections: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
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
    
    private func buySelectedItem() {
        guard let item = selectedItem else { return }
        
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
            shopViewModel.updateOwnedStatus()
            justPurchasedItem = item
            showWearConfirmation = true
        } else {
            alertMessage = "Errore durante l'acquisto"
            showAlert = true
        }
    }
    
    private func wearItem() {
        guard let item = justPurchasedItem else { return }
        
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
