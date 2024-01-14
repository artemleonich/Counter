//
//  ViewController.swift
//  Counter
//
//  Created by Артём Леонов on 14.01.2024.
//

import UIKit

class ViewController: UIViewController {
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
    
}

