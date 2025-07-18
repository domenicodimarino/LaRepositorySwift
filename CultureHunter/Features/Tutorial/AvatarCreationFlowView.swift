import SwiftUI

struct AvatarCreationFlowView: View {
    @ObservedObject var viewModel: TutorialViewModel
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    // Aggiungi il binding al nome qui
        private var nameBinding: Binding<String> {
            Binding<String>(
                get: { self.viewModel.avatarViewModel.avatar.name },
                set: { self.viewModel.avatarViewModel.setName($0) }
            )
        }
        
    
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
                    VStack(spacing: 20) {
                                            // Campo nome con stile coerente
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Come ti chiami?")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                TextField("Inserisci il tuo nome", text: nameBinding)
                                                    .padding()
                                                    .background(Color(.systemGray6))
                                                    .cornerRadius(10)
                                                    .padding(.horizontal)
                                            }
                                            .padding(.horizontal)
                                            
                                            // Usa StyleView normalmente ma passa l'azione personalizzata!
                                            StyleView(
                                                viewModel: viewModel.avatarViewModel,
                                                onCustomAction: { viewModel.nextAvatarStep() }
                                            )
                                        }
                    
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
