//
//  HistoryEntry.swift
//  Counter
//
//  One entry in the counter history log. Replaces the previous append-only
//  String buffer so the history can be persisted, capped, and inspected
//  without parsing.
//

import Foundation

struct HistoryEntry: Codable, Equatable {
    /// When the change happened.
    let date: Date
    /// Human-readable description, e.g. "значение изменено на +1".
    let message: String

    init(date: Date = Date(), message: String) {
        self.date = date
        self.message = message
    }
}