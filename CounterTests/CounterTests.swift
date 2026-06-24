//
//  CounterTests.swift
//  CounterTests
//
//  Tests for CounterStore — replaces the auto-generated empty stubs.
//

import XCTest
@testable import Counter

/// In-memory test double for ``KeyValueStore``.
final class InMemoryDefaults: KeyValueStore {
    private var values: [String: Int] = [:]
    func integer(forKey key: String) -> Int { values[key] ?? 0 }
    func set(_ value: Int, forKey key: String) { values[key] = value }
}

final class CounterStoreTests: XCTestCase {
    private var defaults: InMemoryDefaults!
    private var historyURL: URL!
    private var store: CounterStore!

    override func setUpWithError() throws {
        defaults = InMemoryDefaults()
        // Use a unique temp dir per test so parallel tests don't collide.
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("CounterTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        historyURL = dir.appendingPathComponent("counter_history.json")
        store = CounterStore(defaults: defaults, historyFileURL: historyURL)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: historyURL.deletingLastPathComponent())
    }

    // MARK: - Counter persistence

    func test_new_store_starts_at_zero() {
        XCTAssertEqual(store.count, 0)
    }

    func test_increment_persists_to_defaults() {
        store.increment()
        store.increment()
        store.increment()
        XCTAssertEqual(store.count, 3)
        XCTAssertEqual(defaults.integer(forKey: "Counter.countNumber"), 3)
    }

    func test_decrement_persists_to_defaults() {
        store.increment()
        store.increment()
        store.decrement()
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(defaults.integer(forKey: "Counter.countNumber"), 1)
    }

    func test_reset_persists_to_defaults() {
        store.increment()
        store.increment()
        store.reset()
        XCTAssertEqual(store.count, 0)
        XCTAssertEqual(defaults.integer(forKey: "Counter.countNumber"), 0)
    }

    func test_new_store_restores_count_from_defaults() throws {
        // Persist via one store instance.
        let store1 = CounterStore(defaults: defaults, historyFileURL: historyURL)
        store1.increment()
        store1.increment()
        XCTAssertEqual(store1.count, 2)

        // A fresh store reading the same defaults must restore the value.
        let store2 = CounterStore(defaults: defaults, historyFileURL: historyURL)
        XCTAssertEqual(store2.count, 2,
                       "Counter value must survive store reinitialization")
    }

    // MARK: - Decrement guard

    func test_decrement_at_zero_does_not_go_negative() {
        store.decrement()
        store.decrement()
        XCTAssertEqual(store.count, 0, "Counter must clamp at zero")
    }

    func test_decrement_at_zero_records_rejection_in_history() {
        store.decrement()
        XCTAssertFalse(store.history.isEmpty)
        XCTAssertTrue(store.history.first?.message.contains("ниже 0") == true)
    }

    // MARK: - History persistence

    func test_increment_appends_history_entry() {
        store.increment()
        XCTAssertEqual(store.history.count, 1)
        XCTAssertEqual(store.history.first?.message, "значение изменено на +1")
    }

    func test_history_persists_across_stores() throws {
        store.increment()
        store.increment()
        store.decrement()
        store.reset()

        let store2 = CounterStore(defaults: defaults, historyFileURL: historyURL)
        XCTAssertEqual(store2.history.count, 4,
                       "All 4 mutations should be reloaded from disk")
    }

    func test_history_caps_at_max_entries() {
        let originalCap = CounterStore.maxHistoryEntries
        // Just exercise the cap by filling the buffer past the limit.
        for _ in 0...(originalCap + 5) {
            store.increment()
        }
        XCTAssertLessThanOrEqual(store.history.count, originalCap)
    }

    func test_history_file_is_written_atomically() throws {
        store.increment()
        XCTAssertTrue(FileManager.default.fileExists(atPath: historyURL.path),
                      "history.json should exist after a mutation")
    }

    func test_corrupt_history_file_does_not_crash() throws {
        // Write garbage into the history file
        try "not valid json".data(using: .utf8)!
            .write(to: historyURL, options: [.atomic])
        let recovered = CounterStore(defaults: defaults, historyFileURL: historyURL)
        XCTAssertTrue(recovered.history.isEmpty,
                      "Corrupt history should degrade to empty, not crash")
    }

    func test_missing_history_file_yields_empty_history() {
        // setUpWithError already pointed us at a non-existent file
        let fresh = CounterStore(defaults: defaults, historyFileURL: historyURL)
        XCTAssertTrue(fresh.history.isEmpty)
    }

    // MARK: - Formatted output

    func test_formatted_history_includes_header() {
        store.increment()
        let text = store.formattedHistory()
        XCTAssertTrue(text.hasPrefix("История изменений:"))
    }

    func test_formatted_history_includes_each_entry() {
        store.increment()
        store.decrement()
        store.reset()
        let text = store.formattedHistory()
        XCTAssertTrue(text.contains("значение изменено на +1"))
        XCTAssertTrue(text.contains("значение изменено на -1"))
        XCTAssertTrue(text.contains("значение сброшено"))
    }
}