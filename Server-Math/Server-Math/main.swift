//
//  main.swift
//  projet-ppm2-server
//
//  Created by ramzi on 01/02/2021.
//

import Foundation
import Network


/*  if server can't start because of port already used
    kill the previous socket listing to your port
    see it on Terminal : netstat -p tcp -a | grep -e ".24088"
    then get the pid sudo lsof -i :24088 et kill it with
    kill -9 commande
 
 */


let port: UInt16 = 24088


print ("creation du serveur .... sur le port : " + String(port))
let serveur = ServeurListener(port: port)

print ("initialisation du serveur ....")
serveur.initialise()
print ("connection démarrée ....")
serveur.start()


print("\u{001B}[0;31m") // red

print ("liste de commande possible :")
print ("    num  : indique le nombre de joueur connecté sur le serveur")
print ("    list : donne la liste des joueurs diponible")

print("\u{001B}[0;0") // color default

while (true) {
    if let name = readLine() {
        if name == "num" {
            print ("il y'a \u{001B}[0;33m\(serveur.getNumberOfPlayer())\u{001B}[0;0m joueur(s) connecté sur le serveur !!!")
        }else if name == "list" {
            print ("voici la list des joueurs disponible : \n \u{001B}[0;33m\(serveur.getListOfPlayer())\u{001B}[0;0m")
        }
    }
}



//dispatchMain()
//RunLoop.main.run()


