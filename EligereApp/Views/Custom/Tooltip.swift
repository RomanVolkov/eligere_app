import SwiftUI

public extension View {
     func tooltip(_ text: String) -> some View {
        self.overlay(
            Text(text)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(5)
                .font(.caption)
                .opacity(0)
        )
    }
}
