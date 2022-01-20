//
//  main.swift
//  projet-ppm2-server
//
//  Created by ramzi on 01/02/2021.
//

import Foundation
import Network

let port: UInt16 = 24099

//let task = Process()
//let pipe = Pipe()
//
//task.standardOutput = pipe
//task.standardError  = pipe
//task.standardInput  = [port, "kill_tcp_onPort.sh"]
//task.launchPath     = "/bin/zsh"
//print (task.debugDescription)
//task.launch()

print ("creation du serveur .... sur le port : " + String(port))
let serveur = ServeurListener(port: port)

print ("initialisation du serveur ....")
serveur.initialise()
print ("connection démarrée ....")
serveur.start()

dispatchMain()

