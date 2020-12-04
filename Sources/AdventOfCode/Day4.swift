
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

extension CaseIterable where AllCases.Element: RawRepresentable, AllCases.Element.RawValue == String {
    static var parser: Parser<Character, AllCases.Element> {
        return allCases.reduce(
            Parser { throw ParseError.Mismatch($0, String(describing: self), String(describing: $0)) }
        ) { accum, val in
            (string(val.rawValue) >>- { _ in pure(val) }) <|> accum
        }
    }
}

struct Day4: ParsableCommand {
    enum Key: String, CaseIterable {
        case byr, iyr, eyr, hgt, hcl, ecl, pid, cid

        var parser: Parser<Character, Value> {
            switch self {
            case .byr: return Value.byr <^> integer
            case .iyr: return Value.iyr <^> integer
            case .eyr: return Value.eyr <^> integer
            case .hgt: return curry { Value.hgt($0, $1) }
                <^> integer <*> (string("in") <|> string("cm"))
            case .hcl: return Value.hcl <^> ( extend <^> char("#") <*> count(6, oneOf("0123456789abcdef")))
            case .ecl: return Value.ecl <^> Value.EyeColor.parser
            case .pid: return Value.pid <^> count(9, oneOf("0123456789"))
            case .cid: return Value.cid <^> oneOrMore(any())
            }
        }
    }

    enum Value {
        enum EyeColor: String, CaseIterable {
            case amb, blu, brn, gry, grn, hzl, oth
        }

        case byr(Int), iyr(Int), eyr(Int)
        case hgt(Int, String)
        case hcl(String)
        case ecl(EyeColor)
        case pid(String)
        case cid(String)

        var isValid: Bool {
            switch self {
            case .byr(let year): return (1920...2002).contains(year)
            case .iyr(let year): return (2010...2020).contains(year)
            case .eyr(let year): return (2020...2030).contains(year)
            case .hgt(let val, "cm"): return (150...193).contains(val)
            case .hgt(let val, "in"): return (59...76).contains(val)
            case .hgt: return false
            case .hcl, .ecl, .pid, .cid: return true
            }
        }
    }

    static let parser =
        oneOrMore(
            oneOrMore(
                (
                    curry { ($0, $1) } <^>
                        ( Key.parser <* char(":") ) <*> oneOrMore(noneOf([" ", "\n"]))
                )
                <* oneOf(" \n")
            ) <* optional(char("\n"))
        )

    static let input = Array(stdin)

    func run() {
        let data = try! FootlessParser.parse(Self.parser, Self.input.joined(separator: "\n") + "\n").map(Dictionary<Key, String>.init(uniqueKeysWithValues:))

        let part1 = data
            .filter { passport in
                Key.allCases.filter { $0 != .cid }.allSatisfy { passport[$0] != nil }
            }

        print("Part 1", part1.count)

        let part2 = part1
            .filter { passport in
                passport.allSatisfy {
                    (try? FootlessParser.parse($0.key.parser, $0.value))?.isValid == true
                }
            }

        print("Part 2", part2.count)
    }
}
