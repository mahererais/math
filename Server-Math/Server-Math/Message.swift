//
//  Message.swift
//  math
//
//  Created by maher on 16/10/2021.
// maher

import Foundation

enum TypeMessage : Int, Codable{
    case message,
         newPlayed,
         playerLeft,
         invite,
         response,
         done,
         result,
         ready,
         end,
         unknown
}



fileprivate enum MessageKeys : String {
    case type         = "_type"
    case equation     = "_equation"
    case value1       = "_value1"
    case value2       = "_value2"
    case operateur    = "_operateur"
    case resultat     = "_resultat"
    case btPressed    = "_btPressed"
    case name         = "_name"
    case playerID     = "_playerID"
    case toPlayerID   = "_toPlayerID"
    case invite       = "_invite"
}

class Message: NSObject, Codable {
    
    var _type : TypeMessage = .unknown
    var _equations : [[String:Int]] = []
    var _value1 : Int?
    var _value2 : Int?
    var _resultat : Int?
    var _operateur: String?
    var _btPressed: String?
    var _name: String?
    var _playerID: [Int: String]?
    var _toPlayerID : [Int: String]?
    
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
        coder.encode(self._name, forKey: MessageKeys.name.rawValue)
        coder.encode(self._playerID, forKey: MessageKeys.playerID.rawValue)
        coder.encode(self._toPlayerID, forKey: MessageKeys.toPlayerID.rawValue)
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
        self._name = coder.decodeObject(forKey: MessageKeys.name.rawValue) as! String
        self._playerID = coder.decodeObject(forKey: MessageKeys.playerID.rawValue) as! [Int : String]
        self._toPlayerID = coder.decodeObject(forKey: MessageKeys.toPlayerID.rawValue) as! [Int : String]
    }
    
    // MARK: - debug description
    
    override var description: String {
        return """
                _type : \(_type)
                _equation: \(_equations)
                _value_1 : \(_value1)
                _value_2 : \(_value2)
                _resultat : \(_resultat)
                _operateur : \(_operateur)
                _btPressed: \(_btPressed)
                _name: \(_name)
                _playerID: \(_playerID)
                _toPlayerID: \(_toPlayerID)
                """;
    }
}
