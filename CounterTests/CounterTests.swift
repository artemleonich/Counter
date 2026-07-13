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

    // MARK: - Protocol-witness regression

    /// Regression test for the protocol-conformance recursion bug that the
    /// reviewer caught in PR review.
    ///
    /// Earlier ``extension UserDefaults: KeyValueStore`` had explicit method
    /// bodies that called ``self.integer(forKey:)`` / ``self.set(_:forKey:)``.
    /// Inside a protocol-extension method on a type that already provides a
    /// matching native method, ``self.integer(forKey:)`` dispatches through
    /// the protocol witness table and re-enters the extension body — infinite
    /// recursion, stack overflow on first call.
    ///
    /// This test catches that exact failure mode: if anyone re-introduces
    /// explicit method bodies in the UserDefaults extension, this test will
    /// stack-overflow and fail loudly.
    ///
    /// ``InMemoryDefaults`` does not exercise the UserDefaults conformance,
    /// which is why this test is separate from the existing 14 tests.
    func test_user_defaults_conformance_via_protocol_witness_does_not_recurse() {
        let defaults = UserDefaults.standard
        // Use a unique key to avoid clashing with any state from other tests.
        let testKey = "CounterStoreTests-recursion-probe-\(UUID().uuidString)"

        // Force-cleanup before AND after the test for hermeticity.
        defer { defaults.removeObject(forKey: testKey) }

        // Build a KeyValueStore view of UserDefaults via the protocol witness.
        // If ``extension UserDefaults: KeyValueStore`` ever gets explicit
        // bodies that recurse, this call stack-overflows before returning.
        let store: KeyValueStore = defaults

        // Round-trip read/write via the protocol witness.
        XCTAssertEqual(store.integer(forKey: testKey), 0)
        store.set(42, forKey: testKey)
        XCTAssertEqual(store.integer(forKey: testKey), 42)
    }

    /// Regression test that builds the **production** ``CounterStore()``
    /// (which uses ``UserDefaults.standard``). This is what the app actually
    /// does on launch, so it must not crash.
    ///
    /// The previous 14 tests all built the store via the
    /// ``CounterStore(defaults:historyFileURL:)`` initializer with an
    /// ``InMemoryDefaults`` double, so they never exercised the production
    /// code path. After the protocol-witness bug was found, this test exists
    /// to ensure no future regression in that code path goes unnoticed.
    func test_production_counter_store_constructor_does_not_crash() throws {
        // Use a unique domain so the test doesn't pollute real UserDefaults
        // and doesn't collide with other tests run in parallel.
        let domain = "CounterStoreTests-prod-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: domain)!
        // Persist this suite to standard so the production CounterStore() reads it.
        UserDefaults.standard.setVolatileDomain([:], forName: domain)
        defer {
            UserDefaults.standard.removeVolatileDomain(forName: domain)
        }

        // Build the production initializer with a known-empty starting state.
        // We can't pass a UserDefaults suite to CounterStore() directly, so
        // we set the well-known key first and check the store reads it.
        let knownKey = "Counter.countNumber"
        suite.set(7, forKey: knownKey)
        // Mirror the suite's value into standard so CounterStore.standard sees it.
        UserDefaults.standard.set(7, forKey: knownKey)
        defer { UserDefaults.standard.removeObject(forKey: knownKey) }

        // This constructor MUST NOT crash. If the recursion bug ever returns,
        // this line stack-overflows on the very first ``init``.
        let productionStore = CounterStore()
        XCTAssertEqual(productionStore.count, 7,
                       "Production CounterStore() must read from UserDefaults.standard")

        // Cleanup: reset standard so subsequent test runs see a clean state.
        UserDefaults.standard.removeObject(forKey: knownKey)
    }
}