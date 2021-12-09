//
//  EquationObject.swift
//  math
//
//  Created by maher on 08/10/2021.
//

import UIKit

class EquationObject: NSObject {
    
    let value1: Int
    let value2: Int
    let resultat: Int
    let operateur: String
    let defaultValue: Int
    
    init(operateur: String) {
        self.operateur = operateur
        self.value1 = Int.random(in: 0...10);
        self.value2 = Int.random(in: 0...10);
        self.resultat = EquationObject.GetResultat(v1: self.value1,
                                                   v2: self.value2,
                                                   operation: operateur)
        self.defaultValue = EquationObject.GetDefaultValue(operation: operateur)
        
        super.init()
    }
    
    static func GetResultat(v1: Int, v2: Int, operation:String) -> Int
    {
        
        switch operation {
        case "+":
            return v1 + v2
        case "-":
            return v1 - v2
        case "x":
            return v1 * v2
        case "÷":
            return v1 / v2
        default:
            return -1;
        }
    }
    
    static func GetDefaultValue(operation:String) -> Int
    {
        
        switch operation {
        case "+":
            return 0
        case "-":
            return 0
        case "x":
            return 1
        case "÷":
            return 1
        default:
            return -1;
        }
    }
    
    func description () -> String {
        return "equation : \(self.value1) \(self.operateur) \(self.value2) = \(self.resultat)"
    }

}
