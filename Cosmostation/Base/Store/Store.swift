//
//  Store.swift
//  Created by Alberto Penas Amor on 18/7/22.
//

import Foundation
import Combine

actor Store<S: State, Action, R: AsyncSequence, ServiceLocator>: ObservableObject where R.Element == S {
    typealias Input = (state: S, action: Action, serviceLocator: ServiceLocator)
    typealias Output = R
    typealias Reducer = (Input) -> Output

    @MainActor @Published private(set) var state: S = .init()
    private let reducer: Reducer
    private let serviceLocator: ServiceLocator

    @MainActor 
    init(reducer: @escaping Reducer, serviceLocator: ServiceLocator, state: S? = nil) {
        self.reducer = reducer
        self.serviceLocator = serviceLocator
        if let state = state {
            self.state = state
        } else {
            self.state = S()
        }
    }

    func dispatch(action: Action) async {
        do {
            let currentState = await state
            let stream = reducer((currentState, action, serviceLocator))
            for try await newState in stream {
                await postState(newState)
            }
        } catch {
            print(error)
        }
    }
    
    @MainActor private func postState(_ newState: S) async {
        state = newState
    }
}
