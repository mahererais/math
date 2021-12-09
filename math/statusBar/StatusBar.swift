//
//  StatusBarView.swift
//  math
//
//  Created by maher on 26/10/2021.
//  ...........

import UIKit

enum StatusBarLevel {
    case green
    case orange
    case red
}

enum MultiStatus {
    case wait, sync, ready, none, finish, close
}

@IBDesignable class StatusBar: UIViewController {
    
    //weak var window : UIWindow?
    
    let window = UIWindow()
    
    // MARK: singleton code
    
    fileprivate static var instance : StatusBar?
    
    static func Destroy () {
        StatusBar.instance = nil
    }
    
    static var sharedInstance : StatusBar {
        if StatusBar.instance == nil {
            StatusBar.instance = StatusBar()
        }
        return StatusBar.instance!
    }

    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
//    override var canBecomeFirstResponder: Bool {
//        return false
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.resizingWindows(size: size)
        /*
         IL FAUT QUE TU CREES UNE FONCTION "DISPLAY" QUI VA RE-DESSINER PROPREMENT
         ET DANS LES BONNES COORDONNEES DU WINDOW DE LA STATUS BAR
         */
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override func awakeFromNib() {
        //self.view.isHidden = true
        StatusBar.instance = self
    }
    
    func initStatusBar () {
        //let oldFrame: CGRect? = self.view.frame
        window.windowLevel = .normal
        //window.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
        print (window.autoresizingMask.rawValue.description)

        if #available(iOS 13.0, *) {
            let s = UIApplication.shared.connectedScenes.first
            window.windowScene = s as? UIWindowScene
        }
        window.backgroundColor = .clear
        window.isUserInteractionEnabled = true
        window.rootViewController = self
        window.makeKeyAndVisible()
        
        let size = self.view.frame.size
        let w = size.width
        let h = size.height * 74 / 926 // 74 / 926
        window.bounds = self.view.bounds //UIScreen.main.bounds
        window.bounds.size   =  /*size*/ CGSize(width: w, height: h)
        self.resizingWindows(size: self.view.frame.size)
//        window.frame.size = size
//        window.frame.size.width  = UIScreen.main.bounds.size.width
//        window.frame.size.height = UIScreen.main.bounds.size.height * 74 / 926
        
        self.hide()
        (self.view as! UIButton).setTitle("maher", for: .normal)
        
        let gesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.hide)
        )
        gesture.direction = .up
        self.view.addGestureRecognizer(gesture)

    }
    
    func resizingWindows(size: CGSize) {
//        window.bounds = UIScreen.main.bounds
//        self.view.frame.size = size
//        self.view.frame.size.width  = size.width
//        self.view.frame.size.height = size.height * 74 / 926 // 74 / 926
        
        //let w = size.width
        //let h = size.height * 74 / 926 // 74 / 926
        //window.bounds.origin = CGPoint.zero
        //window.bounds.size   =  /*size*/ CGSize(width: w, height: h)
        window.frame.origin = CGPoint.zero
        self.view.frame = self.window.bounds // CGSize(width: w, height: h)
    }
    
    
    func show(str: String, level: StatusBarLevel) {
        self.updateLabel(str: str, level: level)
        self.show()
    }
    
    func show (str: String, status: MultiStatus) {
        self.updateLabel(str: str, status: status)
        if status == .ready || status == .finish || status == .close {
            self.show(fix: false)
            
        }else{
            self.show(fix: true)
        }
    }
    
    func show (status: MultiStatus) {
        switch status {
        case .ready:
            self.show(str: "Ready", status: status)
        case .sync:
            self.show(str: "Synchonisation", status: status)
        case .wait:
            let str = "waiting for player"
            self.show(str: str, status: status)
        case .finish:
            self.show(str: "Finish !!", status: status)
        case .close:
            self.show(str: "Your Opponent left the game !!", status: status)
        default:
            fatalError("erreur " + #function)
        }
    }
    
    
    private func show(fix: Bool = true) {
        self.view.isHidden = false

        //self.view.layer.removeAllAnimations() // NE FONCTIONNE PAS
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.hide),
                                               object: nil)
        
        window.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut,
                       animations: {
                                let screenSize = self.view.frame.size
                                
                                let o = CGPoint.zero
                                let s = CGSize(width: screenSize.width,
                                               height: screenSize.height)
                                self.view.frame = CGRect(origin: o, size: s)
        },
                       completion: { finished in
            if !fix {
                self.perform(#selector(self.hideAnimated), with: nil
                             , afterDelay: 2)
                
            }
            
        })
        
    }
    @objc func hideAnimated() {
        self.hide(animated: true)
    }
    
    @objc func hide (animated : Bool = false) {
//        let screenSize = CGSize (width: (UIApplication.shared.keyWindow?.frame.width)!,
//                                 height: (UIApplication.shared.keyWindow?.frame.height)!)
        
        UIView.animate(withDuration: animated ? 0.3: 0 , delay: 0, options: .curveEaseInOut,
                       animations:  {
            let screenSize = self.view.frame.size
            let o = CGPoint(x: 0, y: -screenSize.height - 15)
            let s = CGSize(width: screenSize.width,
                           height: screenSize.height)
            self.view.frame = CGRect(origin: o, size: s)
        }, completion: {_ in
            self.window.isHidden = true
        })
        
        
    }
    
    func updateLabel(str: String, level: StatusBarLevel = .green) {
        (self.view as! RoundButton).setTitle(str, for: .normal)
        switch level {
        case .green:
            self.view.backgroundColor = .systemGreen
        case .orange:
            self.view.backgroundColor = .systemOrange
        case .red:
            self.view.backgroundColor = .systemPink
        default:
            fatalError("erreur dans la fonction " + #function + " ligne : ??")
        }
    }
    
    func updateLabel(str: String, status: MultiStatus) {
        (self.view as! RoundButton).setTitle(str, for: .normal)
        switch status {
        case .sync:
            self.view.backgroundColor = .systemOrange
        case .ready:
            self.view.backgroundColor = .systemGreen
        case .finish:
            self.view.backgroundColor = .systemGreen
        case .wait:
            self.view.backgroundColor = .systemPink
        case .close:
            self.view.backgroundColor = .systemPink
        default:
            fatalError("erreur dans la fonction " + #function + " ligne : ??")
        }
    }
    

}
