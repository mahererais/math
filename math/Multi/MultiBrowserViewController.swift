//
//  MultiBrowserViewController.swift
//  math
//
//  Created by maher on 18/01/2022.
//

import UIKit
import Network


class MultiBrowserViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, NetworkManagerProtocole
{

    @IBOutlet var tableView : UITableView?
    @IBOutlet var okItemButton : UIBarButtonItem?
    @IBOutlet var navigatItem : UINavigationItem?
    
    var gameController : GameViewController?
    var statusDone = (a:false, b:false)
    var rootController: UIViewController? = nil
    var operateur: String = ""
    var playerPosition : PlayerPosition = .none
    var data : [[Int:String]] = [[:]]
    lazy var networkManager: NetworkManager? = NetworkManager()
    let currentID = UIDevice.current.identifierForVendor!.hashValue
    let currentName = UIDevice.current.name
    
    deinit {
        print(object_getClass(self)!.description() + "." + #function)
    }
    
    func initialise (rootController: UIViewController, ope: String = "+") {
        self.rootController = rootController
        self.operateur = ope
    }
    
    func loadGameViewController () {
        DispatchQueue.main.async {
            self.gameController = GameViewController(ope: self.operateur,
                                      multiBrowserObject: self,
                                                position: self.playerPosition);
            self.gameController!.modalPresentationStyle = .fullScreen
            self.gameController!.modalTransitionStyle = .coverVertical
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let footerView = UILabel(frame: CGRect(x: 0, y: tableView?.frame.maxY ?? 0,
                                              width: tableView?.frame.width ?? 0,
                                              height: 50))
        
//        self.data.append([1:"un"])
//        self.data.append([2: "deux", 3:"trois", 4:"quatre"])
        
        footerView.backgroundColor = .lightGray
        footerView.text = "no player found"
        footerView.textAlignment = .center
        tableView?.tableFooterView = footerView
        
        let headerView = UILabel(frame: CGRect(x: 0, y: tableView?.frame.maxY ?? 0,
                                              width: tableView?.frame.width ?? 0,
                                              height: 50))
        headerView.textAlignment = .center
        tableView?.tableHeaderView = headerView
        
        networkManager?.delegate = self
        //networkManager?.checkConnection()
        networkManager?.startConnectionTCP()
        
      
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func actionDone (sender : Any?) {
        self.dismiss(animated: true,
                     completion: {
            self.networkManager?.close()
            self.networkManager = nil
        })
    }
    
// MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if self.data.count == 0 { return ""}
        else if self.data.count == 1 { return "Choose 1 player to invite ..."}
        else if self.data.count == 2 {
            switch section {
                case 0: return "player invited ..."
                case 1:  return "Choose 1 player to invite ..."
            default:
               return "error ..."
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "mahereCellReuse")
        let values  = Array(data[indexPath.section].values)
        let keys  = Array(data[indexPath.section].keys)
        cell.textLabel?.text = values[indexPath.row]
        if self.data.count == 2 && indexPath.section == 0 {
            cell.detailTextLabel?.text = "connecting ..."
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // je recupere le nom sur la cellule selectionné
        let values  = Array(data[indexPath.section].values)
        let keys  = Array(data[indexPath.section].keys)
        let name = values[indexPath.row]
        let id = keys[indexPath.row]
        if name == self.currentName {
            // j'ai cliqué sur moi meme, donc je ne fais rien
            return
        }else{
            let msg = Message(type: .invite)
            msg._name = UIDevice.current.name
            msg._toPlayerId = [id : name]
            msg._playerID = [self.currentID: self.currentName]
            self.networkManager?.sendPacket(msg)
            playerPosition = .first
            
            // deplacer le joueur selectionné dans la section invité
            if self.data.count == 1 { //je n'ai pas de section invité
                self.data.insert([id:name], at: 0)
                self.data[1].removeValue(forKey: id)
            }else{
                self.data[0][id] = name
                self.data[1].removeValue(forKey: id)
            }
//            var currentCell = tableView.cellForRow(at: indexPath)
//
//            currentCell?.detailTextLabel?.text = "connecting ..."
            self.tableView?.reloadData()
            
        }
    }
    
    


// MARK: - NetworkManagerProtocole
    
    func receiveMessage(name:String, message:String, isMe: Bool, id:String)
    {
        
    }
    func receiveMessage(message:Message, isMe: Bool, id:String)
    {
        if (message._type == .done) {
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
        if (message._type == .message) {
            print ("------> reception d'un \"Message\"")
            if (self.playerPosition == .seconde) {
                self.gameController?.receiveEquations(equations: message._equations)
                //self.gameController?.timerRTT?.invalidate()
            }
        }
        if (message._type == .ready) {
            print ("------> reception d'un \"Ready\"")
            self.gameController?.updateLabelValueDisplayed()
            StatusBar.sharedInstance.show(status: .ready)
            self.statusDone = (a:false, b:false)
        }
        if (message._type == .response) {
            print ("------> reception d'un \"Response\"")
            self.gameController?.j2EquationResponse.append(message._value1!)
            self.gameController?.resumeView?.tableView?.reloadSections(IndexSet(integer: 0), with: .fade)
        }
        if (message._type == .end) {
            let alerController = UIAlertController(title: "Disconned",
                                                   message: "your opponent left",
                                                   preferredStyle: .alert)
            alerController.addAction(UIAlertAction(title: "Ok",
                                                   style: .default,
                                                   handler: {_ in
                self.networkManager?.close()
            }))
            let controller = UIApplication.shared.windows.first?.rootViewController
            //controller?.present(alerController, animated: true, completion: nil)
            // i.e : l'alert ne 'affiche pas , je ne sais pas pourquoi :/
            // j'ai donc remplacer ca par une alert via la statusBar
            StatusBar.sharedInstance.show(str: "your opponent left", status: .close)
        }
    }
    func receiveServerUpdate(id: [Int: String])
    {
        // je cherche a savoir si j'ai deja un invité
        let currentSection = self.data.count > 1 ? 1 : 0
        self.data[currentSection].removeAll()
        for (k, v) in id {
            if k != self.currentID {
                self.data[currentSection][k] = v
            }
        }
        //self.data[currentSection].merge(id) {(_, new) in new}
        self.tableView?.reloadSections(IndexSet(integer: currentSection), with: .automatic)
    }
    func receiveServerRemove(id: [Int: String]) {
        let (idKey, name) = (id.keys.first, id.values.first)
        for (index, dico) in self.data.enumerated() {
            self.data[index][idKey!] = nil
        }
        // je cherche a savoir si j'ai deja un invité
        let currentSection = self.data.count > 1 ? 1 : 0
        self.tableView?.reloadSections(IndexSet(integer: currentSection), with: .automatic)
    }
    func invitationWasAcceptionByOppenent () {
        self.okItemButton?.isEnabled = true
    }
    @IBAction func actionOkItemButton() {
        self.loadGameViewController()
        self.dismiss(animated: true, completion: {
            
            DispatchQueue.main.async {
                
                self.rootController?.present(self.gameController!,
                             animated: true,
                             completion: nil)
            }
            
        })
    }
    func receiveInvite(id: [Int: String]) {
        let alert = UIAlertController (title: title,
                                       message: "\(id.values.first!) invited you",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .default,
                                      handler: {_ in
            self.loadGameViewController()
            self.dismiss(animated: true, completion: {
                
                DispatchQueue.main.async {
                    
                    let msg = Message(type: .invite)
                    let tmp = msg._toPlayerId
                    msg._toPlayerId = msg._playerID
                    msg._playerID = tmp
                    msg._value1 = 99 // code : ok
                    self.networkManager?.sendPacket(msg)
                    
                    self.rootController?.present(self.gameController!,
                                 animated: true,
                                 completion: nil)
                }
                
            })
            self.playerPosition = .seconde
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: {_ in
            self.playerPosition = .none
            let msg = Message(type: .invite)
            let tmp = msg._toPlayerId
            msg._toPlayerId = msg._playerID
            msg._playerID = tmp
            msg._value1 = -99
            self.networkManager?.sendPacket(msg)
        }))
        playerPosition = .secondWait
        self.present (alert, animated: true, completion: nil)
        
        
        return
        // je cherche a savoir si j'ai deja un invité
        

        if self.data.count == 1 {
            self.data.insert(id, at: 0)
        }else{
            self.data[0][id.keys.first!] = id.values.first!
        }
        
    }
    func error(error: NWError?,title:String)
    {
        
    }
    func statusConnectionUpdate (status:String, color: UIColor)
    {
        DispatchQueue.main.async {
            self.navigatItem?.titleView?.tintColor = color
            self.navigatItem?.title = status
        }
        
    }
    
    func connectionReady(manager: NetworkManager) {
        let msg = Message(type: .newPlayed)
        let playerId = [currentID: UIDevice.current.name]
        msg._playerID = playerId
        self.networkManager?.sendPacket(msg)
    }
    
    @objc func sendDoneMessage()  {
        print ("------> envoie un \"Donne\"")
        let msg = Message(type: .done)
        self.networkManager?.sendPacket(msg)
    }
    
    func sendData (equations : Message) {
        self.networkManager?.sendPacket(equations)
    }
    
}



