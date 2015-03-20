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
    
    var displayValue: Double? {
        get {
            if let value = NSNumberFormatter().numberFromString(display.text!) {
                return value.doubleValue
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                display.text! = "\(newValue!)"
            } else {
                display.text! = "Err"
            }
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
    
    @IBAction func appendFloatingPoint() {
        let dotPosition = display.text!.rangeOfString(".")
        if dotPosition == nil {
            display.text = display.text! + "."
            isTypingNewNumber = true
        }
    }
    
    @IBAction func enter() {
        isTypingNewNumber = false
        if displayValue != nil {
            if let result = calcModel.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = nil
            }
        } else {
            displayValue = nil
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
                displayValue = nil
            }
        }
    }
    @IBAction func clear() {
        display.text = "0"
        isTypingNewNumber = false
        calcModel.clearOperand()
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

