//
//  ViewController.swift
//  Counter
//
//  Created by Артём Леонов on 14.01.2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var historyText: UITextView!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var plusButon: UIButton!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var buttonTouch: UIButton!
    @IBOutlet var textCount: UILabel!
    var countNumber: Int = 0
    var history: String = "История изменений:\n"

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTrrr()
        historyText.text = history

        // Do any additional setup after loading the view.
    }

    @IBAction func updateButton(_ sender: Any) {
        countNumber += 1
        updateTrrr()
    }

    func updateHistory(with message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        history += "[\(dateString)]: \(message)\n"
        historyText.text = history
    }

    func updateTrrr() {
        textCount.text = "Значение счётчика: \(countNumber)"
    }

    @IBAction func deletAll(_ sender: Any) {
        countNumber = 0
        updateTrrr()
        updateHistory(with: "значение сброшено")
    }

    @IBAction func addNumber(_ sender: Any) {
        countNumber += 1
        updateTrrr()
        updateHistory(with: "значение изменено на +1")
    }

    @IBAction func minusNumber(_ sender: Any) {
        if countNumber > 0 {
            countNumber -= 1
            updateTrrr()
            updateHistory(with: "значение изменено на -1")
        } else {
            // Здесь countNumber уже равен 0, и пользователь пытается уменьшить его еще больше
            updateHistory(with: "попытка уменьшить значение счётчика ниже 0")
        }
    }
}
