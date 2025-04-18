//
//  StickerEffect.swift
//  Sticker
//
//  Created by Benjamin Pisano on 03/11/2024.
//

import SwiftUI

@available(iOS 17.0, *)
private struct StickerEffectViewModifier: ViewModifier {
    @State private var motion: StickerMotion = .init()

    @Environment(\.stickerMotionEffect) private var effect
    @Environment(\.stickerScale) private var stickerScale
    @Environment(\.stickerColorIntensity) private var stickerColorIntensity
    @Environment(\.stickerContrast) private var stickerContrast
    @Environment(\.stickerBlend) private var stickerBlend
    @Environment(\.stickerCheckerScale) private var stickerCheckerScale
    @Environment(\.stickerCheckerIntensity) private var stickerCheckerIntensity
    @Environment(\.stickerNoiseScale) private var stickerNoiseScale
    @Environment(\.stickerNoiseIntensity) private var stickerNoiseIntensity
    @Environment(\.stickerLightIntensity) private var stickerLightIntensity

    func body(content: Content) -> some View {
        content
            .visualEffect { [motion, stickerLightIntensity] view, proxy in
                view
                    .colorEffect(
                        ShaderLibrary.reflectionShader(
                            size: proxy.size,
                            reflectionPosition: CGPoint(
                                x: (motion.transform.x + proxy.size.width / 2) / proxy.size.width,
                                y: (motion.transform.y + proxy.size.height / 2) / proxy.size.height
                            ),
                            reflectionSize: Float(min(proxy.size.width, proxy.size.height) / 2),
                            reflectionIntensity: motion.isActive ? stickerLightIntensity : 0
                        )
                    )
            }
            .visualEffect {
                [
                    motion, stickerScale, stickerColorIntensity, stickerContrast, stickerBlend,
                    stickerCheckerScale, stickerCheckerIntensity, stickerNoiseScale,
                    stickerNoiseIntensity
                ] view, proxy in
                view
                    .colorEffect(
                        ShaderLibrary.foilShader(
                            offset: motion.isActive
                                ? (motion.transform * -150).point : StickerTransform.neutral.point,
                            size: proxy.size,
                            scale: stickerScale,
                            intensity: stickerColorIntensity,
                            contrast: stickerContrast,
                            blendFactor: stickerBlend,
                            checkerScale: stickerCheckerScale,
                            checkerIntensity: stickerCheckerIntensity,
                            noiseScale: stickerNoiseScale,
                            noiseIntensity: stickerNoiseIntensity
                        )
                    )
            }
            .mask(content)
            .applyTransform(for: effect)
            .onStickerShaderChange { motion in
                self.motion = motion
            }
    }
}

@available(iOS 17.0, *)
extension View {
    @ViewBuilder
    public func stickerEffect(_ isEnabled: Bool = true) -> some View {
        if isEnabled {
            modifier(StickerEffectViewModifier())
        } else {
            self
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    VStack {
        Circle()
            .fill(.white)
            .overlay {
                Circle()
                    .stroke(.black, lineWidth: 2)
                    .padding(2)
            }
            .frame(height: 30)
            .animation(.snappy) { view in
                view
                    .stickerEffect()
                    .stickerMotionEffect(.pointerHover)
            }
            .shadow(radius: 20)
            .padding()

        Circle()
            .fill(.white)
            .overlay {
                Circle()
                    .stroke(.black, lineWidth: 16)
                    .padding()
            }
            .frame(height: 300)
            .animation(.snappy) { view in
                view
                    .stickerEffect()
                    .stickerMotionEffect(.dragGesture)
            }
            .shadow(radius: 20)
            .padding()
    }
}
