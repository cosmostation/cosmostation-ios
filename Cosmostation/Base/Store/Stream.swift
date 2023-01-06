//
//  Stream.swift
//  Created by Alberto Penas Amor on 17/7/22.
//

import Foundation

struct Stream<T>: AsyncSequence {
    typealias Element = T
    typealias Next = () async -> Element?

    private let iterator: StreamIterator<T>

    init() {
        self.iterator = StreamIterator()
    }

    init(item: @escaping Next) {
        self.iterator = StreamIterator(item: item)
    }

    init(items: [Next]) {
        self.iterator = StreamIterator(items: items)
    }

    func makeAsyncIterator() -> StreamIterator<T> {
        return iterator
    }
}

extension Stream {
    struct StreamIterator<T>: AsyncIteratorProtocol {
        typealias Element = T

        private var items: [Stream<T>.Next]

        init() {
            self.items = []
        }

        init(item: @escaping Stream<T>.Next) {
            self.items = [item]
        }

        init(items: [Stream<T>.Next]) {
            self.items = items
        }

        mutating func next() async -> Element? {
            guard !Task.isCancelled else {
                return nil
            }
            if items.isEmpty {
                return nil
            }
            let item = items.removeFirst()
            let result = await item()
            return result
        }
    }
}
