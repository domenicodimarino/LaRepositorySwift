import SwiftUI

struct AvatarCreationFlowView: View {
    @ObservedObject var viewModel: TutorialViewModel
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    var body: some View {
        VStack {
            // Header del tutorial
            Text("Creazione Avatar")
                .font(.largeTitle.bold())
                .padding(.top)
            
            // Componente corrispondente al passo attuale
            Group {
                switch viewModel.avatarCreationStep {
                case .style:
                    // Usa StyleView normalmente ma passa l'azione personalizzata!
                    StyleView(
                        viewModel: viewModel.avatarViewModel,
                        onCustomAction: { viewModel.nextAvatarStep() }
                    )
                    
                case .hair:
                    HairSelectionViewWrapper(
                        viewModel: viewModel.avatarViewModel,
                        onComplete: onNext,
                        onBack: onPrevious
                    )
                    
                case .eyes:
                    EyeColorViewWrapper(
                        viewModel: viewModel.avatarViewModel,
                        onComplete: onNext,
                        onBack: onPrevious
                    )
                    
                case .skin:
                    CarnagioneViewWrapper(
                        viewModel: viewModel.avatarViewModel,
                        onComplete: onNext,
                        onBack: onPrevious
                    )
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }
}
