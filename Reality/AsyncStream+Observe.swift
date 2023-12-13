//
//  AsyncStream+Observe.swift
//  Reality
//
//  Created by Joshua Homann on 12/13/23.
//

import Foundation

extension AsyncStream {
    init<Base: AnyObject>(observing base: Base, keyPath: KeyPath<Base, Element>) {
        let (output, input) = Self.makeStream(of: Element.self, bufferingPolicy: .bufferingNewest(1))
        self = output
        @Sendable
        func subscribe() {
            input.yield(withObservationTracking {
                base[keyPath: keyPath]
            } onChange: { [weak base] in
                DispatchQueue.main.async { [weak base] in
                    guard let base else { return }
                    input.yield(base[keyPath: keyPath])
                    subscribe()
                }
            })
        }
        subscribe()
    }
}
