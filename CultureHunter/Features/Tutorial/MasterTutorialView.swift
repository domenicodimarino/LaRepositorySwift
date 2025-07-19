//
//  MasterTutorialView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

struct MasterTutorialView: View {
    @StateObject private var viewModel: TutorialViewModel
    @Binding var isPresented: Bool
    
    // Costruttore che accetta l'avatarViewModel esterno
        init(isPresented: Binding<Bool>, avatarViewModel: AvatarViewModel) {
            self._isPresented = isPresented
            // Inizializza TutorialViewModel con l'avatarViewModel passato
            self._viewModel = StateObject(wrappedValue: TutorialViewModel(avatarViewModel: avatarViewModel))
        }
    
    var body: some View {
        Group {
            switch viewModel.currentSection {
            case .welcome:
                // Prima pagina di benvenuto
                WelcomeTutorialView(onNext: {
                    viewModel.currentSection = .appInfo
                })
                
            case .appInfo:
                // Pagine informative dell'app
                AppInfoTutorialView(
                    step: viewModel.appInfoStep,
                    onNext: { viewModel.nextAppInfoStep() },
                    onPrevious: { viewModel.prevAppInfoStep() }
                )
                
            case .avatarCreation:
                // Riutilizza i componenti esistenti per la creazione avatar
                AvatarCreationFlowView(
                    viewModel: viewModel,
                    onNext: { viewModel.nextAvatarStep() },
                    onPrevious: { viewModel.prevAvatarStep() }
                )
                
            case .final:
                // Schermata finale
                FinalTutorialView {
                    viewModel.completeTutorial()
                    isPresented = false
                }
            }
        }
        .animation(.easeInOut, value: viewModel.currentSection)
        .animation(.easeInOut, value: viewModel.appInfoStep)
        .animation(.easeInOut, value: viewModel.avatarCreationStep)
    }
}
