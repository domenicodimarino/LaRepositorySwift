//
//  CarDirection.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 17/07/25.
//


enum CarDirection: String {
    case n, ne, e, se, s, sw, w, nw
    
    static func fromAngle(_ angle: Double) -> CarDirection {
        switch angle {
        case 337.5...360, 0..<22.5: return .n
        case 22.5..<67.5: return .ne
        case 67.5..<112.5: return .e
        case 112.5..<157.5: return .se
        case 157.5..<202.5: return .s
        case 202.5..<247.5: return .sw
        case 247.5..<292.5: return .w
        case 292.5..<337.5: return .nw
        default: return .n
        }
    }
    
    static func fromAvatarDirection(_ avatarDir: AvatarDirection) -> CarDirection {
        switch avatarDir {
        case .up: return .n
        case .right: return .e
        case .down: return .s
        case .left: return .w
        }
    }
}