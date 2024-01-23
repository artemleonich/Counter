//
//  ViewController.swift
//  Counter
//
//  Created by Артём Леонов on 14.01.2024.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Outlets
    
    /// Начальное значение счётчика.
    private var countNumber: Int = 0
    /// Строка, содержащая историю изменений счётчика.
    private var history: String = "История изменений:\n"
    
    /// Текстовое поле для отображения истории изменений счётчика.
    @IBOutlet private var historyText: UITextView!
    /// Кнопка для уменьшения значения счётчика.
    @IBOutlet private var minusButton: UIButton!
    /// Кнопка для увеличения значения счётчика.
    @IBOutlet private var plusButton: UIButton!
    /// Кнопка для сброса значения счётчика и истории.
    @IBOutlet private var resetButton: UIButton!
    /// Текстовое поле для отображения текущего значения счётчика.
    @IBOutlet private var textCount: UILabel!
    
    // MARK: - Свойства
    
    // MARK: - Жизненный цикл приложения
    
    /// Вызывается после загрузки view контроллера.
    override func viewDidLoad() {
        super.viewDidLoad()
        counterUpdater()
        historyText.text = history
    }
    
    // MARK: - Функции
    
    /// Обновляет историю изменений счётчика.
    /// - Parameter message: Сообщение, описывающее последнее изменение.
    private func updateHistory(with message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        history += "[\(dateString)]: \(message)\n"
        historyText.text = history
    }
    
    // Обновляет пользовательский интерфейс с текущим значением счётчика.
    private func counterUpdater() {
        textCount.text = "Значение счётчика: \(countNumber)"
    }
    
    // Добавляет вибро-отклик кнопкам.
    private func generateFeedback() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()
    }
    
    /// Вызывается при нажатии на кнопку сброса. Обнуляет счётчик и обновляет историю.
    /// - Parameter sender: Объект, инициирующий действие.
    @IBAction private func deleteAll(_ sender: Any) {
        generateFeedback()
        countNumber = 0
        counterUpdater()
        updateHistory(with: "значение сброшено")
    }
    
    /// Увеличивает счётчик на 1 при нажатии на кнопку "+".
    /// - Parameter sender: Объект, инициирующий действие.
    @IBAction private func addNumber(_ sender: Any) {
        generateFeedback()
        countNumber += 1
        counterUpdater()
        updateHistory(with: "значение изменено на +1")
    }
    
    /// Уменьшает счётчик на 1 при нажатии на кнопку "-".
    /// - Parameter sender: Объект, инициирующий действие.
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
}
