import SwiftUI

public struct DarkHoverButtonStyle: ButtonStyle {
    @State private var isHovering = false

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(isHovering ? 0.5 : 0.3))
                    .shadow(color: Color.black.opacity(isHovering ? 0.2 : 0.1), radius: isHovering ? 4 : 2, x: 0, y: isHovering ? 2 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.isHovering = hovering
                }
            }
    }
}

