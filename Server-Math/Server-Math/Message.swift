//
//  Message.swift
//  math
//
//  Created by maher on 16/10/2021.
// maher

import Foundation

enum TypeMessage : Int, Codable{
    case message,  
         response,
         done,
         result,
         ready,
         end,
         unknown
}



fileprivate enum MessageKeys : String {
    case type         = "type"
    case equation     = "equation"
    case value1       = "value1"
    case value2       = "value2"
    case operateur    = "operateur"
    case resultat     = "resultat"
    case btPressed    = "btPressed"
}

class Message: NSObject, Codable {
    
    var _type : TypeMessage = .unknown
    var _equations : [[String:Int]] = []
    var _value1 : Int?
    var _value2 : Int?
    var _resultat : Int?
    var _operateur: String?
    var _btPressed: String?
    
    init(type: TypeMessage) {
        self._type = type
    }
    
    
    
    // MARK: - NSCoding Protocol
    
    func encode(with coder: NSCoder) {
        coder.encode(self._type.rawValue, forKey: MessageKeys.type.rawValue)
        coder.encode(self._equations, forKey: MessageKeys.equation.rawValue)
        coder.encode(self._resultat, forKey: MessageKeys.resultat.rawValue)
        coder.encode(self._value1, forKey: MessageKeys.value1.rawValue)
        coder.encode(self._value2, forKey: MessageKeys.value2.rawValue)
        coder.encode(self._operateur, forKey: MessageKeys.operateur.rawValue)
        coder.encode(self._btPressed, forKey: MessageKeys.btPressed.rawValue)
    }
    
    required init?(coder: NSCoder) {
        super.init()
        self._type = TypeMessage(rawValue: coder.decodeInteger(forKey: MessageKeys.type.rawValue)) ?? TypeMessage.unknown
        self._equations = coder.decodeObject(forKey: MessageKeys.equation.rawValue) as! [[String:Int]]
        self._value1 = coder.decodeInteger(forKey: MessageKeys.value1.rawValue)
        self._value2 = coder.decodeInteger(forKey: MessageKeys.value2.rawValue)
        self._resultat = coder.decodeInteger(forKey: MessageKeys.resultat.rawValue)
        self._operateur = coder.decodeObject(forKey: MessageKeys.operateur.rawValue) as! String
        self._btPressed = coder.decodeObject(forKey: MessageKeys.btPressed.rawValue) as! String
    }
    
    // MARK: - debug description
    
    override var description: String {
        return "type : \(_type) equation: \(_equations) value_1 : \(_value1)"
    }
}
