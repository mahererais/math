//
//  RoundButton.swift
//  math
//
//  Created by maher on 10/10/2021.
//

import UIKit

/**  _ _ _ _ _ _ _ _    SOURCE _ _ _ _ _ _ _ _ _
 https://stackoverflow.com/questions/38874517/how-to-make-a-simple-rounded-button-in-storyboard
 */

@IBDesignable class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
        self.layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
       
//    @IBInspectable var bottomBorder: CGFloat = 0{
//        didSet{
//            let border = CALayer()
//            border.backgroundColor = UIColor.black.cgColor
//            border.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 2)
//            self.layer.addSublayer(border)
//        }
//    }
    
//    @IBInspectable var heightCustome: CGFloat = 0.0 {
//        didSet{
//            self.frame.size.height = self.frame.width
//        }
//    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet{
            self.layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowColor: UIColor = UIColor.white {
        didSet{
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    @IBInspectable var shadowRadius: CGFloat = CGFloat.zero {
        didSet{
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.0 {
        didSet{
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var adjustSizeTitle: Bool = false {
        didSet{
            self.titleLabel!.adjustsFontSizeToFitWidth = adjustSizeTitle
        }
    }
    
    
    


    
}
