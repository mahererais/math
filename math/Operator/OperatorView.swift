//
//  OperatorView.swift
//  math
//
//  Created by maher on 07/10/2021.
//

import UIKit

class OperatorView: RoundButton {
    
    var _operator: OperatorObject?
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        
        self._operator = OperatorObject(o: self.titleLabel!.text!)
        print(self._operator?._operator ?? "unknown")
    }
    
    func getOperatorString() -> String! {
        return self._operator?._operator ?? "unknown operator ...";
    }

}
