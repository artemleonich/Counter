//
//  CounterStore.swift
//  Counter
//
//  Persistence layer for the counter app. Replaces the previous
//  in-memory-only ``ViewController.countNumber`` / ``history: String`` —
//  those were wiped on every app relaunch, making the "history log"
//  feature non-functional across launches.
//
//  Design notes:
//  - The current counter value is stored in UserDefaults (small Int,
//    frequent reads — UserDefaults is the right place).
//  - The history log is stored as a JSON file in Application Support
//    rather than UserDefaults. UserDefaults is for small preferences;
//    a long history would bloat plist backups and slow saves.
//  - The history is capped at ``maxHistoryEntries`` (oldest entries
//    drop off). This prevents the unbounded growth flagged by the
//    audit — a user who taps the button 10 000 times will not end
//    up with a multi-MB scrollback.
//  - A protocol-injected ``UserDefaults`` and file URL make the store
//    unit-testable without touching the real on-disk store.
//

import Foundation

/// Abstract storage contract so tests can inject an in-memory implementation.
protocol KeyValueStore {
    func integer(forKey key: String) -> Int
    func set(_ value: Int, forKey key: String)
}

// ``UserDefaults`` already provides ``integer(forKey:)`` and ``set(_:forKey:)``
// with exactly the required signatures, so we get conformance for free by
// declaring the protocol adoption with an empty extension body.
//
// IMPORTANT — DO NOT add explicit method bodies here. Earlier versions of
// this file did:
//
//   extension UserDefaults: KeyValueStore {
//       func integer(forKey key: String) -> Int { self.integer(forKey: key) }
//       func set(_ value: Int, forKey key: String) { self.set(value, forKey: key) }
//   }
//
// which appears harmless but is actually infinitely recursive: inside the
// body of a protocol-extension method, ``self.integer(forKey:)`` dispatches
// through the protocol witness table and re-enters the extension method
// instead of calling ``UserDefaults.integer(forKey:)``. Production
// ``CounterStore()`` (which uses ``UserDefaults.standard``) would stack
// overflow on the very first ``init`` — i.e. on app launch.
//
// The regression test in ``CounterTests/CounterTests.swift`` exercises this
// conformance via the protocol witness so this class of bug cannot be
// re-introduced silently.
extension UserDefaults: KeyValueStore {}

final class CounterStore {
    /// User-facing cap; oldest entries are dropped when this is exceeded.
    static let maxHistoryEntries = 1000

    private enum DefaultsKey {
        static let counter = "Counter.countNumber"
    }

    /// Where history.json lives. Tests override this to use a temp dir.
    let historyFileURL: URL

    private let defaults: KeyValueStore

    private(set) var count: Int {
        didSet { defaults.set(count, forKey: DefaultsKey.counter) }
    }

    private(set) var history: [HistoryEntry] {
        didSet { persistHistory() }
    }

    /// Designated initializer for production code.
    convenience init() {
        // Application Support is the iOS-recommended location for
        // app-managed data that should not be exposed to the user via
        // iTunes File Sharing. Use it when available; fall back to the
        // temporary directory in the unlikely event Application Support
        // is not accessible.
        let fileManager = FileManager.default
        let directory: URL
        if let appSupport = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) {
            directory = appSupport
        } else {
            directory = fileManager.temporaryDirectory
        }
        self.init(
            defaults: UserDefaults.standard,
            historyFileURL: directory.appendingPathComponent("counter_history.json")
        )
    }

    init(defaults: KeyValueStore, historyFileURL: URL) {
        self.defaults = defaults
        self.historyFileURL = historyFileURL
        self.count = defaults.integer(forKey: DefaultsKey.counter)
        self.history = Self.loadHistory(from: historyFileURL)
    }

    // MARK: - Mutations

    func increment() {
        count += 1
        append(message: "значение изменено на +1")
    }

    func decrement() {
        guard count > 0 else {
            append(message: "попытка уменьшить значение счётчика ниже 0")
            return
        }
        count -= 1
        append(message: "значение изменено на -1")
    }

    func reset() {
        count = 0
        append(message: "значение сброшено")
    }

    /// Test/debug helper: wipe all persisted state.
    func clearAll() {
        count = 0
        history.removeAll()
    }

    /// Format the history as a single string for display in the (currently
    /// read-only) UITextView. Uses a cached formatter to avoid re-creating
    /// DateFormatter on every update — see audit finding about per-tap
    /// allocations.
    func formattedHistory(now: Date = Date()) -> String {
        guard !history.isEmpty else { return "История изменений:\n" }
        let formatter = Self.dateFormatter
        let lines = history.map { entry in
            "[\(formatter.string(from: entry.date))]: \(entry.message)"
        }
        return "История изменений:\n" + lines.joined(separator: "\n") + "\n"
    }

    // MARK: - Private

    private func append(message: String) {
        history.append(HistoryEntry(date: Date(), message: message))
        if history.count > Self.maxHistoryEntries {
            history.removeFirst(history.count - Self.maxHistoryEntries)
        }
    }

    private func persistHistory() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(history)
            try data.write(to: historyFileURL, options: [.atomic])
        } catch {
            // Persistence is best-effort. We surface the failure via
            // os_log so it shows up in Console.app without crashing
            // the app — a crash here would be far worse UX than losing
            // one history entry.
            // The optional next PR (logging/monitoring) will replace
            // this with a structured logger.
            NSLog("CounterStore: failed to persist history: %@", String(describing: error))
        }
    }

    private static func loadHistory(from url: URL) -> [HistoryEntry] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([HistoryEntry].self, from: data)) ?? []
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "ru_RU_POSIX")
        return formatter
    }()
}