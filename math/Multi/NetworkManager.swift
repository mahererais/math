//
//  ConnectionTCPManager.swift
//  projet-ppm-ramzi
//
//  Created by ramzi on 25/01/2021.
//

import UIKit
import Network

/*
    --------------- sources: ---------------
    https://developer.apple.com/videos/play/wwdc2019/712/
    https://developer.apple.com/documentation/network
    NWPathMonitor
    https://www.hackingwithswift.com/example-code/networking/how-to-check-for-internet-connectivity-using-nwpathmonitor
 */



protocol NetworkManagerProtocole : NSObjectProtocol{
    func receiveMessage(name:String, message:String, isMe: Bool, id:String)
    func receiveMessage(message:Message, isMe: Bool, id:String)
    func receiveServerUpdate(number: TimeInterval)
    func error(error: NWError?,title:String)
    func statusConnectionUpdate (status:String, color: UIColor)
}

extension NetworkManagerProtocole {
    //func error(error: NWError?, title:String = "Error Connection") {
    func error(error: NWError?) {
        self.error(error: error, title:"Error Connection")
    }
    func statusConnectionUpdate (status:String)  {
        self.statusConnectionUpdate(status: status, color: .black)
    }
}


class NetworkManager: NSObject {

    fileprivate var available = false
    fileprivate let monitor = NWPathMonitor()
//    let wifiMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
//    let cellMonitor = NWPathMonitor(requiredInterfaceType: .cellular)

    fileprivate let serveurEndPoint: NWEndpoint = NWEndpoint.hostPort(host:NWEndpoint.Host(_SERVER.adresse),
                                                   port: NWEndpoint.Port(String(_SERVER.port))!)
        
    fileprivate var connection: NWConnection?
    fileprivate var queue = DispatchQueue(label: "Ramzi_dispathQueue", qos: .utility)
    fileprivate var host: NWEndpoint.Host?
    fileprivate var port: NWEndpoint.Port?
    fileprivate var data : Data = Data()
    
     weak var delegate : NetworkManagerProtocole? = nil
/*
     https://stackoverflow.com/questions/58484592/swift-in-nwconnection-class-when-does-receivemessagecompletion-gets-called
     */
    
    // MARK: -
    
    override init() {
        super.init()
        initConnectionSocket()
    }
    
    fileprivate init(host:String, port:String) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(port)!
        super.init()
    }
    
    deinit {
        _TOOLS._print(obj: self)
    }
    
    // MARK: -
    
    func initConnectionSocket() {
        self.host = NWEndpoint.Host(PreferenceManager.sharedInstance.loadIP())
        self.port = NWEndpoint.Port(PreferenceManager.sharedInstance.loadPort())!
    }
    
    
    func checkConnection () {
        _TOOLS._print(obj: self)
        monitor.pathUpdateHandler = { path in
            _TOOLS._print(obj: self, path.status)
            if path.status == .satisfied {
                print("The path is available to establish connections and send data.")
                self.available = true
                self.delegate?.statusConnectionUpdate(status: "connection available")
                self.startConnectionTCP()
            } else if path.status == .unsatisfied {
                print("No connection. The path is not available for use." )
                self.available = false
                self.delegate?.statusConnectionUpdate(status: "No connection", color: .red)
                self.delegate?.error(error: nil, title:"monitor unsatisfied")
            }else if path.status == .requiresConnection{
                print("The path is not currently available, but establishing a new connection may activate the path.")
                self.available = false
                self.delegate?.statusConnectionUpdate(status: "requires Connection", color: .red)
                self.delegate?.error(error: nil, title:"requires Connection")
                //self.startConnectionTCP()
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
    }


    
    func startConnectionTCP()
        {
        _TOOLS._print(obj: self)
        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.connectionTimeout = 5
        let parameters = NWParameters(tls: nil,
                                      tcp: tcpOptions)
        if self.connection == nil {
            // connection est != nil si la connection a ete etablie precedement et que
            // le joueur coupe temporairement le wifi et le remet par exemple
            self.connection = NWConnection(host: host!, port: port!, using: parameters)
            self.connection?.stateUpdateHandler =
                    {
                        (newState) in
                        switch (newState)
                        {
                        case .ready:
                            //The connection is established and ready to send and recieve data.
                            print("connection status : ready")
                            self.delegate?.statusConnectionUpdate(status: "ready")
                            self.receive_tcp()
                        case .setup:
                            //The connection has been initialized but not started
                            print("connection status : setup")
                            self.delegate?.statusConnectionUpdate(status: "setup")
                        case .cancelled:
                            //The connection has been cancelled
                            print("connection status : cancelled")
                            self.delegate?.statusConnectionUpdate(status: "cancelled", color: .red)
                        case .preparing:
                            //The connection in the process of being established
                            print("connection status : Preparing")
                            self.delegate?.statusConnectionUpdate(status: "preparing", color: .systemBlue)
                        case .failed(let error):
                            // The connection has disconnected or encountered an error
                            print("connection status : failed -> " + error.debugDescription)
                            self.delegate?.error(error: error, title:"connection failed")
                            self.delegate?.statusConnectionUpdate(status: "failed", color: .red)
                        case .waiting(let error):
                            // The connection is waiting for a network path change
                            print("connection status : connection wainting -> " + error.debugDescription)

                            self.delegate?.error(error: error, title:"check your connection")
                            self.delegate?.statusConnectionUpdate(status: "connection waiting", color: .red)
                            // self.checkConnection() //i.e ne pas le faire ici, ca va faire une boucle
                        default:
                            break
                        }
                }
            self.connection?.betterPathUpdateHandler = { ok in
                 print (" *** betterPathUpdateHandler ***") //  ce ne sert a rien ici
            }
            self.delegate?.statusConnectionUpdate(status: "waiting Server")
            self.connection?.start(queue: self.queue)
        }else{
            // remettre a jour le status "self.delegate?.statusConnectionUpdate"
            // ainsi que le nombre de jour present dans tchat
        }
        

    }
    
    // MARK: - send message
    
    fileprivate func encodeForJSon<T> (data: T) -> Data?  where T : Encodable{
        let encoder = JSONEncoder()
        //encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let dataJson = try encoder.encode(data)
            print (String(data: dataJson, encoding: .utf8) as Any)
            return dataJson
        }catch (let err) {
            print ("error encoding JSon data : " + err.localizedDescription)
        }
        return nil
    }
    
    func sendPacket<T>(_ packet: T) where T: NSCoding {
        do {
            let dataArchived = try NSKeyedArchiver.archivedData(withRootObject: packet, requiringSecureCoding: false)

            self.sendPacket(dataArchived)
        } catch (let err) {
            print ("------------------------------------")
            print (err.localizedDescription)
            print ("------------------------------------")
        }
    }
    
    func sendPacket<T>(_ packet: T) where T: Codable {
        guard let dataEncoded = self.encodeForJSon(data: packet) else {
            fatalError("*** Erreur a la ligne \(#line) de la classe " + object_getClassName(self).debugDescription)
        }
        self.sendPacket(dataEncoded)
    }
    
    func sendPacket(_ packet:String) {
        _TOOLS._print(obj: self)
        guard let packetData = packet.data(using: .utf8) else {
            fatalError("you cant sent nil messsage")
        }
        self.sendPacket(packetData)
    }
    
    fileprivate func sendPacket(_ packet:Data) {
        _TOOLS._print(obj: self)
        self.connection?.send(content: packet, completion: NWConnection.SendCompletion.contentProcessed(({ (error) in
            if let err = error {
                print("Sending error \(err)")
            } else {
                print("Sent successfully")
            }
        })))
    }
    
    // MARK: - Receive messge
    
    
    /// function for class data who implement Codable Protocole
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
    
    /// function for class data who implement NSCoding Protocole
    fileprivate func decode<M>(_ type: M.Type, data: Data) -> M? where M : NSObject & NSCoding {
        print ("decoding data with \"NSKeyedUnarchiver\" decoder")
        do {
            NSKeyedUnarchiver.setClass(M.classForCoder(), forClassName: String(describing: M.self))
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? M
        }catch (let err) {
            //print ("error decoding NSKeyUnarchiver data : " + err.localizedDescription)
        }
        
        return nil
    }
    
    
    func receive_tcp () {
        _TOOLS._print(obj: self)
        let size_maximum = 1024
        self.connection?.receive(minimumIncompleteLength: 1, maximumLength: size_maximum, completion:
            {
                (data, context, isComplete, error) in
                        
                if isComplete
                {
                    self.delegate?.error(error: error, title: "Server Disconnect")
                    self.delegate?.statusConnectionUpdate(status: "disconnect", color: .systemRed)
                    self.close()
                    return
                }
        
                if let err = error {
                    if !isComplete {
                        print("error with server: \(err)")
                        self.delegate?.error(error: err, title: "error receive from Server")
                        self.delegate?.statusConnectionUpdate(status: "disconnect", color: .systemRed)
                        return
                    }
                }


                if let rcvData = data
                {
                    self.data.append(rcvData)
                    
                    
                    
                    if let messageObject = self.decode(Message.self, data: self.data)
                    {
                        DispatchQueue.main.async {
                            if messageObject._type == .info {
                                self.delegate?.receiveServerUpdate(number: messageObject._date)
                            }else{
                                print (String(data: self.data, encoding: .utf8) ?? "")
                                self.delegate?.receiveMessage(message: messageObject,
                                                              isMe: false,
                                                              id: (UIDevice.current.identifierForVendor?.description)!)
                            }
                            
                        }
                        self.data.removeAll()
                        
                    }else{
                        if rcvData.count < size_maximum {
                            self.data.removeAll()
                        }
                    }
                    
                    self.receive_tcp()
                    
                }
            })
    }
    
    
    // MARK: - close Connection
    
    @objc func close() {
        _TOOLS._print(obj: self)
        self.delegate = nil
        self.monitor.cancel()
        self.connection?.cancel()
        self.connection?.forceCancel()
        self.connection?.stateUpdateHandler = nil
        data.removeAll()
        self.connection = nil
    }
    
    
}
