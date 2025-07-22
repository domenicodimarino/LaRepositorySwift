import SwiftUI

struct AvatarCreationFlowView: View {
    @ObservedObject var viewModel: TutorialViewModel
    let onNext: () -> Void
    let onPrevious: () -> Void
    
        private var nameBinding: Binding<String> {
            Binding<String>(
                get: { self.viewModel.avatarViewModel.avatar.name },
                set: { self.viewModel.avatarViewModel.setName($0) }
            )
        }
        
    
    var body: some View {
        VStack {
            Text("Creazione Avatar")
                .font(.largeTitle.bold())
                .padding(.top)
            
            Group {
                switch viewModel.avatarCreationStep {
                case .style:
                    VStack(spacing: 20) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Per iniziare, assegna un nome al tuo avatar.")
                                                    .multilineTextAlignment(.center)
                                                    .font(.body)
                                                    .foregroundColor(.primary)
                                                    .padding(.horizontal)
                                                
                                                LabeledContent {
                                                    TextField("Il tuo nome", text: nameBinding)
                                                } label: {
                                                    Text("Nome:")
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.blue)
                                                }
                                                    .padding()
                                                    .background(Color(.systemGray6))
                                                    .cornerRadius(10)
                                                    .padding(.horizontal)
                                            }
                                            .padding(.horizontal)
                                            
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
                case .missionTime:
                    MissionTimeView(
                                        missionHour: $viewModel.missionHour,
                                        missionMinute: $viewModel.missionMinute,
                                        onNext: onNext
                                    )
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }
}
