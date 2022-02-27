//
//  HighlightedButton.swift
//  math
//
//  Created by maher on 27/02/2022.
//

import Foundation
import UIKit


class HighlightedButton : RoundButton {
    
    var initialBackgrounColor : UIColor?
    var highlightedColor : UIColor?  = UIColor(named: "highlightedColor")

    override func awakeFromNib() {
        self.initialBackgrounColor = self.backgroundColor?.copy() as? UIColor
    }

    // SOURCE : https://swiftstudent.com/2020-06-04-custom-uibutton-highlighting/
    override var isHighlighted: Bool {
        didSet {
            if oldValue == false && isHighlighted {
                self.backgroundColor = initialBackgrounColor?.withAlphaComponent(0.8)
            } else if oldValue == true && !isHighlighted {
                self.backgroundColor = initialBackgrounColor
            }
        }
    }
    
}




