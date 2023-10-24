import SwiftUI

struct LostView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Sorry...")
                    .font(.caprasimo(size: 40))
                Text("Your Loss...")
                    .font(.caprasimo(size: 40))
                
                NavigationLink(destination: TopView(), label:{ Text("Return")
                        .font2(size: 25)
                })
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct LostView_Previews: PreviewProvider {
    static var previews: some View {
        LostView()
    }
}
