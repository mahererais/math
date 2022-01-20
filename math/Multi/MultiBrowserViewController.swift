//
//  MultiBrowserViewController.swift
//  math
//
//  Created by maher on 18/01/2022.
//

import UIKit
import Network

extension MultiBrowserViewController : NetworkManagerProtocole {
    
    func receiveMessage(name:String, message:String, isMe: Bool, id:String)
    {
        
    }
    func receiveMessage(message:Message, isMe: Bool, id:String)
    {
        
    }
    func receiveServerUpdate(number: TimeInterval)
    {
        
    }
    func error(error: NWError?,title:String)
    {
        
    }
    func statusConnectionUpdate (status:String, color: UIColor)
    {
        
    }
    
}

class MultiBrowserViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "mahereCellReuse")
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    

    @IBOutlet var tableView : UITableView!
    var data : [String] = []
    lazy var networkManager = NetworkManager()
    
    deinit {
        self.networkManager.close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let footerView = UILabel(frame: CGRect(x: 0, y: tableView.frame.maxY,
                                              width: tableView.frame.width,
                                              height: 50))
        footerView.backgroundColor = .lightGray
        footerView.text = "no player found"
        footerView.textAlignment = .center
        tableView.tableFooterView = footerView
        
        data.append("maher")
        data.append("rais")
        
        networkManager.delegate = self
        networkManager.startConnectionTCP()
        
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
        self.dismiss(animated: true, completion: nil)
    }

}


