//
//  MultiSearchViewController.swift
//  math
//
//  Created by maher on 09/10/2021.
//

import UIKit

import MultipeerConnectivity


enum PlayerPosition {
    case first, seconde, third, none, secondWait
    // first  : c'est celui qui invite
    // second : c'est celui qui ce fait invité
}

class MultiSearchViewController: NSObject, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate
{
    
    
    var statusDone = (a:false, b:false)
    var playerPosition : PlayerPosition = .none
    var operateur: String = ""
    
    var session: MCSession?
    var ad: MCNearbyServiceAdvertiser?
    var myPeerID = MCPeerID(displayName: UIDevice.current.name + " - \(Int.random(in: 0...1000))")
    var mcPeerID : [Any] = []
    
    var browserController: MCBrowserViewController? = nil
    var browser: MCNearbyServiceBrowser? = nil
    var serviceType = "mahere88"
    
    var gameController : GameViewController? = nil
    
    var rootController: UIViewController? = nil
    

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .systemPink
//        // Do any additional setup after loading the view
//        self.perform(#selector(initialiseBrowser),
//                     with: nil,
//                     afterDelay: 0.5)
//
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//    }
    
    
    // MARK: -
    
    deinit {
        print(object_getClass(self)!.description() + "." + #function)
        self.browserController    = nil
        self.ad         = nil
        self.session    = nil
    }
    
    func stopMultiPeerService() {
        print(object_getClass(self)!.description() + "." + #function)
        self.ad?.delegate = nil
        self.ad?.stopAdvertisingPeer()
        self.ad = nil
        self.session?.delegate = nil
        self.session = nil
        self.mcPeerID = []
        self.browserController!.delegate = nil
    }
    
    
    @objc func initialiseBrowser(rootController: UIViewController, ope: String = "+") {
        self.operateur = ope
        
        self.session = MCSession(peer: self.myPeerID)
        self.browser = MCNearbyServiceBrowser(peer: self.myPeerID,
                                              serviceType: self.serviceType)
        self.browserController = MCBrowserViewController(
                browser: browser!,
                session: session!)
        self.browserController?.title = ope
        browserController!.delegate = self
        session?.delegate = self
        self.rootController = rootController
        rootController.present(browserController!, animated: true, completion: nil)
        
        self.ad = MCNearbyServiceAdvertiser(peer: self.myPeerID,
                                            discoveryInfo: ["operateur": operateur],
                                            serviceType: self.serviceType)
        
//        self.ad = MCAdvertiserAssistant(serviceType: "mahere88",
//                                       discoveryInfo: nil,
//                                       session: session!)
        self.ad?.delegate = self
        
        ad?.startAdvertisingPeer()
        //browser?.startBrowsingForPeers()
        
    }
    
    func loadGameViewController () {
        DispatchQueue.main.async {
            self.gameController = GameViewController(ope: self.operateur,
                                         multiPeerObject: self,
                                                position: self.playerPosition);
            self.gameController!.modalPresentationStyle = .fullScreen
            self.gameController!.modalTransitionStyle = .coverVertical
        }
    }
    
    // MARK: - send / receive data
    
    @objc func sendDoneMessage()  {
        print ("------> envoie un \"Donne\"")
        let msg = Message(type: .done)
        self.sendData(equations: msg)
    }
    
    
    func sendString(str : String) {
        return
        do {
            try self.session?.send(str.data(using: .utf8)!,
                                  toPeers: self.session!.connectedPeers/*multiPeerObject!.mcPeerID*/,
                                       with: .reliable)
        }catch (let err) {
            print ("error encoding JSon data : " + err.localizedDescription)
        }
    }
    
    func receiveString (data : Data) {
        print(object_getClass(self)!.description() + "." + #function)
        print (" *+*+* : " + String(decoding: data, as: UTF8.self))

        let str = String(decoding: data, as: UTF8.self)
        
        DispatchQueue.main.async {
            if (str == "clear") {
                self.gameController?.resultatLabel?.text = ""
                self.gameController?.animateLabel(view: (self.gameController?.resultatLabel)!)
            }else{
                self.gameController?.resultatLabel?.text = str
                self.gameController?.finishPressed(button: nil)
            }
        }
    }
    
    func sendData (equations : Message) {
        print (" sending data -> : " + object_getClass(self)!.description() + "." + #function)
        do {
            if #available(iOS 9.0, *) {
//                let data =  try NSKeyedArchiver.archivedData(withRootObject: equations,
//                                                             requiringSecureCoding: false)
                let encoder = JSONEncoder()
                let data = try encoder.encode(equations)
                
                try self.session?.send(data,
                                       toPeers: self.session!.connectedPeers,
                                       with: .reliable)
            } else {
                // Fallback on earlier versions
            }
                 
        } catch (let err) {
            print ("error encoding JSon data : " + err.localizedDescription)
        }
        
    }
    
    func receiveData (data: Data, peer: MCPeerID) {
        print (" receiving data -> : " + object_getClass(self)!.description() + "." + #function)
        let decoder = JSONDecoder()
        do {
           // print (String(data: data, encoding: .utf8) ?? "error decoding Json data to String")
            let dataDecoded : Message = try decoder.decode(Message.self, from: data)
            print(dataDecoded.description + " -> from " + peer.displayName)
            DispatchQueue.main.async {
                if (dataDecoded._type == .done) {
                    print ("------> reception d'un \"Donne\"")
                    if (self.playerPosition == .seconde) {
                        self.statusDone.a = true
                        if self.statusDone.b == true {
                            self.sendDoneMessage()
                            StatusBar.sharedInstance.show(status: .sync)
                        }
                    }
                    if (self.playerPosition == .first) {
                        self.statusDone.b = true
                        if (self.statusDone.a && self.statusDone.b) {
                            // normalement cette condition est toujours "oui"
                            self.gameController?.perform(#selector(self.gameController?.sendEquations),
                                                         with: nil,
                                                         afterDelay: 1.0)
                            
                            StatusBar.sharedInstance.show(status: .sync)
                        }
                    }
                }
                if (dataDecoded._type == .message) {
                    print ("------> reception d'un \"Message\"")
                    if (self.playerPosition == .seconde) {
                        self.gameController?.receiveEquations(equations: dataDecoded._equations)
                        //self.gameController?.timerRTT?.invalidate()
                    }
                }
                if (dataDecoded._type == .ready) {
                    print ("------> reception d'un \"Ready\"")
                    self.gameController?.updateLabelValueDisplayed()
                    StatusBar.sharedInstance.show(status: .ready)
                    self.statusDone = (a:false, b:false)
                }
                if (dataDecoded._type == .response) {
                    print ("------> reception d'un \"Response\"")
                    self.gameController?.j2EquationResponse.append(dataDecoded._value1!)
                    self.gameController?.resumeView?.tableView?.reloadSections(IndexSet(integer: 0), with: .fade)
                }
                if (dataDecoded._type == .end) {
                    let alerController = UIAlertController(title: "Disconned",
                                                           message: "your opponent left",
                                                           preferredStyle: .alert)
                    alerController.addAction(UIAlertAction(title: "Ok",
                                                           style: .default,
                                                           handler: {_ in
                        self.stopMultiPeerService()
                    }))
                    let controller = UIApplication.shared.windows.first?.rootViewController
                    //controller?.present(alerController, animated: true, completion: nil)
                    // i.e : l'alert ne 'affiche pas , je ne sais pas pourquoi :/
                    // j'ai donc remplacer ca par une alert via la statusBar
                    StatusBar.sharedInstance.show(str: "your opponent left", status: .close)
                }
                
            }
        }catch (let err) {
            print ("error decoding JSon data : " + err.localizedDescription)
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - MCBrowserViewControllerDelegate
     
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        print(object_getClass(self)!.description() + "." + #function)
        
        self.browserController?.dismiss(animated: true, completion: {
            
            DispatchQueue.main.async {
                self.rootController?.present(self.gameController!,
                             animated: true,
                             completion: nil)
            }
            
        })
        
        
        
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        print(object_getClass(self)!.description() + "." + #function)
        self.stopMultiPeerService()
        self.ad?.delegate = nil
        self.ad?.stopAdvertisingPeer()
        self.ad = nil
        self.session = nil
        self.mcPeerID = []
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool
    {
        print(object_getClass(self)!.description() + "." + #function)
        if ((self.session?.myPeerID.displayName)! == peerID.displayName) {
            // c'est moi !!!
            return false
        }
        self.mcPeerID.append(peerID)
        return true
    }
    
    
    // MARK: - MCNearbyAdvertiserAssistantDelegate
    
    // Incoming invitation request.  Call the invitationHandler block with YES
    // and a valid session to connect the inviting peer to the session.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        print(object_getClass(self)!.description() + "." + #function)
        
        invitationHandler(true, self.session)
        playerPosition = .secondWait
    }
    // Advertising did not start due to an error.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error)
    {
        print(object_getClass(self)!.description() + "." + #function)
        playerPosition = .none
    }
    
    
    // MARK: - MCSessionDelegate
    
    func session(_ session: MCSession,
      didReceive data: Data,
                 fromPeer peerID: MCPeerID)
    {
        print(object_getClass(self)!.description() + "." + #function)
        self.receiveData(data: data, peer: peerID)
        
    }
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(object_getClass(self)!.description() + "." + #function)
        switch state {
            case .connected:
                print("Connected")
                
                switch playerPosition {
                    case .secondWait:
                        self.playerPosition = .seconde
                    case .seconde:
                        self.playerPosition = .seconde // celui qui a reçu l'invitation
                    default:
                        self.playerPosition = .first // celui qui a envoyé l'invitation
                }
                self.loadGameViewController()
            case .notConnected:
              print("Not connected: \(peerID.displayName)")
                self.playerPosition = .none
            case .connecting:
              print("Connecting to: \(peerID.displayName)")
                
            @unknown default:
              print("Unknown state: \(state)")
            }
    }
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print(object_getClass(self)!.description() + "." + #function)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print(object_getClass(self)!.description() + "." + #function)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print(object_getClass(self)!.description() + "." + #function)
    }
    
    
    
}
