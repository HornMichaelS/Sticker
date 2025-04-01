//
//  StickerShaderUpdater.swift
//  FoilTest
//
//  Created by Benjamin Pisano on 03/11/2024.
//

import Combine
import SwiftUI

@available(iOS 17.0, *)
struct StickerShaderUpdater {
    typealias ChangeHandler = (_ motion: StickerMotion) -> Void

    let motionSubject = CurrentValueSubject<StickerMotion, Never>(.init())

    var motion: StickerMotion { motionSubject.value }

    private let onChange: ChangeHandler

    init(onChange: @escaping @Sendable ChangeHandler) {
        self.onChange = onChange
    }

    @MainActor
    func update(with transform: StickerTransform) {
        motionSubject.value = .init(
            isActive: true,
            transform: transform
        )

        onChange(motion)
    }

    @MainActor
    func setNeutral() {
        motionSubject.value = .init(
            isActive: false,
            transform: .neutral
        )

        onChange(motion)
    }
}

@available(iOS 17.0, *)
extension StickerShaderUpdater: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(motion)
    }
}

@available(iOS 17.0, *)
extension StickerShaderUpdater: Equatable {
    static func == (lhs: StickerShaderUpdater, rhs: StickerShaderUpdater) -> Bool {
        lhs.motion == rhs.motion
    }
}

@available(iOS 17.0, *)
extension View {
    func onStickerShaderChange(_ onChange: @escaping @Sendable StickerShaderUpdater.ChangeHandler) -> some View {
        environment(\.stickerShaderUpdater, .init(onChange: onChange))
    }
}

@available(iOS 17.0, *)
extension EnvironmentValues {
    @Entry var stickerShaderUpdater: StickerShaderUpdater = .init(onChange: { _ in })
}
