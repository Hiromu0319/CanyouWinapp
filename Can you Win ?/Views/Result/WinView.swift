import SwiftUI

struct WinView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Congratulations!!")
                    .font(.caprasimo(size: 40))
                Text("You Win!!")
                    .font(.caprasimo(size: 40))
                
                NavigationLink(destination: TopView(), label:{ Text("Return")
                        .font2(size: 25)
                })
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct WinView_Previews: PreviewProvider {
    static var previews: some View {
        WinView()
    }
}
