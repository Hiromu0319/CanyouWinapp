import SwiftUI

struct RankingView: View {
    @StateObject var viewModel: RankingViewModel = .init()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ScrollView {
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                }
                HStack{
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.largeTitle)
                    Text("Ranking")
                        .font(.caprasimo(size: 40))
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.largeTitle)
                }
            }
            
            Spacer()
            
            if viewModel.scores.isEmpty {
                VStack {
                    Image(systemName: "note.text")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("No Data")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 64)
            } else {ForEach(viewModel.scores) { score in
                HStack {
                    Spacer()
                    ZStack{
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 50, height: 50)
                        Text(String((viewModel.scores.firstIndex(where: { $0.id == score.id }) ?? 0) + 1))
                            .font(.caprasimo(size: 30))
                            .padding()
                    }
                    VStack(alignment: .leading) {
                        Text("\(score.time)")
                            .font(.caprasimo(size: 35))
                        Text("@" + score.uid.prefix(6))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(5)
            }
            }
        }
        .task {
            await viewModel.fetchScore()
        }
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}
