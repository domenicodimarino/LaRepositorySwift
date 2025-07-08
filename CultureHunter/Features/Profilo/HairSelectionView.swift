//
//  HairSelectionView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//  Ottimizzato il 08/07/25.
//

import SwiftUI

// MARK: - Modelli e Dati

/// Modello per una capigliatura
struct Hair: Identifiable, Hashable {
    let id = UUID()
    let assetName: String
    let tipo: String  // "Nessuna", "Corti", "Lunghi"
    
    // Proprietà computed per facilitare l'accesso al nome visualizzabile
    var displayName: String {
        // Estrae il colore dal nome dell'asset (es. "120 hair Long blue" -> "blue")
        if assetName == "none" {
            return "Nessuna"
        }
        
        let components = assetName.components(separatedBy: " ")
        return components.count > 3 ? components.last ?? "" : ""
    }
}

/// Organizza i capelli per tipo
struct HairCategory: Identifiable {
    let id: String
    let title: String
    let items: [Hair]
    
    init(title: String, items: [Hair]) {
        self.id = title
        self.title = title
        self.items = items
    }
}

// MARK: - Vista principale

struct HairSelectionView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: AvatarViewModel
    
    /// Categorie di capelli organizzate
    private let categories: [HairCategory]
    
    /// Tracking dello stato UI
    @State private var scrollToCategory: String? = nil
    
    // MARK: - Initialization
    
    init(viewModel: AvatarViewModel) {
        self.viewModel = viewModel
        
        // Definisce l'ordine esplicito delle categorie
        let categoryOrder = ["Nessuna", "Corti", "Lunghi"]
        
        // Organizza i capelli in categorie mantenendo l'ordine specificato
        let allHairs = Self.loadHairs()
        
        // Crea le categorie nell'ordine specifico
        self.categories = categoryOrder.map { tipo in
            let hairsInCategory = allHairs.filter { $0.tipo == tipo }
            return HairCategory(title: tipo, items: hairsInCategory)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                avatarPreviewSection
                
                // Sezioni di capelli per categoria
                ForEach(categories) { category in
                    HairCategorySection(
                        title: categoryTitle(for: category.title),
                        items: category.items,
                        selectedHair: viewModel.avatar.hair,
                        onSelect: { hair in
                            viewModel.setHair(hair.assetName)
                        }
                    )
                }
                
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .navigationTitle("Capigliatura")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Al caricamento della vista, determina la categoria corrente
            findCurrentCategory()
        }
    }
    
    // MARK: - Computed Properties
    
    private var avatarPreviewSection: some View {
        ZStack(alignment: .bottom) {
            Image("hair salon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 308, height: 205)
                .clipped()
                .cornerRadius(16)
            
            AvatarSpriteKitView(viewModel: viewModel)
                .frame(width: 128, height: 128)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    /// Carica tutti i capelli disponibili
    private static func loadHairs() -> [Hair] {
        // 1. Definisci i colori una sola volta (sono gli stessi per entrambi i tipi)
        let hairColors = ["black", "dark brown", "light brown", "blonde",
                          "ginger", "gold", "gray", "white",
                          "green", "pink", "purple", "red", "blue"]
        
        // 2. Primo array - Nessuna capigliatura
        let noHair = [Hair(assetName: "none", tipo: "Nessuna")]
        
        // 3. Genera i due tipi di capelli usando gli stessi colori
        let shortHair = hairColors.map { Hair(assetName: "120 hair Plain \($0)", tipo: "Corti") }
        let longHair = hairColors.map { Hair(assetName: "120 hair Long \($0)", tipo: "Lunghi") }
        
        // 4. Unione degli array in ordine
        return noHair + shortHair + longHair
    }
    
    /// Determina la categoria corrente in base al capello selezionato
    private func findCurrentCategory() {
        let currentHair = viewModel.avatar.hair
        for category in categories {
            if category.items.contains(where: { $0.assetName == currentHair }) {
                scrollToCategory = category.id
                break
            }
        }
    }
    
    /// Fornisce il titolo formattato per una categoria
    private func categoryTitle(for type: String) -> String {
        switch type {
        case "Nessuna": return "Nessuna capigliatura"
        case "Corti": return "Capelli corti"
        case "Lunghi": return "Capelli lunghi"
        default: return type
        }
    }
}

// MARK: - Componenti di supporto

/// Sezione per una categoria di capelli
struct HairCategorySection: View {
    let title: String
    let items: [Hair]
    let selectedHair: String
    let onSelect: (Hair) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { hair in
                        HairCard(
                            imageName: hair.assetName,
                            isSelected: selectedHair == hair.assetName,
                            onSelect: { onSelect(hair) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        HairSelectionView(viewModel: AvatarViewModel())
    }
}
