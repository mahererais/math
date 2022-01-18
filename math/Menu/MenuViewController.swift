//
//  ViewController.swift
//  math
//
//  Created by maher on 07/10/2021.
//

import UIKit
import GameKit


enum Player {
    case solo, duo, none
}

class MenuViewController: UIViewController {
    

    @IBOutlet weak var batailleButton: UIButton!
    @IBOutlet weak var seulButton: UIButton!
    @IBOutlet weak var plusButton: OperatorView!
    @IBOutlet weak var moinsButton: OperatorView!
    @IBOutlet weak var multiButton: OperatorView!
    @IBOutlet weak var divisButton: OperatorView!
    @IBOutlet weak var operatorsViews: UIView!
    
    @IBOutlet var statusBarController : StatusBar?
    
    var multi : MultiBrowserViewController? = nil
    
    var operateur : String = ""
    var typeMultiPlayer : Player = .none
//    let window = UIWindow()
    
    // MARK: -
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addShadow()
       
        self.statusBarController?.initStatusBar()
        
        // Do any additional setup after loading the view.
        print(object_getClass(self)!.description() + "." + #function)
        
        self.batailleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.seulButton.titleLabel?.adjustsFontSizeToFitWidth = true
        // **********************************************************
        self.addGestureTo(button: self.multiButton, direction: [.up, .down])
        self.addGestureTo(button: self.divisButton, direction: [.up, .down])
        // **********************************************************
        self.addGestureTo(button: self.plusButton, direction: [.up, .down])
        self.addGestureTo(button: self.moinsButton, direction: [.up, .down])
        // **********************************************************
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print (self.view.window!.autoresizingMask.rawValue.description)
        self.operateur = ""
        self.showOperatorButtons( false, animated: false, button: nil)
    }

    @IBAction func action(sender: UIButton) {
        
        let operatorView: OperatorView = sender as! OperatorView;
        self.operateur = operatorView.getOperatorString()
        print(object_getClass(self)!.description() + "." + #function + " -> " + self.operateur)
        
        if (typeMultiPlayer == .solo)
        {
            let gameController: GameViewController = GameViewController(ope: self.operateur);
            gameController.modalPresentationStyle = .fullScreen
            self.present(gameController,
                         animated: true,
                         completion: nil)
        }
        else if (typeMultiPlayer == .duo)
        {
            
            //multi = MultiSearchViewController()
            multi = MultiBrowserViewController()
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                //multi?.browserController?.modalPresentationStyle = .overFullScreen
            }else{
                multi?.modalPresentationStyle = .overFullScreen            }
            //multi?.initialiseBrowser(rootController: self, ope: self.operateur)
            
            self.present(multi!, animated: true, completion:  nil)
            
        }


    }
    
    func addGestureTo( button: UIView, direction: UISwipeGestureRecognizer.Direction) {
        
        let gesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.hideBatailleButton)
        )
        gesture.direction = direction
        button.addGestureRecognizer(gesture)
    }
    
    //static var i = 0
    @IBAction func actionSeul (button: UIButton) {
        
//        if MenuViewController.i % 2 == 0 {
//            StatusBar.sharedInstance.show(str: "hello", level: .green)
//        }else{
//            StatusBar.sharedInstance.hide()
//        }
//        MenuViewController.i += 1
//        return
        
//        self.gameCenterController()
//        return
        
        
        if typeMultiPlayer == .solo {
            // je cache le bouton solo et j'affiche les operateur en haut
            //self.operatorsViews.frame.origin = CGPoint.zero
            self.hideBatailleButton()
            typeMultiPlayer = .none
        }else{
            // je cache le bouton "duo" et j'affiche les operateur en bas
            self.operatorsViews.frame.origin = CGPoint(x: 0,
                                                       y: self.view.superview!.frame.midY)
            
            typeMultiPlayer = .solo
            self.showOperatorButtons(true, animated: true, button: self.seulButton)
            self.multi = nil
            
            (self.plusButton.gestureRecognizers!.first as! UISwipeGestureRecognizer).direction = .up
            (self.moinsButton.gestureRecognizers!.first as! UISwipeGestureRecognizer).direction = .up
            (self.divisButton.gestureRecognizers!.first as! UISwipeGestureRecognizer).direction = .up
            (self.multiButton.gestureRecognizers!.first as! UISwipeGestureRecognizer).direction = .up
        }
       
        
    }
    
    @IBAction func actionBataille (button: UIButton) {
        
        
        if typeMultiPlayer == .duo {
            // je cache le bouton solo et j'affiche les operateur en haut
//            self.operatorsViews.frame.origin = CGPoint(x: 0,
//                                                       y: self.view.superview!.frame.midY)
            self.hideBatailleButton()
            typeMultiPlayer = .none
            
        }else{
            // je cache le bouton "duo" et j'affiche les operateur en bas
            
            typeMultiPlayer = .duo
            self.operatorsViews.frame.origin = CGPoint.zero
            
            self.showOperatorButtons(true, animated: true, button: button)
        
            (self.plusButton.gestureRecognizers!.first as! UISwipeGestureRecognizer).direction = .down
            (self.moinsButton.gestureRecognizers!.first as! UISwipeGestureRecognizer).direction = .down
            (self.divisButton.gestureRecognizers!.first as! UISwipeGestureRecognizer).direction = .down
            (self.multiButton.gestureRecognizers!.first as! UISwipeGestureRecognizer).direction = .down
        }
        
        
    }
    
    
    @objc func hideBatailleButton() {
        print(object_getClass(self)!.description() + "." + #function)
        self.showOperatorButtons(false, animated: true, button: nil)
        //StatusBar.sharedInstance.hide(animated: true)
    }
    
    func showOperatorButtons (_ isHidden: Bool, animated: Bool = true, button: UIButton?) {
        
        
        UIView.animate(withDuration: animated ? 0.5 : 0.0, delay: 0, options: .curveEaseInOut,
                       animations: {
            
            if (isHidden) {
                // j'affiche les boutons "operateur"
                if button == self.batailleButton {
                    self.seulButton.center = CGPoint(x: self.view.center.x,
                                                     y: -1 * (self.seulButton.bounds.height / 2))
                }else{
                    self.batailleButton.center = CGPoint(x: self.view.center.x,
                                                         y: self.view.bounds.height
                                                         + (self.batailleButton.bounds.height / 2))
                }
            }else{
                // je cache les boutons "operateur"
                self.seulButton.center = CGPoint(x: self.view.center.x,
                                                 y: (self.seulButton.bounds.height / 2))
                self.batailleButton.center = CGPoint(x: self.view.center.x,
                                                     y: self.view.bounds.height
                                                     - (self.batailleButton.bounds.height / 2))
                self.typeMultiPlayer = .none
            }
            
        },
                       completion: nil)
        
        
//        self.seulButton.isHidden     = isHidden
//        self.progressButton.isHidden = isHidden
//        self.batailleButton.isHidden = isHidden
    }
    
    func addShadow() {
        
        func addShadow(button: UIButton, offSetHeight: CGFloat) {
            button.layer.shadowOpacity = 1
            button.layer.shadowOffset = CGSize(width: 0, height: offSetHeight)
            button.layer.shadowRadius = 4
            button.layer.shadowColor  = UIColor.black.cgColor
            
//            button.layer.borderColor = UIColor.black.cgColor
//            button.layer.borderWidth = 2
        }
        addShadow(button: batailleButton, offSetHeight: 3)
        addShadow(button: seulButton, offSetHeight: -3)
    }
    
}

extension MenuViewController : GKMatchmakerViewControllerDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        let _ = 1
    }
    

    func gameCenterController() {
        
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { (controller , error) in
            if error != nil {
                print("***** " + error!.localizedDescription)
            }
            
            if controller != nil {
                self.present(controller!, animated: true, completion: nil)
            }
        }
        
        let matchResquest = GKMatchRequest()
        matchResquest.minPlayers = 2
        matchResquest.maxPlayers = 2
        
        DispatchQueue.main.async {
            let gameCenterController = GKMatchmakerViewController(matchRequest: matchResquest)
            gameCenterController?.matchmakerDelegate = self
            if let gcc = gameCenterController {
                self.present(gcc, animated: true, completion: nil)
            }
            
        }
    }

}

