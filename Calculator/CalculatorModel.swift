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
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _):
                return symbol
            case .Constant(let symbol, _):
                return symbol
            }
        }
    }
    
    var description: String {
        var (result, remainder) = describe(opStack)
        if remainder.isEmpty {
            result!.splice(" =", atIndex: result!.endIndex)
        }
        while !remainder.isEmpty {
            result!.splice(", ", atIndex: result!.startIndex)
            var (desc, newRemainder) = describe(remainder)
            result!.splice(desc!, atIndex: result!.startIndex)
            remainder = newRemainder
        }
        return result!
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷"){$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−"){$1 - $0})
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("√", sqrt))
        // To have a different symbol in the equation display
        knownOps["±"] = Op.UnaryOperation("-"){$0 * -1}
        learnOp(Op.Constant("π", M_PI))
    }
    
    private func describe(ops: [Op]) -> (description: String?, remainingOps:[Op]) {
        if !ops.isEmpty {
            var remainingOperations = ops
            let op = remainingOperations.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOperations)
            case .UnaryOperation(let symbol, _):
                let opDescription = describe(remainingOperations)
                if let operand = opDescription.description {
                    return ("\(symbol)(\(operand))", opDescription.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let opDescription1 = describe(remainingOperations)
                if let operand1 = opDescription1.description {
                    let opDescription2 = describe(opDescription1.remainingOps)
                    if let operand2 = opDescription2.description {
                        return ("\(operand1) \(symbol) \(operand2)", opDescription2.remainingOps)
                    } else {
                        return ("\(operand1) \(symbol) ?", opDescription1.remainingOps)
                    }
                }
            case .Constant(let symbol, _):
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
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOperations)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
                
            case .Constant(_, let value):
                return (value, remainingOperations)
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
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearOperand() {
        opStack = [Op]()
    }
}