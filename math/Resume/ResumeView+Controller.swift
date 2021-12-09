//
//  GameViewController+resumeView.swift
//  math
//
//  Created by maher on 21/10/2021.
//

import UIKit
import Foundation

extension GameViewController: UITableViewDelegate, UITableViewDataSource {
    
    func showResumeView () {
        self.view.addSubview(self.resumeView!)
        self.resumeView?.display(self.view.bounds,
                                 isMultiplayer: self.multiPeerObject == nil ? false : true)
//        if self.multiPeerObject == nil {
//            print((self.resumeView?.J2Label?.frame.size.width)!)
//            self.resumeView?.J2Label?.frame.size.width = 0
//            print((self.resumeView?.J2Label?.frame.size.width)!)
//        }
        self.resumeView?.tableView?.reloadData()
    }
    
    func hideResumeView () {
        self.resumeView?.removeFromSuperview()
    }
    
    // MARK: Button Actions
    
    
    // MARK: - UITableViewDelegate, UITableViewDataSource Protocols
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print(object_getClass(self)!.description() + "." + #function)
        
        
        
        let reuseID = "ScoreTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseID) as? ScoreTableViewCell
        
        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1,
//                                   reuseIdentifier: reuseID)
            cell = Bundle.main.loadNibNamed(reuseID, owner: self, options: nil)?.first as? ScoreTableViewCell
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            
        }
        
        
        let row = indexPath.row
        if (self.resumeView?.superview != nil) {
            // i.e : la condition a ete ajouté suite a un bug lors que je joue en multi
            // joueur. Cette fonction est appelé lorsque je recois une ".reponse" de
            // l'adversaire apres avoir fait un "retry", ce qui n'est pas le cas
            // lors de la premiere partie. Cette fonction est appele seulement
            // le ResumeView est affiché sur l'ecran
            self.updateCellLabels(cell: cell!, withIndex: row)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: -
    
    
    func updateCellLabels(cell: ScoreTableViewCell, withIndex i: Int) {
        
        let equation = equations[i]
        
       
        cell.updateEquationLabel(n1: equation["value1"]!,
                                  ope: getStringFrom(operateur :Operateur(rawValue: equation["operateur"]!)!),
                                  n2: equation["value2"]!)
        
        cell.updateJoueurLabel(cell.j1Label!,
                          withNumber: j1EquationResponse[i],
                          andResult: equation["resultat"]!)
        
        if (i < j2EquationResponse.count) {
            cell.updateJoueurLabel(cell.j2Label!,
                              withNumber: j2EquationResponse[i],
                              andResult: equation["resultat"]!)
        }else{
            cell.updateJoueurLabel(cell.j2Label!,
                              withNumber: -1,
                              andResult: 0)
        }
        
        cell.updateJ2LabelContrainte(isMultiplayer: self.multiPeerObject == nil ? false : true)
    }
    
    func getStringFrom(operateur : Operateur) -> String {
        switch operateur {
            case .plus: return "+"
            case .moins: return "-"
            case .multication: return "x"
            case .division: return "÷"
        default:
            return ""
        }
    }
    
    
    
    
    

}
