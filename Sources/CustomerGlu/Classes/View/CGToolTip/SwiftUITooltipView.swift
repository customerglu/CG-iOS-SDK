//import SwiftUI
//
//public struct SwiftUITooltipView: UIViewRepresentable {
//    let text: String
//    let parentWidth: CGFloat
//    
//    public func makeUIView(context: Context) -> TooltipView {
//        let tooltipView = TooltipView(text: text)
//        let screenWidth = UIScreen.main.bounds.width
//        tooltipView.adjustSize(forWidth: screenWidth)
//        return tooltipView
//    }
//    
//    public func updateUIView(_ uiView: TooltipView, context: Context) {
//        let screenWidth = UIScreen.main.bounds.width
//        uiView.adjustSize(forWidth: screenWidth)
//    }
//}
