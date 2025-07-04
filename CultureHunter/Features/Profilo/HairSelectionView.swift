//
//  HairSelectionView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//

import SwiftUI

// Modello per capigliatura
struct Hair: Identifiable, Hashable {
  let id = UUID()
  let assetName: String
  let tipo: String  // ad esempio: "Nessuna", "Corti", "Lunghi"
}

struct HairSelectionView: View {

  let allHairs: [Hair] = [
    Hair(assetName: "none", tipo: "Nessuna"),
    Hair(assetName: "120 hair Plain black", tipo: "Corti"),
    Hair(assetName: "120 hair Plain dark brown", tipo: "Corti"),
    Hair(assetName: "120 hair Plain light brown", tipo: "Corti"),
    Hair(assetName: "120 hair Plain blonde", tipo: "Corti"),
    Hair(assetName: "120 hair Plain ginger", tipo: "Corti"),
    Hair(assetName: "120 hair Plain gold", tipo: "Corti"),
    Hair(assetName: "120 hair Plain gray", tipo: "Corti"),
    Hair(assetName: "120 hair Plain white", tipo: "Corti"),
    Hair(assetName: "120 hair Plain green", tipo: "Corti"),
    
    Hair(assetName: "120 hair Plain pink", tipo: "Corti"),
    Hair(assetName: "120 hair Plain purple", tipo: "Corti"),
    Hair(assetName: "120 hair Plain red", tipo: "Corti"),
    
    Hair(assetName: "120 hair Plain blue", tipo: "Corti"),
    Hair(assetName: "120 hair Long black", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long dark brown", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long light brown", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long blonde", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long ginger", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long gold", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long gray", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long white", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long green", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long pink", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long purple", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long red", tipo: "Lunghi"),
    Hair(assetName: "120 hair Long blue", tipo: "Lunghi"),
  ]

  @State private var selectedHair: Hair?

  var body: some View {
    ScrollView {
      VStack {
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
        .padding(.top)
        .frame(maxWidth: .infinity)

        // Nessuna capigliatura
        Spacer()
        Text("Nessuna capigliatura")
          .font(.headline)
          .padding(.horizontal)
          .frame(maxWidth: .infinity, alignment: .leading)
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            ForEach(allHairs.filter { $0.tipo == "Nessuna" }) { hair in
              HairCard(
                imageName: hair.assetName,
                isSelected: selectedHair == hair,
                onSelect: { selectedHair = hair }
              )
            }
          }
          .padding(.horizontal)
        }
        Spacer(minLength: 20)
        // Capelli corti
        Text("Capelli corti")
          .font(.headline)
          .padding(.horizontal)
          .frame(maxWidth: .infinity, alignment: .leading)
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            ForEach(allHairs.filter { $0.tipo == "Corti" }) { hair in
              HairCard(
                imageName: hair.assetName,
                isSelected: selectedHair == hair,
                onSelect: { selectedHair = hair }
              )
            }
          }
          .padding(.horizontal)
        }
        Spacer(minLength: 20)
        // Capelli lunghi
        Text("Capelli lunghi")
          .font(.headline)
          .padding(.horizontal)
          .frame(maxWidth: .infinity, alignment: .leading)
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            ForEach(allHairs.filter { $0.tipo == "Lunghi" }) { hair in
              HairCard(
                imageName: hair.assetName,
                isSelected: selectedHair == hair,
                onSelect: { selectedHair = hair }
              )
            }
          }
          .padding(.horizontal)
        }

        Spacer()
      }
    }.navigationTitle(Text("Capigliatura"))
          .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  HairSelectionView()
}
