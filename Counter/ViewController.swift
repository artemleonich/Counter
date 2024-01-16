//
//  ViewController.swift
//  Counter
//
//  Created by Артём Леонов on 14.01.2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButon: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var buttonTouch: UIButton!
    @IBOutlet weak var textCount: UILabel!
    var countNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTrrr()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateButton(_ sender: Any) {
        countNumber += 1
        updateTrrr()
    }
    
    func updateTrrr() {
        textCount.text = "Значение счётчика: \(countNumber)"
    }
    
    @IBAction func deletAll(_ sender: Any) {
        countNumber = 0
        updateTrrr()
    }
    @IBAction func addNumber(_ sender: Any) {
        countNumber += 1
        updateTrrr()
    }
    @IBAction func minusNumber(_ sender: Any) {
        countNumber = max(0, countNumber - 1)
        updateTrrr()
    }
}

