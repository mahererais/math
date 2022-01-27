//
//  GameViewController.swift
//  math
//
//  Created by maher on 07/10/2021.
//

import UIKit
import Foundation

class GameViewController: UIViewController {
    
    @IBOutlet var operatorLabel: UILabel?
    @IBOutlet var value1Label: UILabel?
    @IBOutlet var value2Label: UILabel?
    @IBOutlet var resultatLabel: UILabel?
    @IBOutlet var okButton: UIButton?
    @IBOutlet var resumeView : ResumeView?
    
    
    let maxEquation = 10
    
    var playerPosition : PlayerPosition = .none
    
    var equation: EquationObject?
    var etape : Int = 0
    var equations: [[String: Int]] = []
    
    var operatorString : String?
    
    var multiPeerObject: MultiViewController?
    //weak var multiPeerObject: MultiSearchViewController?
   
    var j1EquationResponse : [Int] = []
    var j2EquationResponse : [Int] = []
    
    // MARK: -
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.resumeView?.display(CGRect(origin: .zero
                                        , size: size),
                                 isMultiplayer: self.multiPeerObject == nil ? false : true)
    }
    
    
    init(ope : String, multiPeerObject: MultiSearchViewController? = nil, position: PlayerPosition = PlayerPosition.none) {
        super.init(nibName: "GameViewController", bundle: nil)
        self.operatorString = ope
        self.multiPeerObject = multiPeerObject
        self.playerPosition = position
        self.etape = 0
    }
    init(ope : String, multiBrowserObject: MultiBrowserViewController? , position: PlayerPosition = PlayerPosition.none) {
        super.init(nibName: "GameViewController", bundle: nil)
        self.operatorString = ope
        self.multiPeerObject = multiBrowserObject
        self.playerPosition = position
        self.etape = 0
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        print(object_getClass(self)!.description() + "." + #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultatLabel?.adjustsFontSizeToFitWidth = true
        
        let gesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.backToMenu)
        )
        gesture.direction = .down
        self.view.addGestureRecognizer(gesture)

        // Do any additional setup after loading the view.
        
        self.initNewGame()
        
        
    }
    
    func initNewGame() {
        self.j1EquationResponse.removeAll()
        self.j2EquationResponse.removeAll()
        self.etape = 0
        
        
        self.clearAllLabelValues()
        
        if (self.multiPeerObject == nil) {
            self.playerPosition = .first
            self.initialiseEquations(oper: self.operatorString!,
                                     iterationNumber: maxEquation)
            self.updateLabelValueDisplayed()
        }
        print(self.equations)
        
    }
    
    func clearAllLabelValues() {
        self.operatorLabel?.text =  ""
        self.value1Label?.text = ""
        self.value2Label?.text = ""
        self.resultatLabel?.text = ""
        self.okButton?.isEnabled = false
        self.okButton?.setTitleColor(.gray, for: .disabled)
        self.okButton?.alpha = 0.5
    }
    
    @objc func updateLabelValueDisplayed() {
        let o = Operateur(rawValue: equations[etape]["operateur"]!)
        self.operatorLabel?.text =  convertOperateurToString(o: o!)
        
        self.value1Label?.text = String(equations[etape]["value1"]!)
        self.value2Label?.text = String(equations[etape]["value2"]!)
        self.resultatLabel?.text = ""
        
        self.animateLabel(view: self.value1Label!)
        self.animateLabel(view: self.value2Label!)
        self.animateLabel(view: self.resultatLabel!)
        self.okButton?.isEnabled = false
        self.okButton?.alpha = 0.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (self.multiPeerObject != nil){
            let str = "waiting for player n°\(self.playerPosition == .first ? "2" : "1")"
            StatusBar.sharedInstance.show(str: str, status: .wait)
            if (self.playerPosition == .first) {
                self.multiPeerObject!.statusDone.a = true
                self.multiPeerObject?.sendDoneMessage()
            }else if (self.playerPosition == .seconde) {
                self.multiPeerObject!.statusDone.b = true
                if self.multiPeerObject!.statusDone.a == true {
                    self.multiPeerObject?.sendDoneMessage()
                    StatusBar.sharedInstance.show(status: .sync)
                }else{
                    // je fais rien , j'attend que le "player 1" m'envoie la notification "done"
                    // i.e : voir dans MultiSearchViewController.receiveData(:)
                }
            }
            
        }
    }
    
    @objc func sendEquations() {
        self.initialiseEquations(oper: self.operatorString!, iterationNumber: maxEquation)
        //self.updateNewEquation()
        StatusBar.sharedInstance.show(status: .sync)
        
        let message = Message(type: .message)
        message._operateur = self.operatorString
        message._equations = self.equations
        self.multiPeerObject?.sendData(equations: message)
        print ("------> envoie de \"l'equation\"")
    }
    
    func receiveEquations(equations: [[String: Int]]) {
//        if (!self.equations.isEmpty) {
//            return
//        }
            
        self.equations = equations
        let message = Message(type: .ready)
        self.multiPeerObject?.sendData(equations: message)
        print ("------> envoie un \"Ready\"")
        self.multiPeerObject?.statusDone = (a:false, b:false)
        self.updateLabelValueDisplayed()
        StatusBar.sharedInstance.show(status: .ready)
    }
    
//    @objc func newEquation() {
//        self.operatorLabel.text = operatorString!
//        equation = EquationObject(operateur: operatorString!)
//        print (equation!.description)
//
//        self.value1Label.text = String(equation!.value1)
//        self.value2Label.text = String(equation!.value2)
//        self.resultatLabel.text = ""
//
//        self.animateLabel(view: self.value1Label)
//        self.animateLabel(view: self.value2Label)
//        self.animateLabel(view: self.resultatLabel)
//
//        //self.multiPeerObject?.sendString(str: "clear")
//        let msg = Message(type: .message)
//        msg._btPressed = "clear"
//        self.multiPeerObject?.sendData(equations: msg)
//    }
    
    func animateLabel(view: UIView) {
        UIView.transition(
            with: view,
            duration: 0.5,
            options: [.transitionCurlUp],
            animations: {
                
            },
            completion: { (finish) in
                
        })
    }
    
     @objc func backToMenu () {
        self.multiPeerObject?.sendData(equations: Message(type: .end))
       
        self.dismiss(animated: true, completion: {
            self.multiPeerObject?.stopMultiService()
            //self.multiPeerObject?.networkManager?.close()
        })
    }
    
    @IBAction func numberPressed(button: UIButton) {
        let currentValue = Int(button.titleLabel!.text!) ?? -1
        print ("value pressed : \(currentValue)")
        self.okButton?.isEnabled = true
        self.okButton?.alpha = 1
        self.updateResultatLabelWith(newNumber: currentValue)
        //self.finishPressed(button: UIButton())
    }
    
    func updateResultatLabelWith(newNumber: Int) {
        let resultatValue = self.resultatLabel!.text!
        if (resultatValue == "") {
            self.resultatLabel?.text = String(newNumber)
        }else{
            let newResult =  Int(resultatValue)! * 10 + newNumber
            self.resultatLabel?.text = String(newResult)
            //let resultatValue_ = self.resultatLabel?.text!
        }
    }
    
    
    @IBAction func ACPressed(button: UIButton?) {
        // je supprime le dernier chiffre
        let resultatValue = self.resultatLabel!.text!
        if (resultatValue == "??"  ||  resultatValue == "" || Int(resultatValue)! < 10) {
            // je fais rien
            // rien a supprimer
            self.okButton?.isEnabled = false
            self.okButton?.alpha = 0.5
            self.resultatLabel!.text = ""
        }else{
            let newResult =  Int(resultatValue)! / 10
            self.resultatLabel!.text = String(newResult)
        }
    }
    
    @IBAction func finishPressed(button: UIButton?) {
        
        let resultatValue = Int(self.resultatLabel!.text!) ?? -1
        if (etape < maxEquation && !self.equations.isEmpty) {
            //if (resultatValue == self.equations[etape]["resultat"]!) {
            if (true) {
                // bonne reponse
                self.j1EquationResponse.append(resultatValue)
                let msg = Message(type: .response)
                msg._value1 = resultatValue
                self.multiPeerObject?.sendData(equations: msg)
                
                self.etape += 1
            
                if (etape < maxEquation) {
                    self.perform(
                        #selector(/*newEquation*/updateLabelValueDisplayed),
                        with: nil,
                        afterDelay: 0.0
                    )
                }else{
                    StatusBar.sharedInstance.show(status: .finish)
                    self.showResumeView()
                }
                
            }
        }
        
        
    }
    
    @IBAction func retryButton(sender : Any?) {
        self.initNewGame()
        self.hideResumeView()
        self.viewDidAppear(false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initialiseEquations (oper : String, iterationNumber : Int) {
        self.equations.removeAll()
        for _ in 0..<iterationNumber {
            let e = EquationObject(operateur: oper)
            let dico : [String: Int] = ["value1" : e.value1,
                                         "value2" :e.value2,
                                         "operateur" :  convertOperateurType(e.operateur).rawValue,
                                         "resultat" : e.resultat]
            self.equations.append(dico)
        }
        //equations.description
    }
    
    func convertOperateurType(_ o : String) -> Operateur{
        switch o {
            case "+": return .plus
            case "-": return .moins
            case "x": return .multication
            case "÷": return .division
        default:
            return .unknown
        }
    }
    
    func convertOperateurToString(o : Operateur) -> String {
        switch o {
            case .plus: return "+"
            case .moins: return "-"
            case .multication: return "x"
            case .division: return "÷"
        default:
            return ""
        }
    }
    
//    func updateStatusMulti (str :MultiStatus) {
//        var message = ""
//        self.statusMultiButton?.alpha = 1.0
//        switch str {
//        case .ready:
//            self.statusMultiButton?.backgroundColor = .systemGreen
//            message = "ready"
//            self.statusMultiButton?.perform(#selector(setter: view.alpha),
//                                            with: CGFloat(1.0),
//                                            afterDelay: 2.0)
//        case .sync:
//            self.statusMultiButton?.backgroundColor = .systemOrange
//            message = "synchonisation"
//        case .wait:
//            self.statusMultiButton?.backgroundColor = .systemPink
//            message = "waiting for player n°\(self.playerPosition == .first ? "2" : "1")"
//        case .finish:
//            self.statusMultiButton?.backgroundColor = .systemGreen
//            message = "Finish !!"
//        default:
//            self.statusMultiButton?.backgroundColor = .clear
//        }
//        
//        self.statusMultiButton?.setTitle(message, for: .normal)
//        
//    }
    
    
    //@available (macCatalyst 13.4, *)
//#if targetEnvironment(macCatalyst)
    @available (iOS 9.0, *)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print ("*** pressesBegan ***")
        var isNumeriqueKey = false
        
        for press in presses {
            guard let key = press.key else {continue}
            switch key.characters {
                case "0": isNumeriqueKey = true
                case "1": isNumeriqueKey = true
                case "2": isNumeriqueKey = true
                case "3": isNumeriqueKey = true
                case "4": isNumeriqueKey = true
                case "5": isNumeriqueKey = true
                case "6": isNumeriqueKey = true
                case "7": isNumeriqueKey = true
                case "8": isNumeriqueKey = true
                case "9": isNumeriqueKey = true
            default:
                let _ = 1
            }
            if isNumeriqueKey {
//                self.updateResultatLabelWith(newNumber: Int(key.characters)!)
//                self.finishPressed(button: UIButton())
                let b = UIButton()
                b.setTitle(key.characters, for: .normal)
                self.numberPressed(button: b)
                break
            }
            
            if #available(macCatalyst 13.4, iOS 13.4, *) {
                if (key.keyCode ==  UIKeyboardHIDUsage.keyboardDeleteOrBackspace) {
                    self.ACPressed(button: nil)
                }
                
                if (key.keyCode ==  UIKeyboardHIDUsage.keyboardReturnOrEnter ||
                    key.keyCode ==  UIKeyboardHIDUsage.keypadEnter) {
                    self.finishPressed(button: UIButton())
                }
                
            }
            
        }
        
    }
//#endif
    
}
