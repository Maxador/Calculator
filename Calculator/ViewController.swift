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
    @IBOutlet weak var operationDisplay: UILabel!
    
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
                if newValue! % 1 == 0 {
                    let formatter = NSNumberFormatter()
                    formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                    display.text! = formatter.stringFromNumber(newValue!)!
                } else {
                    display.text! = "\(newValue!)"
                }
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
//        if let stack = calcModel.readStack() {
//            operationDisplay.text = stack
//        } else {
//            operationDisplay.text = ""
//        }
    }
    
    @IBAction func backspace() {
        let length = countElements(display.text!)
        if isTypingNewNumber {
            if length == 1{
                displayValue = 0
                isTypingNewNumber = false
            } else {
                display.text = dropLast(display.text!)
            }
        }
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if isTypingNewNumber {
            if displayValue! > 0 {
                display.text = "-" + display.text!
            } else {
                if display.text!.rangeOfString("-") != nil {
                    display.text = dropFirst(display.text!)
                }
            }
        } else {
            if let operation = sender.currentTitle {
                if let result = calcModel.performOperation(operation) {
                    displayValue = result
                } else {
                    displayValue = nil
                }
            }
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
            if let stack = calcModel.readStack() {
                operationDisplay.text = stack
            } else {
                operationDisplay.text = ""
            }
        }
    }
    
    @IBAction func clear() {
        displayValue = 0
        operationDisplay.text = ""
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

