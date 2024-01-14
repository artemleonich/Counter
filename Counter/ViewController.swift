//
//  ViewController.swift
//  Counter
//
//  Created by Артём Леонов on 14.01.2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var countButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func clickButton(_ sender: Any) {
        print("Нажатие")
    }
    
}

