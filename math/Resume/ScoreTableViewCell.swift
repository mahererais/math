//
//  ScoreTableViewCell.swift
//  math
//
//  Created by maher on 24/10/2021.
//

import UIKit

@IBDesignable class  ScoreTableViewCell: UITableViewCell {
    
    @IBOutlet var equationLabel : UILabel?
    @IBOutlet var j1Label : UILabel?
    @IBOutlet var j2Label : UILabel?
    


    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet{
            self.j1Label?.layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowColor: UIColor = UIColor.white {
        didSet{
            self.j1Label?.layer.shadowColor = shadowColor.cgColor
        }
    }
    @IBInspectable var shadowRadius: CGFloat = CGFloat.zero {
        didSet{
            self.j1Label?.layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.0 {
        didSet{
            self.j1Label?.layer.shadowOpacity = shadowOpacity
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.j1Label?.adjustsFontSizeToFitWidth = true
        self.j2Label?.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateJ2LabelContrainte(isMultiplayer: Bool) {
        for constraint in self.j2Label!.constraints {
            if constraint.identifier == "myContrainte" /* voir identifier dans le .xib*/ {
                constraint.constant = isMultiplayer ? 50 : 0
            }
        }
    }
    
    func updateJoueurLabel(_ label: UILabel, withNumber n:Int, andResult r: Int)
    {
        label.text = (n == -1) ? "" : "\(n)"
        if (n == r) {
            label.textColor = .systemGreen
        }else{
            label.textColor = .systemPink
        }
    }
    
    func updateEquationLabel (n1: Int, ope: String, n2: Int) {
        self.equationLabel?.text = " \(n1) " + ope + " \(n2) "
    }
    
     
    
}
