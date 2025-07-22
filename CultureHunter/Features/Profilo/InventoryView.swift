//
//  InventoryView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

struct InventoryView: View {
    
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
        .init(
          title: "Maglietta",
          iconName: nil,
          iconColor: nil,
          destination: AnyView(ShirtView(viewModel: viewModel)),
          dynamicImage:{
              let shirtName = getShirtIconName()
              return Image(shirtName)
          }
            ),
        .init(
          title: "Pantaloni",
          iconName: nil,
          iconColor: nil,
          destination: AnyView(PantsView(viewModel: viewModel)),
          dynamicImage: {
            let pantsName = getPantsIconName()
            return Image(pantsName)
          }
        ),
        .init(
          title: "Scarpe",
          iconName: nil,
          iconColor: nil,
          destination: AnyView(ShoesView(viewModel: viewModel)),
          dynamicImage: {
                let shoesName = getShoesIconName()
              return Image(shoesName)
          }),
      ]
    }
    
    private func getShirtIconName() -> String {
        return viewModel.avatar.shirt
    }
      private func getPantsIconName() -> String {
          return viewModel.avatar.pants
      }

      private func getShoesIconName() -> String {
          return viewModel.avatar.shoes
      }
    
    
    var body: some View {
        ZStack{
            Color(UIColor.systemGroupedBackground)
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
                  AvatarSpriteKitView(viewModel: viewModel)
                    .frame(width: 128, height: 128)
                }
                VStack(spacing: 0) {
                  ForEach(options) { opt in
                    NavigationLink(destination: opt.destination) {
                      HStack(spacing: 16) {

                        if let dynamicImageProvider = opt.dynamicImage {
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
                            .overlay(
                              Circle()
                                .stroke(Color.black, lineWidth: 4)
                            )
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
        .navigationTitle("Il tuo inventario")
    }
}
