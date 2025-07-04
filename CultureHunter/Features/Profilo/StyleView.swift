import SwiftUI

struct StyleView: View {
    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack {
            Text("Cambio stile")
                .font(.largeTitle)
                .foregroundColor(.black)
                .bold()
                .padding()
            Text("Scegli uno dei due avatar qui sotto. Ricorda che puoi ricambiarlo successivamente.")
                .font(.body)
                .foregroundColor(.black)
                .padding()
            HStack {
                Spacer()
                // Primo bottone
                Button(action: { selectedIndex = 0 }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 147.49, height: 198)
                            .background(
                                selectedIndex == 0
                                    ? Color(red: 0.49, green: 0.49, blue: 0.49)
                                    : Color(red: 0.85, green: 0.85, blue: 0.85)
                            )
                            .cornerRadius(34.35)
                            .overlay(
                                RoundedRectangle(cornerRadius: 34.35)
                                    .inset(by: 5.05)
                                    .stroke(.black, lineWidth: 5.05)
                            )
                        Image("uomo")
                            .resizable()
                            .frame(width: 137, height: 137)
                    }
                    // SOLO LA SPUNTA in alto a destra
                    .overlay(
                        Group {
                            if selectedIndex == 0 {
                                Image("checkmark") // Cambia con il nome della tua spunta
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .offset(x:10,y:-10)
                            }
                        },
                        alignment: .topTrailing
                    )
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                // Secondo bottone
                Button(action: { selectedIndex = 1 }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 147.49, height: 198)
                            .background(
                                selectedIndex == 1
                                    ? Color(red: 0.49, green: 0.49, blue: 0.49)
                                    : Color(red: 0.85, green: 0.85, blue: 0.85)
                            )
                            .cornerRadius(34.35)
                            .overlay(
                                RoundedRectangle(cornerRadius: 34.35)
                                    .inset(by: 5.05)
                                    .stroke(.black, lineWidth: 5.05)
                            )
                        Image("donna")
                            .resizable()
                            .frame(width: 137, height: 137)
                    }
                    .overlay(
                        Group {
                            if selectedIndex == 1 {
                                Image("checkmark") // Cambia con il nome della tua spunta
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .offset(x:10,y:-10)
                            }
                        },
                        alignment: .topTrailing
                    )
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            // Bottone "Avanti"
            Button(action: {
                // Azione per avanti
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 276.42, height: 102.34)
                        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
                        .cornerRadius(28.88)
                    Text("Avanti")
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 30)
        }
    }
}

#Preview {
    StyleView()
}
