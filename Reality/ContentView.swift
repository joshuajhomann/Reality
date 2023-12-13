//
//  ContentView.swift
//  Reality
//
//  Created by Joshua Homann on 11/18/23.
//

import OSLog
import SwiftUI
import RealityKit
import RealityKitContent

let log = Logger(subsystem: "com.josh.example", category: "error")

@MainActor
struct ContentView: View {
    @State private var viewModel: ViewModel
    @State private var game: Game
    init() {
        let viewModel = ViewModel()
        _viewModel = .init(wrappedValue: viewModel)
        _game = .init(wrappedValue: .init(viewModel: viewModel))
    }
    var body: some View {
        TimelineView(.animation) { context in
            VStack {
                RealityView(
                    make: game.make(_:_:),
                    update: game.update(_:_:),
                    placeholder: { ProgressView() },
                    attachments: {
                        Attachment(id: ViewModel.Tag.label) {
                            Toggle("Enlarge RealityView Content", isOn: $viewModel.enlarge)
                                .toggleStyle(.button)
                        }
                    }
                )
                    .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { game.move($0.entity) })
                Text(context.date.timeIntervalSince(viewModel.initialTime).formatted())
                    .font(.extraLargeTitle2)
                    .padding()
                    .glassBackgroundEffect()
            }
        }
    }
}

@MainActor
@Observable
final class ViewModel {
    var enlarge = false
    var initialTime = Date()
}

extension ViewModel {
    enum Tag: Hashable {
        case label
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
