//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Maxime Mongeau on 2015-03-17.
//  Copyright (c) 2015 Maxime Mongeau. All rights reserved.
//

import Foundation

class CalculatorModel: CustomStringConvertible {
    
    fileprivate enum Op: CustomStringConvertible {
        case operand(Double)
        case unaryOperation(String, (Double) -> Double)
        case binaryOperation(String, Int, (Double, Double) -> Double)
        case constant(String, Double)
        case variable(String)
        
        var description: String {
            switch self {
            case .operand(let operand):
                return "\(operand)"
            case .unaryOperation(let symbol, _):
                return symbol
            case .binaryOperation(let symbol, _, _):
                return symbol
            case .constant(let symbol, _):
                return symbol
            case .variable(let symbol):
                return symbol
            }
        }
    }
    
    var description: String {
        var (result, remainder) = describe(opStack, previousPriority:Int.min)
        if remainder.isEmpty {
            result!.insert(contentsOf: " =".characters, at: result!.endIndex)
        }
        while !remainder.isEmpty {
            result!.insert(contentsOf: ", ".characters, at: result!.startIndex)
            var (desc, newRemainder) = describe(remainder, previousPriority:Int.min)
            result!.insert(contentsOf: desc!.characters, at: result!.startIndex)
            remainder = newRemainder
        }
        return result!
    }
    
    fileprivate var opStack = [Op]()
    fileprivate var knownOps = [String:Op]()
    fileprivate var variablesValues = [String:Double]()
    
    init() {
        func learnOp(_ op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.binaryOperation("×", Int.max, *))
        learnOp(Op.binaryOperation("÷", Int.max){$1 / $0})
        learnOp(Op.binaryOperation("+", 0, +))
        learnOp(Op.binaryOperation("−", 0){$1 - $0})
        learnOp(Op.unaryOperation("sin", sin))
        learnOp(Op.unaryOperation("cos", cos))
        learnOp(Op.unaryOperation("√", sqrt))
        // To have a different symbol in the equation display
        knownOps["±"] = Op.unaryOperation("-"){$0 * -1}
        learnOp(Op.constant("π", M_PI))
    }
    
    fileprivate func describe(_ ops: [Op], previousPriority: Int) -> (description: String?, remainingOps:[Op]) {
        if !ops.isEmpty {
            var remainingOperations = ops
            let op = remainingOperations.removeLast()
            switch op {
            case .operand(let operand):
                return ("\(operand)", remainingOperations)
            case .unaryOperation(let symbol, _):
                let opDescription = describe(remainingOperations, previousPriority:Int.min)
                let operand = opDescription.description ?? "?"
                return ("\(symbol)(\(operand))", opDescription.remainingOps)
            case .binaryOperation(let symbol, let priority, _):
                let opDescription1 = describe(remainingOperations, previousPriority:priority)
                if let operand1 = opDescription1.description {
                    let opDescription2 = describe(opDescription1.remainingOps, previousPriority: priority)
                    var returnString = "\(operand1) \(symbol) "
                    let operand2 = opDescription2.description ?? "?"
                    returnString.insert(contentsOf: operand2.characters, at: returnString.endIndex)
                    if previousPriority > priority {
                        returnString.insert(contentsOf: "(".characters, at: returnString.startIndex)
                        returnString.insert(contentsOf: ")".characters, at: returnString.endIndex)
                    }
                    return (returnString, opDescription2.remainingOps)
                }
            case .constant(let symbol, _):
                return (symbol, remainingOperations)
            case .variable(let symbol):
                return (symbol, remainingOperations)
            }
        }
        return (nil, ops)
    }
    
    fileprivate func evaluate(_ ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOperations = ops
            let op = remainingOperations.removeLast()
            switch op {
            case .operand(let operand):
                return (operand, remainingOperations)
            case .unaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOperations)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .binaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOperations)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
                
            case .constant(_, let value):
                return (value, remainingOperations)
            case .variable(let symbol):
                return (variablesValues[symbol], remainingOperations)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        return result
    }
    
    func pushOperand(_ operand: Double) -> Double? {
        opStack.append(Op.operand(operand))
        return evaluate()
    }
    
    func pushOperand(_ symbol: String) -> Double? {
        opStack.append(Op.variable(symbol))
        return evaluate()
    }
    
    func pushVariableValue(_ symbol:String, value: Double) -> Double? {
        variablesValues[symbol] = value
        return evaluate()
    }
    
    func performOperation(_ symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearOperand() {
        opStack = [Op]()
        variablesValues = [String:Double]()
    }
}
