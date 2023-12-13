//
//  Game.swift
//  Reality
//
//  Created by Joshua Homann on 12/13/23.
//

import Foundation
import RealityKit
import RealityKitContent

@MainActor
final class Game {
    private weak var sphere: Entity?
    private let viewModel: ViewModel
    private let subscriptions = Subscriptions()
    let move: (Entity) -> Void
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        let (output, input) = AsyncStream.makeStream(of: Entity.self, bufferingPolicy: .bufferingNewest(0))
        move = { input.yield($0) }
        subscriptions.onMain { [weak self] in
            for await entity in output {
                guard let sphere = self?.sphere, entity === sphere else { continue }
                sphere.move(
                    to: .init(translation: .init(0, 0.33, 0)),
                    relativeTo: sphere.parent,
                    duration: 0.5,
                    timingFunction: .easeInOut
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    sphere.move(
                        to: .init(translation: .zero),
                        relativeTo: sphere.parent,
                        duration: 0.25,
                        timingFunction: .easeInOut
                    )
                }
            }
        }
        let enlargeEvents = AsyncStream(observing: viewModel, keyPath: \.enlarge)
        subscriptions.onMain { [weak self] in
            for await enlarge in enlargeEvents {
                self?.sphere?.move(
                    to: .init(scale: .init(repeating: viewModel.enlarge ? 1.25 : 1.0)),
                    relativeTo: self?.sphere?.parent,
                    duration: 0.5,
                    timingFunction: .easeInOut
                )
            }
        }
    }
    @Sendable
    func make(_ content: inout RealityViewContent, _ attachments: RealityViewAttachments) async {
        do {
            let sphereEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.33), materials: [SimpleMaterial(color: .red, roughness: 0, isMetallic: true)])
            sphere = sphereEntity
            content.add(sphereEntity)
            sphereEntity.setPosition([0, -0.1, 0], relativeTo: sphereEntity.parent)
            sphereEntity.components[CollisionComponent.self] = .init(shapes: [ShapeResource.generateSphere(radius: 0.33)])
            sphereEntity.components[InputTargetComponent.self] = .init()
            sphereEntity.components[GroundingShadowComponent.self] = .init(castsShadow: true)
            guard let tagged = attachments.entity(for: ViewModel.Tag.label) else { throw CustomError("No tag found")}
            sphereEntity.addChild(tagged, preservingWorldTransform: false)
            tagged.transform = .init(translation: .init(0, 0, 0.4))
        } catch {
            log.error("\(error.localizedDescription)")
        }
    }
    func update(_ content: inout RealityViewContent, _ attachments: RealityViewAttachments) { }
}
