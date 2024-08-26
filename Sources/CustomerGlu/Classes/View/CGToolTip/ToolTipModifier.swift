import SwiftUI

public extension View {
    func cgtooltip(_ text: String, color: UIColor = .systemBlue, position: TooltipPosition = .top) -> some View {
        self.modifier(TooltipModifier(text: text, color: color, position: position))
    }
}

struct TooltipModifier: ViewModifier {
    let text: String
    let color: UIColor
    var position: TooltipPosition
    @State private var isShowing = false
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isShowing {
                        SwiftUITooltipView(text: text, parentWidth: UIScreen.main.bounds.width)
                            .offset(y: position == .top ? -geometry.size.height : geometry.size.height)
                    }
                }
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.isShowing = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                    withAnimation {
                        self.isShowing = false
                    }
                }
            }
    }
}
