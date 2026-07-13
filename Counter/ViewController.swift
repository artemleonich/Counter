//
//  ViewController.swift
//  Counter
//
//  Created by Артём Леонов on 14.01.2024.
//
//  This file was simplified as part of the persistence PR. All state
//  lives in ``CounterStore``; the view controller only renders and
//  forwards taps.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private var historyText: UITextView!
    @IBOutlet private var minusButton: UIButton!
    @IBOutlet private var plusButton: UIButton!
    @IBOutlet private var resetButton: UIButton!
    @IBOutlet private var textCount: UILabel!

    // MARK: - State

    private let store = CounterStore()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        renderCount()
        renderHistory()
        // History view is for display only — see audit finding about
        // users being able to type into the log.
        historyText.isEditable = false
        historyText.isSelectable = true
    }

    // MARK: - Actions

    @IBAction private func deleteAll(_ sender: UIButton) {
        generateFeedback()
        store.reset()
        renderCount()
        renderHistory()
    }

    @IBAction private func addNumber(_ sender: UIButton) {
        generateFeedback()
        store.increment()
        renderCount()
        renderHistory()
    }

    @IBAction private func minusNumber(_ sender: UIButton) {
        generateFeedback()
        store.decrement()
        renderCount()
        renderHistory()
    }

    // MARK: - Rendering

    private func renderCount() {
        textCount.text = "Значение счётчика: \(store.count)"
    }

    private func renderHistory() {
        historyText.text = store.formattedHistory()
    }

    // Cached so the engine is ready to fire instantly on the next tap.
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()

    private func generateFeedback() {
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
    }
}