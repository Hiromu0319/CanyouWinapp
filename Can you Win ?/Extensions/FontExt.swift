import SwiftUI

extension Font {
    static func caprasimo(size: CGFloat) -> Font {
        .custom("AvenirNext-Heavy", size: size)
    }
}

extension View {
    
    @ViewBuilder
    func font1(proxy: GeometryProxy) -> some View {
        let size: CGFloat = proxy.size.width
        self
            .font(.custom("AvenirNext-Heavy", size: size * 0.05))
            .frame(width: size * 0.3, height: size * 0.15)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    
    @ViewBuilder
    func font2(size: CGFloat) -> some View {
        self
            .font(.custom("AvenirNext-Heavy", size: size))
            .frame(width: size * 20, height: size * 2)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
    }

}
