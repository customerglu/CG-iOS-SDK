
import SwiftUI
import CustomerGlu

struct CGVisibilityModifier: ViewModifier {
    let identifier: String
    @State private var capturedCoordinates: CGPoint? = nil
    @State private var isUserInteractionDisabled: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    if #available(iOS 14.0, *) {
                        Color.clear
                            .onAppear {
                                checkFullVisibility(geometry: geometry)
                            }
                            .onChange(of: geometry.frame(in: .global)) { _ in
                                
                                checkFullVisibility(geometry: geometry)
                            }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            )
            .accessibility(identifier: identifier)
            .disabled(isUserInteractionDisabled) // Disable interaction when needed
    }

    private func checkFullVisibility(geometry: GeometryProxy) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let frame = geometry.frame(in: .global)
            let screenBounds = UIScreen.main.bounds

            let isFullyVisible = screenBounds.contains(frame.origin) &&
                screenBounds.contains(CGPoint(x: frame.maxX, y: frame.maxY))

            if isFullyVisible && capturedCoordinates == nil {
                print("screenBounds x", screenBounds.maxX);
                print("screenBounds y", screenBounds.maxY);

               // capturedCoordinates = frame.origin
             
                
               showToolTip(at: frame)
            }
        }
    }

    private func showToolTip(at coordinates: CGRect) {
        isUserInteractionDisabled = true // Disable UI interaction

        // Show the tooltip at captured coordinates
        print("coordinates ", coordinates);
        print("coordinates maxX", coordinates.maxX );
        let newX = ((coordinates.maxX - coordinates.origin.x) / 2) + coordinates.origin.x;
        print("coordinates newX", newX );

        CustomerGlu.getInstance.showAnchorToolTip(xAxis: coordinates.origin.x, yAxis: coordinates.origin.y,centerX: newX,maxXAxis:coordinates.maxX,maxyAxis:coordinates.maxY,anchorviewHeight: coordinates.size.height,anchorviewWidth:coordinates.size.width)

        // Re-enable interaction after a delay, adjust time based on tooltip duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isUserInteractionDisabled = false
        }
    }
}

public extension View {
    func cgToolTipModifier(identifier: String) -> some View {
        self.modifier(CGVisibilityModifier(identifier: identifier))
    }
}
