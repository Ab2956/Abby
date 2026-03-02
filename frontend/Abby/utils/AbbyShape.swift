//
//  AbbyShape.swift
//  Abby
//
//  Created by Adam Brows on 15/02/2026.
//

import SwiftUI

struct AbbyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Example placeholder path
        path.move(to: CGPoint(x: rect.minX + 10, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 10, y: rect.midY),
            control1: CGPoint(x: rect.midX - 50, y: rect.minY),
            control2: CGPoint(x: rect.midX + 50, y: rect.maxY)
        )

        return path
    }
}
