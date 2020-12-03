import Foundation
import CoreGraphics

public struct Coordinate {
    public let x, y: Int
    public typealias Direction = KeyPath<Coordinate, Coordinate>

    public var right: Coordinate { return Coordinate( x: x + 1, y: y ) }
    public var left: Coordinate { return Coordinate( x: x - 1, y: y ) }
    public var up: Coordinate { return Coordinate( x: x, y: y - 1 ) }
    public var down: Coordinate { return Coordinate( x: x, y: y + 1 ) }
    public var neighbors: [Coordinate] { return [ up, left, right, down ] }

    public func neighbors(limitedBy: Int) -> [Coordinate] {
        return neighbors(limitedBy: limitedBy, and: limitedBy )
    }

    public func neighbors(limitedBy xLimit: Int, and yLimit: Int) -> [Coordinate] {
        return [ left, right, up, down ].filter { $0.isValid( x: xLimit, y: yLimit ) }
    }

    public func isValid( x: Int, y: Int ) -> Bool {
        return self.x >= 0 && self.x < x && self.y >= 0 && self.y < y
    }

    public func neighbors( limitedBy: Int, traveling: Direction ) -> [Coordinate] {
        switch traveling {
        case \Coordinate.down, \Coordinate.up:
            return [ left, right ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
        case \Coordinate.left, \Coordinate.right:
            return [ down, up ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
        default: fatalError()
        }
    }

    public func neighbors8( limitedBy: Int ) -> [Coordinate] {
        return [ left, right, up, down, left.up, right.up, left.down, right.down ].filter { $0.isValid(x: limitedBy, y: limitedBy) }
    }

    public func direction(to: Coordinate) -> Direction {
        if abs(self.x - to.x) > abs(self.y - to.y) {
            return self.x > to.x ? \Coordinate.left : \Coordinate.right
        } else {
            return self.y > to.y ? \Coordinate.up : \Coordinate.down
        }
    }

    public init( x: Int, y: Int ) {
        self.x = x
        self.y = y
    }
}

public extension Coordinate {
    static func turn(left: Direction) -> Direction {
        switch left {
        case \Coordinate.down: return \Coordinate.right
        case \Coordinate.up: return \Coordinate.left
        case \Coordinate.right: return \Coordinate.up
        case \Coordinate.left: return \Coordinate.down
        default: return left
        }
    }
    static func turn(right: Direction) -> Direction {
        switch right {
        case \Coordinate.down: return \Coordinate.left
        case \Coordinate.up: return \Coordinate.right
        case \Coordinate.right: return \Coordinate.down
        case \Coordinate.left: return \Coordinate.up
        default: return right
        }
    }
    static func turn(around: Direction) -> Direction {
        switch around {
        case \Coordinate.down: return \Coordinate.up
        case \Coordinate.up: return \Coordinate.down
        case \Coordinate.right: return \Coordinate.left
        case \Coordinate.left: return \Coordinate.right
        default: return around
        }
    }
}

public struct Grid<T>: Sequence {

    public struct CoordinateIterator: Sequence, IteratorProtocol {
        let maxX, maxY: Int
        var coordinate: Coordinate

        public mutating func next() -> Coordinate? {
            if !coordinate.isValid( x: maxX, y: maxY ) {
                coordinate = Coordinate(x: 0, y: coordinate.y+1)
            }
            guard coordinate.isValid( x: maxX, y: maxY ) else { return nil }
            defer { coordinate = coordinate.right }

            return coordinate
        }
    }

    public struct Iterator: IteratorProtocol {
        let grid: Grid
        var iterator: CoordinateIterator

        public mutating func next() -> T? {
            guard let coordinate = iterator.next() else { return nil }
            return grid[ coordinate ]
        }
    }

    public typealias Element = T
    var grid: [Element]
    public let maxX: Int
    public let maxY: Int
    let transform: CGAffineTransform

    public subscript( x x: Int, y y: Int ) -> Element {
        get { grid[ y * maxX + x ] }
        set { grid[ y * maxX + x ] = newValue }
    }

    public subscript( _ c: Coordinate ) -> Element {
        get { self[ x: c.x, y: c.y ] }
        set { self[ x: c.x, y: c.y ] = newValue }
    }

    public subscript( x x: CountableRange<Int>, y y: CountableRange<Int>) -> Grid<Element>? {
        return Grid( zip( y, repeatElement( x, count: y.count ) ).lazy.flatMap{ outer in outer.1.map { inner in self[ x: inner, y: outer.0 ] } }, maxX: x.count, maxY: y.count, transform: .identity )
    }

    public init?<S: Sequence>( _ input: S, maxX: Int, maxY: Int, transform: CGAffineTransform = .identity ) where S.Element == Element {
        self.grid = Array(input)
        self.maxX = maxX
        self.maxY = maxY
        self.transform = transform

        guard grid.count == maxX * maxY else { return nil }
    }

    public func makeIterator() -> Iterator {
        return Iterator(grid: self, iterator: CoordinateIterator(maxX: maxX, maxY: maxY, coordinate: Coordinate(x: 0, y: 0)))
    }

    public var indices: CoordinateIterator {
        return CoordinateIterator(maxX: maxX, maxY: maxY, coordinate: Coordinate(x: 0, y: 0))
    }

    public mutating func copy( grid: Grid<T>, origin: Coordinate ) {
        for y in origin.y..<(origin.y+grid.maxY) {
            for x in origin.x..<(origin.x+grid.maxX) {
                self[x: x, y: y] = grid[x: x - origin.x, y: y - origin.y]
            }
        }
    }
}

extension Grid where Grid.Element: Equatable {
    public static func ==(lhs: Grid, rhs: Grid) -> Bool {
        guard lhs.maxX == rhs.maxX, lhs.maxY == rhs.maxY else { return false }
        return lhs.elementsEqual( rhs )
    }
}

extension Grid: CustomStringConvertible where Element: CustomStringConvertible {
    public var description: String {
        var result = ""
        for y in 0..<maxY {
            for x in 0..<maxX {
                result.append( self[x: x, y: y].description )
            }
            result.append("\n")
        }
        return result
    }
}

extension Coordinate: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension Coordinate: CustomStringConvertible {
    public var description: String {
        return "(\(x), \(y))"
    }
}

extension Coordinate: Comparable {
    public static func <(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.y == rhs.y ? lhs.x < rhs.x : lhs.y < rhs.y
    }
}

extension Coordinate: Equatable {
    public static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.y == rhs.y && lhs.x == rhs.x
    }
}
