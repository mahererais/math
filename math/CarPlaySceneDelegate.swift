//
//  CarPlaySceneDelegate.swift
//  math
//
//  Created by maher on 02/11/2021.
//

import CarPlay

/** SOURCE
    Link : https://medium.com/@vipulkumar273/create-apps-for-apple-carplay-in-ios-14-swift-f83f0538fd82
    **/

@available(iOS 13.0, *)
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    

    var interfaceController: CPInterfaceController?
    
    
     // CarPlay connected
    @available(iOS 14.0, *)
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                   didConnect interfaceController: CPInterfaceController)
    {
        
        self.interfaceController = interfaceController
        
        // creating the tab section
        let tabFavs = CPListItem(text: "Favorite", detailText: "subtitle for favorites")
        let tabRecent = CPListItem(text: "Most Recent", detailText: "subtitle for Most Recent")
        let tabHistory = CPListItem(text: "History", detailText: "subtitle for History")
        
        // adding the above tabs in section
        let sectionA = CPListSection(items: [tabRecent, tabFavs])
        let sectionB = CPListSection(items: [tabHistory])
        
        let listTemplate = CPListTemplate(title: "", sections: [sectionA])
        let listTemplateA = CPListTemplate(title: "", sections: [sectionB])
        
        
        // creating tabs
        let tabA : CPListTemplate = listTemplate
        tabA.tabSystemItem = .favorites
        tabA.showsTabBadge = false
        
        let tabB : CPListTemplate = listTemplateA
        tabA.tabSystemItem = .history
        tabA.showsTabBadge = true
        
        let tabBarTemplate = CPTabBarTemplate(templates: [tabA, tabB])
        self.interfaceController?.setRootTemplate(tabBarTemplate, animated: true, completion: nil)
     }
     // CarPlay disconnected
    private  func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                           didDisconnect interfaceController: CPInterfaceController)
    {
        self.interfaceController = nil
    }
    

}
