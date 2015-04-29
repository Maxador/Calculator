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
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
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
                display.text! = " "
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
    
    @IBAction func appendVariable(sender: UIButton) {
        if isTypingNewNumber {
            enter()
        }
        displayValue = calcModel.pushOperand(sender.currentTitle!)
    }
    
    @IBAction func setVariableValue() {
        isTypingNewNumber = false
        displayValue = calcModel.pushVariableValue("M", value: displayValue!)
    }
    
    
    @IBAction func enter() {
        isTypingNewNumber = false
        displayValue = calcModel.pushOperand(displayValue!)
    }
    
    @IBAction func backspace() {
        let length = count(display.text!)
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
                displayValue = calcModel.performOperation(operation)
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if isTypingNewNumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = calcModel.performOperation(operation)
            operationDisplay.text = calcModel.description
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

