//
//  ResumeView.swift
//  math
//
//  Created by maher on 21/10/2021.
//

import UIKit

@IBDesignable class ResumeView: UIView {

    @IBOutlet var tableView : UITableView?
    @IBOutlet var MenuButton : UIButton?
    @IBOutlet var replayButton : UIButton?
    @IBOutlet var J2Label: UILabel?
    @IBOutlet var J1Label: UILabel?
    @IBOutlet var EquationLabel: UILabel?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    func display(_ rect: CGRect, isMultiplayer: Bool) {
        // Drawing code
        
        let w = floor(rect.size.width * 0.75)
        let h = floor(rect.size.height * 0.65)
        self.frame = CGRect(x: 0, y: 0, width: w, height: h)
        self.center = CGPoint(x:rect.midX, y:rect.midY)
        
//        self.EquationLabel?.frame.size.width = 80.0
//        self.EquationLabel?.frame = CGRect(x: self.EquationLabel!.frame.minX,
//                                           y: self.EquationLabel!.frame.minY,
//                                           width: self.EquationLabel!.frame.width,
//                                           height: 150)
        // i.e : impossible de reduire la largeur a 0 parce que J2Label.width a une contrainte
        for constraint in self.J2Label!.constraints {
            if constraint.identifier == "myContrainte" /* voir identifier dans le .xib*/ {
                constraint.constant = isMultiplayer ? 50 : 0
            }
        }
        
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        self.layer.borderWidth  = 2.0
        self.layer.borderColor  = UIColor.black.cgColor
        self.layer.cornerRadius = 0.0
        
        context?.restoreGState()
        self.layer.shadowColor   = UIColor.black.cgColor
        self.layer.shadowOffset  = CGSize(width: 0, height: 0)
        self.layer.shadowRadius  = 10
        self.layer.shadowOpacity = 1
        
        self.tableView?.separatorStyle = .none
        
        
    }
    
    
    // MARK: - @IBInspectable
    
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
    
    
    override func awakeFromNib() {
        print(object_getClass(self)!.description() + "." + #function)
        self.tableView?.backgroundColor = .lightGray
    }

}
