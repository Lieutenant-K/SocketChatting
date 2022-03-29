//
//  SocketIOManager.swift
//  SocketExample
//
//  Created by 김윤수 on 2022/03/26.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let shared = SocketIOManager()
    var manager = SocketManager(socketURL: URL(string: "http://172.30.1.30:3000")!)
    var socket: SocketIOClient!
        
    
    func establishConnection() {
        
        socket.connect()
        print("연결")
        
    }
    
    func closeConnection() {
        
        socket.disconnect()
        print("해제")
        
    }
    
    func sendMessage(message: String, nickname: String){
        
        socket.emit("chatMessage", nickname, message)
        
    }
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: Any]) -> Void) {
        
        socket.on("newChatMessage") { dataArray, ack in
            var messageDictionary = [String: Any]()
            messageDictionary["nickname"] = dataArray[0] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            
            completionHandler(messageDictionary)
        }
        
    }
    
    private func listenForOtherMessage() {
        
        socket.on("userConnectUpdate") { dataArray, ack in
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
            
        }
        
        socket.on("userExitUpdate") { dataArray, ack in
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
            
        }
        
        socket.on("userTypingUpdate") { dataArray, ack in
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userTypingNotification"), object: dataArray[0] as? [String: AnyObject])
            
        }
    }
    
    func connectToServerWithNickName(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]) -> Void) {
        
        socket.emit("connectUser", nickname)
        
        socket.on("userList") { dataArray, ack in
            completionHandler(dataArray[0] as! [[String: AnyObject]])
        }
        
        listenForOtherMessage()
        
    }
    
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        
        socket.emit("exitUser", nickname)
        completionHandler()
        
    }
    
    func sendStartTypingMessage(nickname: String) {
        
        socket.emit("startType", nickname)
        
    }
    
    func sendStopTypingMessage(nickname: String) {
        
        socket.emit("stopType", nickname)
        
    }
    
    override init(){
        super.init()

        socket = self.manager.socket(forNamespace: "/")
        
        
    }
    
    
}
