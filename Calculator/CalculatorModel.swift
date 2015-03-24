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
        // To have a different symbol in the equation display
        knownOps["±"] = Op.UnaryOperation("-"){$0 * -1}
        learnOp(Op.Constant("π", M_PI))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, equation: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOperations = ops
            let op = remainingOperations.removeLast()
            switch op {
                case .Operand(let operand):
                    return (operand, "\(operand)", remainingOperations)
                
                case .UnaryOperation(let symbol, let operation):
                    let operandEvaluation = evaluate(remainingOperations)
                    if let operand = operandEvaluation.result {
                        return (operation(operand), "\(symbol)(\(operandEvaluation.equation!))", operandEvaluation.remainingOps)
                    }
                
                case .BinaryOperation(let symbol, let operation):
                    let op1Evaluation = evaluate(remainingOperations)
                    if let operand1 = op1Evaluation.result {
                        let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                        if let operand2 = op2Evaluation.result {
                            return (operation(operand1, operand2), "(\(op2Evaluation.equation!) \(symbol) \(op1Evaluation.equation!))", op2Evaluation.remainingOps)
                        }
                    }
                
                case .Constant(let symbol, let value):
                    return (value, symbol, remainingOperations)
            }
        }
        return (nil, nil, ops)
    }
    
    func evaluate() -> (Double?, String?) {
        let (result, equation, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder)")
        var equationDisplay = equation
        if remainder.isEmpty {
            equationDisplay = equationDisplay! + " ="
        }
        return (result, equationDisplay)
    }
    
    func pushOperand(operand: Double) -> (Double?, String?) {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> (Double?, String?) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearOperand() {
        opStack = [Op]()
    }
}