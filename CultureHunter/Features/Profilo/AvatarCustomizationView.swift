import SwiftUI

struct AvatarCustomizationView: View {
    
    @ObservedObject var viewModel: AvatarViewModel
    
    struct Option: Identifiable {
        let id = UUID()
        let title: String
        let iconName: String?
        let iconColor: Color?
        let destination: AnyView
        let dynamicImage: (() -> Image)?
    }
    
    private var options: [Option] {
        [
            .init(title: "Cambia stile",
                  iconName: "giovanni",
                  iconColor: nil,
                  destination: AnyView(StyleView()),
                 dynamicImage: nil),
            .init(title: "Capigliatura",
                  iconName: "hair_icon",
                  iconColor: nil,
                  destination: AnyView(HairSelectionView(viewModel: viewModel)),
                  dynamicImage: {
                                        // Generiamo l'immagine dal nome del capello attuale
                                        let hairName = getHairIconName()
                                        return Image(hairName)
                                    }
                 ),
            .init(title: "Carnagione",
                  iconName: nil,
                  iconColor: Color(red: 0.98, green: 0.84, blue: 0.73),
                  destination: AnyView(Text("Carnagione View")),
                 dynamicImage: nil),
            .init(title: "Colore degli occhi",
                  iconName: nil,
                  iconColor: .blue,
                  destination: AnyView(Text("Occhi View")),
                 dynamicImage: nil),
        ]
    }
    // Funzione per ottenere il nome dell'icona dei capelli
        private func getHairIconName() -> String {
            return viewModel.avatar.hair
        }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground) // Sfondo grigio
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    ZStack(alignment: .bottom) {
                        Image("background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 308, height: 205)
                            .clipped()
                            .cornerRadius(16)
                        // Sostituiamo l'immagine statica con l'avatar dinamico
                                                AvatarSpriteKitView(viewModel: viewModel)
                            .frame(width: 128, height: 128)
                    }
                    // Lista con sfondo bianco
                    VStack(spacing: 0) {
                        ForEach(options) { opt in
                            NavigationLink(destination: opt.destination) {
                                HStack(spacing: 16) {
                                    
                                    if let dynamicImageProvider = opt.dynamicImage {
                                                                            // Usa l'immagine dinamica se disponibile
                                                                            dynamicImageProvider()
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .cornerRadius(10)
                                                                                .frame(width: 60, height: 60)
                                                                                .clipped()
                                                                                .background(Color.gray.opacity(0.1))
                                                                        } else if let iconName = opt.iconName {
                                        Image(iconName)
                                            .resizable()
                                            .scaledToFill()
                                            .cornerRadius(10)
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                    } else if let color = opt.iconColor {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 60, height: 60)
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                            .frame(width: 60, height: 60)
                                    }
                                    Text(opt.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.white)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .overlay(
                                Divider()
                                    .padding(.leading, 76), alignment: .bottom
                            )
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Il tuo aspetto")
    }
}

#Preview {
    NavigationView {
        AvatarCustomizationView(viewModel: AvatarViewModel())
    }
}
