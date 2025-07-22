//
//  Mission.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 10/07/25.
//


import Foundation

struct Mission: Identifiable, Codable, Equatable {
    let id: UUID
    let description: String
    let reward: Int
    let duration: TimeInterval
    var startDate: Date?
    var isCompleted: Bool

    init(description: String, reward: Int, duration: TimeInterval) {
        self.id = UUID()
        self.description = description
        self.reward = reward
        self.duration = duration
        self.startDate = nil
        self.isCompleted = false
    }
    
        static func == (lhs: Mission, rhs: Mission) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.isCompleted == rhs.isCompleted &&
                   lhs.startDate == rhs.startDate
        }

    func timeLeft(from now: Date = Date()) -> TimeInterval? {
        guard let start = startDate else { return nil }
        let end = start.addingTimeInterval(duration)
        return max(0, end.timeIntervalSince(now))
    }
}
