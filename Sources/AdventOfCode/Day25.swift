
import Foundation
import ArgumentParser
import Algorithms

struct Day25: ParsableCommand {
    static let cardPublicKey = 10943862
    static let doorPublicKey = 12721030

    func loop(subject: Int, target: Int) -> Int {
        var value = 1
        for m in 1... {
            value *= subject
            value %= 20201227

            if value == target { return m }
        }

        fatalError()
    }

    func loop(subject: Int, loopSize: Int) -> Int {
        var value = 1
        for _ in 1...loopSize {
            value *= subject
            value %= 20201227
        }

        return value
    }


    func run() {
        let cardLoopSize = loop(subject: 7, target: Self.cardPublicKey)

        print("CardLoopSize:", cardLoopSize)
        let encryptionKey = loop(subject: Self.doorPublicKey, loopSize: cardLoopSize)
        print("Part 1", encryptionKey)
    }
}
