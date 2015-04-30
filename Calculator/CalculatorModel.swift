//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Maxime Mongeau on 2015-03-17.
//  Copyright (c) 2015 Maxime Mongeau. All rights reserved.
//

import Foundation

class CalculatorModel: Printable {
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)
        case Constant(String, Double)
        case Variable(String)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _, _):
                return symbol
            case .Constant(let symbol, _):
                return symbol
            case .Variable(let symbol):
                return symbol
            }
        }
    }
    
    var description: String {
        var (result, remainder) = describe(opStack, previousPriority:Int.min)
        if remainder.isEmpty {
            result!.splice(" =", atIndex: result!.endIndex)
        }
        while !remainder.isEmpty {
            result!.splice(", ", atIndex: result!.startIndex)
            var (desc, newRemainder) = describe(remainder, previousPriority:Int.min)
            result!.splice(desc!, atIndex: result!.startIndex)
            remainder = newRemainder
        }
        return result!
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    private var variablesValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", Int.max, *))
        learnOp(Op.BinaryOperation("÷", Int.max){$1 / $0})
        learnOp(Op.BinaryOperation("+", 0, +))
        learnOp(Op.BinaryOperation("−", 0){$1 - $0})
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("√", sqrt))
        // To have a different symbol in the equation display
        knownOps["±"] = Op.UnaryOperation("-"){$0 * -1}
        learnOp(Op.Constant("π", M_PI))
    }
    
    private func describe(ops: [Op], previousPriority: Int) -> (description: String?, remainingOps:[Op]) {
        if !ops.isEmpty {
            var remainingOperations = ops
            let op = remainingOperations.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOperations)
            case .UnaryOperation(let symbol, _):
                let opDescription = describe(remainingOperations, previousPriority:Int.min)
                let operand = opDescription.description ?? "?"
                return ("\(symbol)(\(operand))", opDescription.remainingOps)
            case .BinaryOperation(let symbol, let priority, _):
                let opDescription1 = describe(remainingOperations, previousPriority:priority)
                if let operand1 = opDescription1.description {
                    let opDescription2 = describe(opDescription1.remainingOps, previousPriority: priority)
                    var returnString = "\(operand1) \(symbol) "
                    let operand2 = opDescription2.description ?? "?"
                    returnString.splice(operand2, atIndex: returnString.endIndex)
                    if previousPriority > priority {
                        returnString.splice("(", atIndex: returnString.startIndex)
                        returnString.splice(")", atIndex: returnString.endIndex)
                    }
                    return (returnString, opDescription2.remainingOps)
                }
            case .Constant(let symbol, _):
                return (symbol, remainingOperations)
            case .Variable(let symbol):
                return (symbol, remainingOperations)
            }
        }
        return (nil, ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOperations = ops
            let op = remainingOperations.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOperations)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOperations)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOperations)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
                
            case .Constant(_, let value):
                return (value, remainingOperations)
            case .Variable(let symbol):
                return (variablesValues[symbol], remainingOperations)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder)")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushVariableValue(symbol:String, value: Double) -> Double? {
        variablesValues[symbol] = value
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
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