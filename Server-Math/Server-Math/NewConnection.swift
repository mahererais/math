//
//  NewConnection.swift
//  projet-ppm2-server
//
//  Created by ramzi on 01/02/2021.
//

import Foundation
import Network
import AVFoundation


protocol NewConnectionDelegate : NSObjectProtocol{
    
    func notifyDisConnectionsWithServerInfo (connection : NewConnection)
    func forwardMessage(data:Data?, from sender:NewConnection)
    func forwardMessage (data:Data?, toId:[Int : String])
    func removeConnection(connection: NewConnection)
    func notifyAddNewPlayer(connection: NewConnection)
    func notifyPlayerLeft(connection: NewConnection, id: [Int: String])
    func sendMePlayerList(connection: NewConnection, ids: [Int: String])
}

class NewConnection : NSObject{
    
    
    let connection : NWConnection
    let id : Int
    let queue = DispatchQueue(label: "NewConnection Queue")
    var currentPlayerID : [Int: String] = [:]
    weak var delegate : NewConnectionDelegate?
    
    
    init(_ connection:NWConnection) {
        self.connection = connection
        self.id = Int.random(in: 0...Int.max)
    }
    
    deinit {
        //print(object_getClass(self)!.description() + "." + #function)
    }
    
    func initialise () {
        self.connection.stateUpdateHandler = self.connectionStatusUpdate(to:)
    }
    
    func start() {
        self.connection.start(queue: self.queue)
    }
    
    func close() {
        //self.queue.stop()
        
        self.delegate = nil
        self.connection.stateUpdateHandler = nil
        self.connection.cancel()
    }
    
    // MARK: -
    
    func connectionStatusUpdate (to state:NWConnection.State)
    {
        switch state {
        case .ready:
            print ("connection status update : " + "ready")
            self.receive()
            //self.delegate?.notifyConnectionsWithServerInfo()
        case .cancelled:
            print ("connection status update : " + "cancelled")
        case .setup:
            print ("connection status update : " + "setup")
        case .failed(let err):
            print ("connection status update : " + "failed with err : " + err.localizedDescription)
        case .waiting(let err):
            print ("connection status update : " + "waiting with err : " + err.localizedDescription)
        case .preparing:
            print ("connection status update : " + "preparing")
        default:
            print ( "connection ????????? i'm not supposed to be here  ?????????" )
        }
    }
    
    // MARK -
    
    func send(data: Data) {
        print ("envoie d'un message a la connexion " + String(self.id))
        self.connection.send(content: data, completion: NWConnection.SendCompletion.contentProcessed({ (err) in
            
        }))
    }
    
    func receive() {
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { (data, context, isComplete, err) in
            
            if /*err == nil && data == nil &&*/ isComplete {
                // le client c'est deconnecté sans prevenir
                // i.e: j'ai pas le meme comportement du serveur avec Catalina et BigSur
                self.delegate?.notifyPlayerLeft(connection: self, id: self.currentPlayerID)
                self.delegate?.removeConnection(connection: self)
                return
            }
            
            if err != nil {
                print ("Erreur lors de la reception du message de la connexion \(self.id)")
                print (err?.localizedDescription)
                self.delegate?.removeConnection(connection: self)
            }else if data != nil {
                // je decode le message
                var message = self.decode(Message.self, data: data!)
                if message!._type == .newPlayed {
                    if let playerId = message!._playerID {
                        (self.delegate as? ServeurListener)?.addNewPlayerOnList(newId: playerId)
                        self.currentPlayerID = playerId
                        self.delegate?.notifyAddNewPlayer(connection: self)
                    }
                }else if (message!._type == .invite || message!._type == .done || message!._type == .end || message!._type == .response || message!._type == .result || message!._type == .message)  {
//                    if message!._toPlayerId == nil {
//                        self.delegate?.forwardMessage(data: data, from:self)
//                    }else{
                        self.delegate?.forwardMessage(data: data, toId: message!._toPlayerId!)
//                    }
                }else{
                    self.delegate?.forwardMessage(data: data, from: self)
                }
                
                print ("reception d'un message de la connexion " + String(self.id))
                self.receive()
            }
            
        }
    }
    
    /// function for class data who implement Codable Protocole
    /// type : ex: Message.self 
    fileprivate func decode<T> (_ type: T.Type, data: Data) -> T? where T : Codable  {
        //print ("decoding data with \"JSon\" decoder")
        let decoder = JSONDecoder()
        do {
           // print (String(data: data, encoding: .utf8) ?? "error decoding Json data to String")
            let dataDecoded = try decoder.decode(type, from: data)
            return dataDecoded
        }catch (let err) {
            //print ("error decoding JSon data : " + err.localizedDescription)
        }

        return nil
    }

    
}
