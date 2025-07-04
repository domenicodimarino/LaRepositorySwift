import SwiftUI

struct ProfileView: View {
    @State private var nickname: String = ""
    
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
                        Image("giovanni")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 133)
                    }
                    
                    // Spacer to separate from form
                    Spacer(minLength: 10)
                    
                    // Title2/Emphasized
                    Text("Informazioni sul profilo")
                        .font(.title2)
                        .fontWeight(.medium)
                      .foregroundColor(.black)
                    Form {
                        
                        Section() {
                            TextField("Il tuo nome", text: $nickname)
                            
                            // Link a schermata di personalizzazione avatar
                            NavigationLink {
                                AvatarCustomizationView()
                            } label: {
                                HStack {
                                    Text("Aspetto")
                                    Spacer()
                                }
                            }
                            
                            // Link a inventario
                            NavigationLink {
                                //InventoryView()
                            } label: {
                                HStack {
                                    Text("Inventario")
                                    Spacer()
                                }
                            }
                            // Link a inventario
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
                    .frame(height: 300) // regola in base al contenuto
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }.navigationTitle("Profilo")
    }
}

#Preview{
    ProfileView()
}
