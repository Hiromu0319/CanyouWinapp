import SwiftUI

struct TopView: View {
    
    @StateObject var viewModel: TopViewModel = .init()
    @State var showRankingView: Bool = false
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 32) {
                
                Text("Can you Win ?")
                    .font(.caprasimo(size: 40))
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack {
                    Text("ID:")
                    if let uid = viewModel.userID {
                        Text(uid.prefix(6))
                    }
                }
                .font(.caprasimo(size: 20))
                .foregroundColor(.secondary)
                .padding(20)
                
                NavigationLink(destination: PlayView(viewModel: .init(oldScore: viewModel.scores.first))){
                    Text("Let's Play")
                        .font2(size: 25)
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                Button("Ranking") {
                    showRankingView = true
                }
                .font2(size: 25)
            })
            .sheet(isPresented: $showRankingView) {
                RankingView()
            }
            
        }.navigationBarBackButtonHidden(true)
        .task {
            await viewModel.onAppear()
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
