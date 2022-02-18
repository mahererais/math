//
//  ServeurListener.swift
//  projet-ppm2-server
//
//  Created by ramzi on 01/02/2021.
//

import Foundation
import Network


class ServeurListener : NSObject , NewConnectionDelegate{
    
    
    let port : NWEndpoint.Port?
    var listener : NWListener?
    var connections = [NewConnection]()
    var listOfPlayer : [Int:String] = [:]
    
    
    init(port : UInt16) {
        self.port = NWEndpoint.Port(rawValue: port)
        self.listener = try! NWListener(using: .tcp, on: self.port!)
    }
    
    deinit {
        print(object_getClass(self)!.description() + "." + #function)
    }
    
    // MARK: -
    
    func initialise () {
        
        // ouvre une connexion sur le port indiqué en TCP
        listener?.newConnectionLimit = NWListener.InfiniteConnectionLimit
        listener?.stateUpdateHandler = listenerStatusUpdate(to:)
        listener?.newConnectionHandler = newConnectionDetected(connection:)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(close),
//                                               name: UIApplication.willTerminated,
//                                               object: nil)
    }
    
    func start() {
        let queue = DispatchQueue(label: "Listener Server Math")
        self.listener?.start(queue: queue)
    }
    
    func close () {
        for connection in self.connections {
            connection.close()
        }
        self.listener?.stateUpdateHandler = nil
        self.listener?.newConnectionHandler = nil
        self.listener?.cancel()
        self.listener = nil
    }
    
    func getId() -> Int { return self.listOfPlayer.keys.first ?? -1 }
    func getName() -> String { return self.listOfPlayer.values.first ?? "unknows" }
    
    // MARK:  -
    
    func addNewPlayerOnList (newId : [Int: String]) {
        self.listOfPlayer.merge(newId) {(_, new) in new}
        print("nom du joueur : \(self.getName())")
    }
    
    func removePlayerOnList (id: [Int: String]) {
        self.listOfPlayer.removeValue(forKey: id.keys.first!)
    }
    
    func listenerStatusUpdate (to state:NWListener.State)
    {
        print ("mise a jour du status du serveur")
        switch state {
        case .ready:
            // The listener is running and able to receive incoming connections.
            print ("listener status update : " + "ready")
        case .cancelled:
            // The listener has been canceled.
            print ("listener status update : " + "cancelled")
        case .setup:
            // The listener has been initialized but not started.
            print ("listener status update : " + "setup")
        case .failed(let err):
            // The listener has encountered a fatal error.
            print ("listener status update : " + "failed with err : " + err.localizedDescription)
        case .waiting(let err):
            // The listener is waiting for a network to become available.
            print ("listener status update : " + "waiting with err : " + err.localizedDescription)
        default:
            print ( "listener ?????????? i'm not supposed to be here  ?????????" )
        }
    }
    
    
    func newConnectionDetected (connection: NWConnection) {
        let newConnection = NewConnection(connection)
        print ("\n|--> nouvelle connection avec un id : " + String(newConnection.id))
        switch connection.endpoint {
        case .hostPort(host: let host, port: _):
            print ("connection avec une @ip : \(host)")
        default:
            break
        }
        self.connections.append(newConnection)
        newConnection.delegate = self
        newConnection.initialise()
        newConnection.start()
    }
    
    func exceptionCatched (err: Error) {
        print ("---------Exception Catch-----------")
        print (err.localizedDescription)
        print ("-----------------------------------")
    }
    
    func sendAll (data:Data) {
        for connection in connections {
            connection.send(data: data)
        }
    }
    
    func sendToAllExcepteMe(connection: NewConnection, data: Data) {
        for connect in connections {
            if connect != connection {
                connect.send(data: data)
            }
        }
    }
    
    func sendData(_ data:Data, to connection: NewConnection) {
        connection.send(data: data)
    }
    
    // MARK: - NewConnectionDelegate
    func sendMePlayerList(connection: NewConnection, ids: [Int: String]) {
        let msg = Message(type: .newPlayed)
        msg._playerID = ids
        self.sendData(self.encode(data: msg)!, to: connection)
    }
    
    func notifyAddNewPlayer(connection: NewConnection) {
        let msg = Message(type: .newPlayed)
        msg._playerID = self.listOfPlayer
        self.sendAll(data: self.encode(data: msg)!)
    }
    
    func notifyPlayerLeft(connection: NewConnection, id: [Int: String]) {
        let msg = Message(type: .playerLeft)
        msg._playerID = id
        self.listOfPlayer[id.keys.first!] = nil
        self.sendToAllExcepteMe(connection: connection, data: self.encode(data: msg)!)
    }
    
    func notifyDisConnectionsWithServerInfo (connection : NewConnection) {
//        let message = Message(type: .info)
//        message._name = connection.name
//        let data = self.encode(data: message)
//        if data != nil {
//            self.sendAll(data: data!)
//        }
    }
    
    func removeConnection(connection: NewConnection) {
        self.connections =  self.connections.filter { (value) -> Bool in
            return value.id != connection.id
        }
        //self.notifyDisConnectionsWithServerInfo(connection: connection)
        
        connection.close()
        print ("|<-- deconnection du client \(self.getName()) avec un id : " + String(connection.id) + "\n")
        
    }
    func forwardMessage (data:Data?, toId:[Int : String]) {
        for connection in connections {
            if toId == connection.currentPlayerID {
                self.sendData(data!, to: connection)
            }
        }
    }
    func forwardMessage(data:Data?, from sender:NewConnection) {
//        if connections.count == 1 {
//            let message = Message(me: false, name: "Serveur",
//                                  msg: "Mais tu veux parler avec qui ? tu es seul sur le tchat pour l'instant :)", date: Date().timeIntervalSinceNow)
//            self.connections.first?.send(data: encode(data: message)!)
//        }
        for connection in connections {
            if sender.id != connection.id {
                if data != nil{
                    connection.send(data: data!)
                }else{
                    print ("le client " + String(sender.id) + " a envoyé un paquet VIDE !! ....")
                }
                
            }
        }
    }
    
    // MARK: encoding data
    
    // encode for JSon coding
    fileprivate func encode<T> (data: T) -> Data?  where T : Encodable{
        let encoder = JSONEncoder()
        //encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let dataJson = try encoder.encode(data)
            //print (String(data: dataJson, encoding: .utf8)!.debugDescription)
            return dataJson
        }catch (let err) {
            print ("error encoding JSon data : " + err.localizedDescription)
        }
        return nil
    }
    
    // encode for NSKeyArchiver coding
    fileprivate func encode<T> (data: T) -> Data?  where T : NSCoding{
        do {
            NSKeyedArchiver.setClassName("Message", for: Message.classForCoder())
            let data = try NSKeyedArchiver.archivedData(withRootObject: data,
                                                         requiringSecureCoding: false)
            return data
        }catch (let err) {
            print(err.localizedDescription)
        }
        return nil
        
    }
    
    
    // MARK: -
    
    func getNumberOfPlayer() -> Int {
        return self.connections.count
    }
    
    func getListOfPlayer () -> String {
        return self.listOfPlayer.values.description
    }
    
    
    
}
