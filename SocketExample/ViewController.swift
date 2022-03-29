//
//  ViewController.swift
//  SocketExample
//
//  Created by 김윤수 on 2022/03/26.
//

import UIKit
import SocketIO

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var socketConnectButton: UIButton!
    @IBOutlet var socketDisconnectButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var joinChatButton: UIButton!
    
    var nickname = ""
    var users: [[String: AnyObject]] = []
    
    @IBAction func touchConnectButton(_ sender: UIButton){
        
        SocketIOManager.shared.establishConnection()
        
    }
    
    @IBAction func touchDisconnecButton(_ sender: UIButton){
        
        SocketIOManager.shared.closeConnection()
        
    }
    
    @IBAction func extiUser(_ sender: UIBarItem) {
     
        SocketIOManager.shared.exitChatWithNickname(nickname: self.nickname) {
            
            DispatchQueue.main.async {
                
                self.nickname = ""
                self.users.removeAll()
                self.askForNickname()
                self.tableView.isHidden = true
                
                
            }
        }
        
    }
    
    func askForNickname() {
        
        let alertController = UIAlertController(title: "채팅", message: "닉네임을 입력하세요", preferredStyle: .alert)
        
        alertController.addTextField()
        
        let action = UIAlertAction(title: "확인", style: .default) { action in
            let textField = alertController.textFields![0]
            if textField.text?.count == 0 {
                
                self.askForNickname()
                
            }
            else {
                
                self.nickname = textField.text!
                
                
                SocketIOManager.shared.connectToServerWithNickName(nickname: self.nickname) {
                    [unowned self] userList in
                    
                    DispatchQueue.main.async {
                        
                        self.users = userList
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                        
                    }
                }
            }
        }
        
        alertController.addAction(action)

        present(alertController, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        var content = cell.defaultContentConfiguration()
        
        content.text = users[indexPath.row]["nickname"] as? String
        
        let stateText = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        let stateColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.green : UIColor.red
        let stateIcon = (users[indexPath.row]["isConnected"] as! Bool) ? UIImage(systemName: "bubble.middle.bottom.fill") : UIImage(systemName: "bubble.middle.bottom")
    
        content.secondaryAttributedText = NSAttributedString(string: stateText, attributes: [.foregroundColor : stateColor])
        content.image = stateIcon
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if nickname.isEmpty {
            askForNickname()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let destinationVC = segue.destination as! ChatViewController
        
        destinationVC.nickname = self.nickname
        
    }
    


}

