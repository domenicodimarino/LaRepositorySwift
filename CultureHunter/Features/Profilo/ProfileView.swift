import SwiftUI

struct ProfileView: View {
  
    @ObservedObject var viewModel: AvatarViewModel
    
    // Keys for mission time (same as in MissionViewModel)
        private let missionTimeHourKey = "missionTimeHourKey"
        private let missionTimeMinuteKey = "missionTimeMinuteKey"
  
  // Proprietà calcolata per il binding al nome
  private var nameBinding: Binding<String> {
    Binding<String>(
      get: { self.viewModel.avatar.name },
      set: { self.viewModel.setName($0) }
    )
  }
    private func saveMissionTime(_ date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        UserDefaults.standard.set(components.hour, forKey: missionTimeHourKey)
        UserDefaults.standard.set(components.minute, forKey: missionTimeMinuteKey)
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
                LabeledContent {
                    TextField("Il tuo nome", text: nameBinding)
                } label: {
                    Text("Nome:")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }

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
              Section {
                                          // Mission time picker
                                          DatePicker("Orario missione giornaliera",
                                                    selection: Binding<Date>(
                                                      get: {
                                                          let hour = UserDefaults.standard.integer(forKey: self.missionTimeHourKey)
                                                          let minute = UserDefaults.standard.integer(forKey: self.missionTimeMinuteKey)
                                                          return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
                                                      },
                                                      set: { newValue in
                                                          saveMissionTime(newValue)
                                                      }
                                                    ),
                                                    displayedComponents: .hourAndMinute)
                                      }
          }
          .frame(height: 350)  // regola in base al contenuto
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
  ProfileView(viewModel: AvatarViewModel())
}
