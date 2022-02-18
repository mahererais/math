//
//  Tools.swift
//  projet-ppm
//
//  Created by ramzi on 24/01/2021.
//

import Foundation
import UIKit

//#if !targetEnvironment(simulator)
//    func print(_ items: Any..., separator: String = " ", terminator: String = "\n")  {}
//    
//#endif


struct _GAME_CONSTANT {
    
    static let _compteARebour: TimeInterval = 0.4
    static var _scaleRoad:CGFloat           = _TOOLS._isPad ? 2.0: 1.0
    static var _scaleBody:CGFloat           = _TOOLS._isPad ? 1.5: 1
    static var _scaleCoin:CGFloat           = _TOOLS._isPad ? 0.6: 0.4
    static var _scaleTrou:CGFloat           = _TOOLS._isPad ? 1.8: 1.0
    static var _timer_speed: TimeInterval   = _TOOLS._isPad ? 0.015: 0.015
    static var _body_speed: TimeInterval    = 0.6
    static var _road_speed: CGFloat         = _TOOLS._isPad ? 8 : 4
    static var _coin_speed: CGFloat         = _TOOLS._isPad ? 8 : 4
    static let _jump_scale: CGFloat         = _TOOLS._isPad ? 2 : 1.5

}

struct  _TOOLS {
 /*   static func _isSoundUser() -> Bool  {
        let result = PreferenceManager.sharedInstance.loadSound() ??  true
        return result
    }
    static func _isGyroUser() -> Bool {
        return PreferenceManager.sharedInstance.loadSound() ?? true
        
    }
    static func _isChatUser() -> Bool {
        return PreferenceManager.sharedInstance.loadChat() ?? true
        
    }
  */
    static let _isPad:Bool =
    {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            return true
        }else{
            return false
        }
    }()
    
    static func _print(obj: Any?, function: String = #function, _ items: Any...) {
        print(object_getClass(obj)!.description() + "." + function + items.description )
    }
    static func _print(obj: Any?, function: String = #function) {
        print(object_getClass(obj)!.description() + "." + function )
    }
    
    static func _shadow(vue: UIView,
                        _ offset:CGSize = CGSize(width: 0, height: 0),
                        _ opacity: Float = 1,
                        _ isBborder: Bool = true)
    {
        vue.layer.borderWidth = isBborder ? 0.5 : 0
        vue.layer.cornerRadius = 0
        vue.layer.shadowRadius = 3
        vue.layer.shadowPath = UIBezierPath(rect: vue.bounds).cgPath
        vue.layer.shadowOffset = .init(width: offset.width, height: offset.height)
        vue.layer.shadowOpacity = opacity
        vue.layer.shadowColor = UIColor.black.cgColor
        
        if vue.isKind(of: UIButton.self) {
            let vueButton = vue as! UIButton
            vueButton.setTitleColor(.gray, for: .disabled)       // for enabled state
            vueButton.setTitleShadowColor(.clear, for: .disabled)  // for enabled state
        }
        
    }
    
   /* static func _alert(viewController:UIViewController? = _TOOLS.getTopViewController(),
                       title:String = "Error",
                       message:String = #function + "-line:" + String(#line))
    {
        let alert = UIAlertController (title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        viewController?.present (alert, animated: true, completion: nil)
    }
    
    
     static func getTopViewController() -> UIViewController? {
        return UIApplication.shared.windows.first?.getTopViewController()
    }
    */
    
}

struct _CHAT {
    static let myID   = UIDevice.current.identifierForVendor?.description
    static let myUUID = UUID().uuidString
    static let myName = UIDevice.current.name
}


struct _NOTIFICATION {
    static let CHAT_VALUE_DID_CHANGE    = NSNotification.Name ("CHAT_VALUE_DID_CHANGE")
    static let START_COMPTEUR           = "NOTIFICATION_START_COMPTEUR"
    static let STOP_COMPTEUR            = "NOTIFICATION_STOP_COMPTEUR"
}

struct _SERVER {
    static var ip = /*"176.158.155.209"*/ /*"127.0.0.1" */ "192.168.2.98"
    static var port : UInt16   = 24099
}




