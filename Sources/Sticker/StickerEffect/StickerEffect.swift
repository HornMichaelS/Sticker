//
//  File.swift
//  Sticker
//
//  Created by Benjamin Pisano on 03/11/2024.
//

import SwiftUI

private struct StickerEffectViewModifier: ViewModifier {
    @State private var motion: StickerMotion = .init()

    @Environment(\.stickerMotionEffect) private var effect
    @Environment(\.stickerEffectScale) private var stickerEffectScale
    @Environment(\.stickerEffectIntensity) private var stickerEffectIntensity
    @Environment(\.stickerEffectContrast) private var stickerEffectContrast
    @Environment(\.stickerEffectBlendFactor) private var stickerEffectBlendFactor
    @Environment(\.stickerEffectNoiseScale) private var stickerEffectNoiseScale
    @Environment(\.stickerEffectNoiseIntensity) private var stickerEffectNoiseIntensity
    @Environment(\.stickerEffectLightIntensity) private var stickerEffectLightIntensity

    func body(content: Content) -> some View {
        content
            .visualEffect { [motion, stickerEffectScale, stickerEffectIntensity, stickerEffectContrast, stickerEffectBlendFactor, stickerEffectNoiseScale, stickerEffectNoiseIntensity] view, proxy in
                view
                    .colorEffect(
                        ShaderLibrary.foilShader(
                            offset: motion.isActive ? (motion.transform * -150).point : StickerTransform.neutral.point,
                            size: proxy.size,
                            scale: stickerEffectScale,
                            intensity: stickerEffectIntensity,
                            contrast: stickerEffectContrast,
                            blendFactor: stickerEffectBlendFactor,
                            noiseScale: stickerEffectNoiseScale,
                            noiseIntensity: stickerEffectNoiseIntensity
                        )
                    )
            }
            .visualEffect { [motion, stickerEffectLightIntensity] view, proxy in
                view
                    .colorEffect(
                        ShaderLibrary.reflectionShader(
                            size: proxy.size,
                            reflectionPosition: CGPoint(
                                x: motion.transform.x,
                                y: motion.transform.y
                            ),
                            reflectionSize: Float(min(proxy.size.width, proxy.size.height) / 2),
                            reflectionIntensity: motion.isActive ? stickerEffectLightIntensity : 0
                        )
                    )
            }
            .mask(content)
            .rotation3DEffect(
                motion.isActive ? .radians(motion.transform.x - 0.5) : .degrees(0),
                axis: (0, 1, 0)
            )
            .rotation3DEffect(
                motion.isActive ? .radians(motion.transform.y - 0.5) : .degrees(0),
                axis: (-1, 0, 0)
            )
            .stickerTransformation(effect)
            .onStickerMotionChange { motion in
                self.motion = motion
            }
    }
}

public extension View {
    @ViewBuilder
    func stickerEffect(_ isEnabled: Bool = true) -> some View {
        if isEnabled {
            modifier(StickerEffectViewModifier())
        } else {
            self
        }
    }
}

#Preview {
    VStack {
        Circle()
            .fill(.white)
            .stroke(.black, lineWidth: 5)
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
            .stroke(.black, lineWidth: 10)
            .frame(height: 300)
            .animation(.snappy) { view in
                view
                    .stickerEffect()
                    .stickerMotionEffect(.pointerHover)
            }
            .shadow(radius: 20)
            .padding()
    }
}
