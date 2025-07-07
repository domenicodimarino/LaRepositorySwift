import SwiftUI

struct ProfileView: View {
  // Rimuoviamo lo stato locale e usiamo il viewModel
  @StateObject var viewModel = AvatarViewModel()
  
  // Proprietà calcolata per il binding al nome
  private var nameBinding: Binding<String> {
    Binding<String>(
      get: { self.viewModel.avatar.name },
      set: { self.viewModel.setName($0) }
    )
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          // Header
          Text("Il tuo profilo")
            .font(.largeTitle)
            .fontWeight(.bold)
            .kerning(0.4)
            .multilineTextAlignment(.center)
            .foregroundColor(.primary)
            .padding(.top)

          // Avatar + background
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

          // Spacer to separate from form
          Spacer()

          // Title2/Emphasized
          Text("Informazioni sul profilo")
            .font(.title)
            .fontWeight(.medium)
            .foregroundColor(.primary)
          Form {
            Section {
              // Ora usiamo il binding al viewModel
              TextField("Il tuo nome", text: nameBinding)

              // Link a schermata di personalizzazione avatar
              NavigationLink {
                AvatarCustomizationView(viewModel: viewModel)
              } label: {
                HStack {
                  Text("Aspetto")
                  Spacer()
                }
              }

              // Link a inventario
              NavigationLink {
                InventoryView(viewModel: viewModel)
              } label: {
                HStack {
                  Text("Inventario")
                  Spacer()
                }
              }
              // Link a riavvio tutorial
              NavigationLink {
                //InventoryView()
              } label: {
                HStack {
                  Text("Riavvia Tutorial")
                  Spacer()
                }
              }
            }
          }
          .frame(height: 300)  // regola in base al contenuto
          .cornerRadius(16)
        }
        .padding()
      }
      .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
    .navigationTitle("Profilo")
  }
}

#Preview {
  ProfileView()
}
