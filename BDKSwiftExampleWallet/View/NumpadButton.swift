//
//  NumpadButton.swift
//  CypherPunkCulture
//
//  Created by Esky Lab  on 23/08/2024.
//  Copyright © 2024 CypherPunkCulture. All rights reserved.
//

import Foundation
import SwiftUI

struct NumpadButton: View {
    @Binding var numpadAmount: String
    var character: String

    @State private var isPressed: Bool = false

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Button {
            feedbackGenerator.impactOccurred() // Trigger haptic feedback
            if character == "<" {
                if numpadAmount.count > 1 {
                    numpadAmount.removeLast()
                } else {
                    numpadAmount = "0"
                }
            } else if character == " " {
                return
            } else {
                if numpadAmount == "0" {
                    numpadAmount = character
                } else {
                    numpadAmount.append(character)
                }
            }
        } label: {
            Text(character)
                .font(.title2.weight(.medium))
                .foregroundColor(.primary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isPressed ? Color(uiColor: .systemGray5) : Color(uiColor: .systemBackground))
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

#if DEBUG
#Preview {
    NumpadButton(numpadAmount: .constant("0"), character: "1")
}
#endif
