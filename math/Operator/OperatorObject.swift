//
//  OperatorObject.swift
//  math
//
//  Created by maher on 07/10/2021.
//

import UIKit


enum Operateur : Int, Codable{
    case plus,
         moins,
         multication,
         division,
         unknown
}


class OperatorObject: NSObject {

    var _operator: String
    
    init( o: String ) {
        self._operator = o
    }
    
    func getOperateurFrom(_ str : String) -> Operateur{
        switch str {
            case "+": return .plus
            case "-": return .moins
            case "x": return .multication
            case "÷": return .division
        default:
            return .unknown
        }
    }
    
    func getStringFrom(operateur : Operateur) -> String {
        switch operateur {
            case .plus: return "+"
            case .moins: return "-"
            case .multication: return "x"
            case .division: return "÷"
        default:
            return ""
        }
    }
    
}
