//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Maxime Mongeau on 2015-03-17.
//  Copyright (c) 2015 Maxime Mongeau. All rights reserved.
//

import Foundation

class CalculatorModel {
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        
        var description: String {
            get {
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
        learnOp(Op.UnaryOperation("±"){$0 * -1})
        learnOp(Op.Constant("π", M_PI))
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
    
    
    // TODO: Refactor to do this at the same time than evaluate
    private func readStack(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOperations = ops
            let op = remainingOperations.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOperations)
            case .UnaryOperation(let symbol, _):
                let operandRead = readStack(remainingOperations)
                if let operand = operandRead.result {
                    return ("\(symbol)(\(operand))", remainingOperations)
                }
            case .BinaryOperation(let symbol, _):
                let op1Read = readStack(remainingOperations)
                if let operand1 = op1Read.result {
                    let op2Read = readStack(op1Read.remainingOps)
                    if let operand2 = op2Read.result {
                        return ("(\(operand1) \(symbol) \(operand2))", remainingOperations)
                    }
                }
            case .Constant(let symbol, _):
                return (symbol, remainingOperations)
            }
        }
        return (nil, ops)
    }
    
    func readStack() -> String? {
        let (result, remainder) = readStack(opStack)
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