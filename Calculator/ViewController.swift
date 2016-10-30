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
            return NumberFormatter().number(from: display.text!)?.doubleValue
        }
        set {
            if newValue != nil {
                if newValue!.truncatingRemainder(dividingBy: 1) == 0 {
                    let formatter = NumberFormatter()
                    
                    formatter.numberStyle = NumberFormatter.Style.decimal
                    display.text! = formatter.string(from: newValue! as NSNumber)!
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
    
    
    @IBAction func appendDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if isTypingNewNumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            isTypingNewNumber = true
        }
    }
    
    @IBAction func appendFloatingPoint() {
        let dotPosition = display.text!.range(of: ".")
        if dotPosition == nil {
            display.text = display.text! + "."
            isTypingNewNumber = true
        }
    }
    
    @IBAction func appendVariable(_ sender: UIButton) {
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
        let length = display.text!.characters.count
        if isTypingNewNumber {
            if length == 1{
                displayValue = 0
                isTypingNewNumber = false
            } else {
                display.text!.remove(at: display.text!.index(before:display.text!.endIndex))
            }
        }
    }
    
    @IBAction func changeSign(_ sender: UIButton) {
        if isTypingNewNumber {
            if displayValue! > 0 {
                display.text = "-" + display.text!
            } else {
                if display.text!.range(of: "-") != nil {
                    display.text! = String(display.text!.characters.dropFirst())
                }
            }
        } else {
            if let operation = sender.currentTitle {
                displayValue = calcModel.performOperation(operation)
            }
        }
    }
    
    @IBAction func operate(_ sender: UIButton) {
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

