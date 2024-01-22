//
//  ViewController.swift
//  Counter
//
//  Created by Артём Леонов on 14.01.2024.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Outlets
    
    /// Текстовое поле для отображения истории изменений счётчика.
    @IBOutlet var historyText: UITextView!
    /// Кнопка для уменьшения значения счётчика.
    @IBOutlet var minusButton: UIButton!
    /// Кнопка для увеличения значения счётчика.
    @IBOutlet var plusButton: UIButton!
    /// Кнопка для сброса значения счётчика и истории.
    @IBOutlet var resetButton: UIButton!
    /// Текстовое поле для отображения текущего значения счётчика.
    @IBOutlet var textCount: UILabel!
    
    // MARK: - Свойства
    
    /// Начальное значение счётчика.
    var countNumber: Int = 0
    /// Строка, содержащая историю изменений счётчика.
    var history: String = "История изменений:\n"
    
    // MARK: - Жизненный цикл приложения
    
    /// Вызывается после загрузки viewконтроллера.
    override func viewDidLoad() {
        super.viewDidLoad()
        counterUpdater()
        historyText.text = history
    }
    
    // MARK: - Функции
    
    /// Обновляет историю изменений счётчика.
    /// - Parameter message: Сообщение, описывающее последнее изменение.
    func updateHistory(with message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        history += "[\(dateString)]: \(message)\n"
        historyText.text = history
    }
    
    // Обновляет пользовательский интерфейс с текущим значением счётчика.
    func counterUpdater() {
        textCount.text = "Значение счётчика: \(countNumber)"
    }
    
    /// Вызывается при нажатии на кнопку сброса. Обнуляет счётчик и обновляет историю.
    /// - Parameter sender: Объект, инициирующий действие.
    @IBAction func deleteAll(_ sender: Any) {
        countNumber = 0
        counterUpdater()
        updateHistory(with: "значение сброшено")
    }
    
    /// Увеличивает счётчик на 1 при нажатии на кнопку "+".
    /// - Parameter sender: Объект, инициирующий действие.
    @IBAction func addNumber(_ sender: Any) {
        countNumber += 1
        counterUpdater()
        updateHistory(with: "значение изменено на +1")
    }
    
    /// Уменьшает счётчик на 1 при нажатии на кнопку "-".
    /// - Parameter sender: Объект, инициирующий действие.
    @IBAction func minusNumber(_ sender: Any) {
        if countNumber > 0 {
            countNumber -= 1
            counterUpdater()
            updateHistory(with: "значение изменено на -1")
        } else {
            updateHistory(with: "попытка уменьшить значение счётчика ниже 0")
        }
    }
}
