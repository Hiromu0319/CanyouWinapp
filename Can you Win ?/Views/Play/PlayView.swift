import SwiftUI

struct PlayView: View {
    
    @StateObject var viewModel: PlayViewModel
    
    init(viewModel: PlayViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    @ViewBuilder
    func dataTable(proxy: GeometryProxy) -> some View{
        let size = proxy.size.width * 0.07
        HStack {
            Spacer()
            VStack {
                Text("Score")
                    .font(.caprasimo(size: size*1.1))
                
                if let endTimeStr = viewModel.convertDate() {
                    Text(endTimeStr)
                        .font(.caprasimo(size: size))
                } else if let startTime = viewModel.startTime {
                    Text(startTime, style: .timer)
                        .font(.caprasimo(size: size))
                }
            }
            Spacer()
            VStack {
                Text("Time")
                    .font(.caprasimo(size: size * 1.1))
                Text("\(viewModel.remainingTime / 60):\(String(format: "%02d", viewModel.remainingTime % 60))")
                    .font(.caprasimo(size: size))
            }
            Spacer()
            VStack {
                Text("Point")
                    .font(.caprasimo(size: size * 1.1))
                Text("\(viewModel.humanPoint) - \(viewModel.computerPoint)")
                    .font(.caprasimo(size: size))
            }
            Spacer()
        }
    }
    
    
    @ViewBuilder
    func main(proxy: GeometryProxy) -> some View{
        let size = proxy.size.width * 0.2
        LazyVGrid(
            columns: viewModel.createColumns(size: size),
            content: {
                ForEach(viewModel.numbers, id: \.self) { num in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.selectedNumbers.contains(num) ? .white: (viewModel.selectNumber == num ? .green : .black))
                        Text("\(num.self)")
                            .foregroundColor(.white)
                            .font(.caprasimo(size: size * 0.4))
                    }
                    .frame(height: size)
                    .onTapGesture {
                        viewModel.toggleSelect(num: num)
                    }
                }
            }
        )
    }
    
    
    @ViewBuilder
    func lastSelectView(proxy: GeometryProxy) -> some View {
        let size = proxy.size.width * 0.06
        if viewModel.selectedNumbers.count == 0 {
            Text("LastSelect: ")
                .font(.caprasimo(size: size))
        }
        else{
            let lastselect = viewModel.selectedNumbers.last!
            Text("LastSelect: \(lastselect) ")
                .font(.caprasimo(size: size))
        }
    }
    
    
    var body: some View {
        GeometryReader { proxy in
            
            VStack() {
                Spacer()
                dataTable(proxy: proxy)
                Spacer()
                main(proxy: proxy)
                Spacer()
                lastSelectView(proxy: proxy)
                Spacer()
                HStack {
                    
                    Button("choice"){
                        if !viewModel.pushChoice() {
                            viewModel.plusHumanPoint()
                            viewModel.initialize()
                        }
                    }
                    .font1(proxy: proxy)
                    .disabled(viewModel.notShowButtonToggle())
                    
                    Button("No choice"){
                        viewModel.plusComputerPoint()
                        viewModel.initialize()
                    }
                    .font1(proxy: proxy)
                    
                    Button("Interrupt"){
                        viewModel.isAlertPresented.toggle()
                    }
                    .font1(proxy: proxy)
                    .alert(isPresented: $viewModel.isAlertPresented) {
                        Alert(
                            title: Text("本当に中断しますか？"),
                            primaryButton: .destructive(Text("中断する"), action: {
                                viewModel.navigateToTopView = true
                            }),
                            secondaryButton: .cancel(Text("キャンセル"))
                        )
                    }
                }
                Spacer()
                
            }
            NavigationStack{
                NavigationLink(destination: LostView(), isActive: $viewModel.computerWinFlag) {EmptyView()}
                NavigationLink(destination: WinView(), isActive: $viewModel.humanWinFlag) {EmptyView()}
            }
            
        }.navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.onAppear()
                viewModel.startTimer()
                viewModel.startTime = Date()
                
            }
            .background(
                NavigationLink(destination: TopView(), isActive: $viewModel.navigateToTopView) {EmptyView()}
            )
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(viewModel: .init(oldScore: nil))
    }
}
