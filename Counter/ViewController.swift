//
//  ViewController.swift
//  Counter
//
//  Created by Артём Леонов on 14.01.2024.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private var historyText: UITextView!
    @IBOutlet private var minusButton: UIButton!
    @IBOutlet private var plusButton: UIButton!
    @IBOutlet private var resetButton: UIButton!
    @IBOutlet private var textCount: UILabel!

    // MARK: - Свойства

    private var countNumber: Int = 0
    private var history: String = "История изменений:\n"

    // MARK: - Жизненный цикл

    override func viewDidLoad() {
        super.viewDidLoad()
        counterUpdater()
        historyText.text = history
    }

    // MARK: - Действия

    @IBAction private func addNumber(_ sender: Any) {
        generateFeedback()
        countNumber += 1
        counterUpdater()
        updateHistory(with: "значение изменено на +1")
    }

    @IBAction private func minusNumber(_ sender: Any) {
        generateFeedback()
        if countNumber > 0 {
            countNumber -= 1
            counterUpdater()
            updateHistory(with: "значение изменено на -1")
        } else {
            updateHistory(with: "попытка уменьшить значение счётчика ниже 0")
        }
    }

    @IBAction private func deleteAll(_ sender: Any) {
        generateFeedback()
        countNumber = 0
        counterUpdater()
        updateHistory(with: "значение сброшено")
    }

    // MARK: - Приватные методы

    private func counterUpdater() {
        textCount.text = "Значение счётчика: \(countNumber)"
    }

    private func updateHistory(with message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        history += "[\(dateString)]: \(message)\n"
        historyText.text = history
    }

    private func generateFeedback() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()
    }
}
