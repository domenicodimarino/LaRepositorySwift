import SwiftUI

struct AvatarCustomizationView: View {
    @ObservedObject var viewModel: AvatarViewModel
    
    // MARK: - Data Models
    
    // Utilizzo di un enum per rappresentare i vari tipi di opzioni in modo più tipizzato
    enum CustomizationOption: Identifiable {
        case style                   // Cambio stile (uomo/donna)
        case hair                    // Capelli
        case complexion              // Carnagione
        case eyeColor                // Colore occhi
        
        var id: String { title }
        
        var title: String {
            switch self {
            case .style: return "Cambia stile"
            case .hair: return "Capigliatura"
            case .complexion: return "Carnagione"
            case .eyeColor: return "Colore degli occhi"
            }
        }
    }
    
    // MARK: - Properties
    
    // Usa una lista fissa di opzioni, poiché l'ordine e le opzioni non cambiano
    private let options: [CustomizationOption] = [.style, .hair, .complexion, .eyeColor]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    avatarPreviewSection
                    optionsListSection
                }
                .padding(.top)
            }
        }
        .navigationTitle("Il tuo aspetto")
    }
    
    // MARK: - View Components
    
    private var avatarPreviewSection: some View {
        ZStack(alignment: .bottom) {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 308, height: 205)
                .clipped()
                .cornerRadius(16)
            
            AvatarSpriteKitView(viewModel: viewModel)
                .frame(width: 128, height: 128)
        }
    }
    
    private var optionsListSection: some View {
        VStack(spacing: 0) {
            ForEach(options) { option in
                navigationLinkForOption(option)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        // Aggiungi un ID univoco basato sui dati dell'avatar per forzare l'aggiornamento
        .id("optionsList-\(viewModel.avatar.hair)-\(viewModel.avatar.skin)-\(viewModel.avatar.eyes)")
    }
    
    // MARK: - Helper Functions
    
    @ViewBuilder
    private func navigationLinkForOption(_ option: CustomizationOption) -> some View {
        NavigationLink(destination: destinationForOption(option)) {
            HStack(spacing: 16) {
                iconForOption(option)
                
                Text(option.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(Color.secondary)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
            Divider()
                .padding(.leading, 76),
            alignment: .bottom
        )
    }
    
    @ViewBuilder
    private func iconForOption(_ option: CustomizationOption) -> some View {
        switch option {
        case .style:
            AvatarHeadPreview(viewModel: viewModel, size: CGSize(width: 60, height: 60))
            
        case .hair:
            // Accedi direttamente al valore corrente
            Image(viewModel.avatar.hair)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .frame(width: 60, height: 60)
                .clipped()
                .background(Color.gray.opacity(0.1))
            
        case .complexion:
            Circle()
                .fill(getComplexionColor())
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 4)
                )
            
        case .eyeColor:
            Circle()
                .fill(getEyeColor())
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 4)
                )
        }
    }
    
    // Accediamo direttamente ai valori aggiornati quando necessario
    private func getComplexionColor() -> Color {
        let currentSkin = viewModel.avatar.skin
        if let complexion = ComplexionColors.findComplexion(in: currentSkin) {
            return complexion.color
        }
        return ComplexionColors.getColor(for: "light")
    }
    
    private func getEyeColor() -> Color {
        let currentEyes = viewModel.avatar.eyes
        if let eyeColor = EyeColors.findEyeColor(in: currentEyes) {
            return eyeColor.color
        }
        return EyeColors.getColor(for: "blue")
    }
    
    @ViewBuilder
    private func destinationForOption(_ option: CustomizationOption) -> some View {
        switch option {
        case .style:
            StyleView(viewModel: viewModel)
        case .hair:
            HairSelectionView(viewModel: viewModel)
        case .complexion:
            CarnagioneView(viewModel: viewModel)
        case .eyeColor:
            EyeColorView(viewModel: viewModel)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        AvatarCustomizationView(viewModel: AvatarViewModel())
    }
}
