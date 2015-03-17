//
//  ViewController.swift
//  Calculator
//
//  Created by Maxime Mongeau on 2015-03-16.
//  Copyright (c) 2015 Maxime Mongeau. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var display: UILabel!
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text! = "\(newValue)"
            isTypingNewNumber = false
        }
    }
    
    var isTypingNewNumber = false
    var calcModel = CalculatorModel()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if isTypingNewNumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            isTypingNewNumber = true
        }
    }
    
    
    @IBAction func enter() {
        isTypingNewNumber = false
        if let result = calcModel.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if isTypingNewNumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = calcModel.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

