import SwiftUI

struct StyleView: View {
    @ObservedObject var viewModel: AvatarViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var onCustomAction: (() -> Void)?
    
    @State private var selectedIndex: Int?
    @State private var previewViewModel = AvatarViewModel()
    
    var body: some View {
        ScrollView { // <--- AVVOLGI TUTTO IN UNO SCROLLVIEW
            VStack {
                Text("Cambio stile")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .bold()
                    .padding()
                
                Text("Scegli uno dei due avatar qui sotto. Ricorda che puoi ricambiarlo successivamente.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        selectedIndex = 0
                    }) {
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
                            
                            if viewModel.avatar.gender == .male {
                                AvatarSpriteKitView(viewModel: viewModel)
                                    .frame(width: 137, height: 137)
                            } else {
                                AvatarSpriteKitView(viewModel: previewViewModel)
                                    .frame(width: 137, height: 137)
                            }
                        }
                        .overlay(
                            Group {
                                if selectedIndex == 0 {
                                    Image("checkmarkIcon")
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
                    
                    Button(action: {
                        selectedIndex = 1
                    }) {
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
                            
                            if viewModel.avatar.gender == .female {
                                AvatarSpriteKitView(viewModel: viewModel)
                                    .frame(width: 137, height: 137)
                            } else {
                                AvatarSpriteKitView(viewModel: previewViewModel)
                                    .frame(width: 137, height: 137)
                            }
                        }
                        .overlay(
                            Group {
                                if selectedIndex == 1 {
                                    Image("checkmarkIcon")
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
                Button(action: {
                    if let selectedIndex = selectedIndex {
                        let newGender: Gender = selectedIndex == 0 ? .male : .female
                        if viewModel.avatar.gender != newGender {
                            viewModel.avatar = previewViewModel.avatar
                        }
                    }
                    
                    if let customAction = onCustomAction {
                        customAction()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 276.42, height: 102.34)
                            .background(colorScheme == .dark ? Color.white : Color.black)
                            .cornerRadius(28.88)
                        Text("Avanti")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .font(.title2)
                            .bold()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 30)
                .disabled(selectedIndex == nil)
                .opacity(selectedIndex == nil ? 0.6 : 1.0)
            }
            .onAppear {
                selectedIndex = viewModel.avatar.gender == .male ? 0 : 1
                setupPreviewViewModel()
            }
        }
    }
    
    private func setupPreviewViewModel() {
        previewViewModel.avatar = viewModel.avatar
    
        let currentGender = viewModel.avatar.gender
        let oppositeGender: Gender = currentGender == .male ? .female : .male
        
        previewViewModel.avatar.gender = oppositeGender
        
        let oldPrefix = currentGender == .male ? "male_" : "female_"
        let newPrefix = oppositeGender == .male ? "male_" : "female_"
        
        previewViewModel.avatar.head = previewViewModel.avatar.head.replacingOccurrences(of: oldPrefix, with: newPrefix)
        previewViewModel.avatar.hair = previewViewModel.avatar.hair.replacingOccurrences(of: oldPrefix, with: newPrefix)
        previewViewModel.avatar.skin = previewViewModel.avatar.skin.replacingOccurrences(of: oldPrefix, with: newPrefix)
        previewViewModel.avatar.shirt = previewViewModel.avatar.shirt.replacingOccurrences(of: oldPrefix, with: newPrefix)
        previewViewModel.avatar.pants = previewViewModel.avatar.pants.replacingOccurrences(of: oldPrefix, with: newPrefix)
        previewViewModel.avatar.shoes = previewViewModel.avatar.shoes.replacingOccurrences(of: oldPrefix, with: newPrefix)
        previewViewModel.avatar.eyes = previewViewModel.avatar.eyes.replacingOccurrences(of: oldPrefix, with: newPrefix)
    }
}
