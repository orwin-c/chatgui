
import SwiftUI

struct AnimatedGradientText: View {
    let text: String
    let fontSize: CGFloat
    @State private var animationStart = -1.0
    @State private var animationEnd = 0.0

    init(text: String, fontSize: CGFloat = 18) {
        self.text = text
        self.fontSize = fontSize
    }

    var body: some View {
        Text(text)
            .font(Font.custom("Inter Display", size: fontSize))
            .foregroundColor(Color("Black"))
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.black, .clear, .black]),
                    startPoint: .init(x: animationStart, y: 0.5),
                    endPoint: .init(x: animationEnd, y: 0.5)
                )
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    self.animationStart = 1.0
                    self.animationEnd = 2.0
                }
            }
    }
}

#Preview {
    AnimatedGradientText(text: "Loading Content...", fontSize: 18)
}
