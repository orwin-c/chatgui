//
//  SolidMaterial.swift
//  chatgui
//
//  Created by Owen Cheng on 10/26/25.
//
import SwiftUI

struct SolidMaterial: ViewModifier {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color("WhiteAlternate"))
                    .shadow(
                        color: Color.black.opacity(0.10), radius: 25, y: 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color("Gray3Permanent"), lineWidth: 0.5)
                    )
            )
    }
}

// Extension to make it easier to use
extension View {
    func solidMaterial(cornerRadius: CGFloat = 3) -> some View {
        modifier(SolidMaterial(cornerRadius: cornerRadius))
    }
}
