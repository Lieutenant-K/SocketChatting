//
//  ChatViewController.swift
//  SocketExample
//
//  Created by 김윤수 on 2022/03/28.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var otherUserStatusLabel: UILabel!
    
    @IBOutlet weak var tvMessageEditor: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblNewsBanner: UILabel!
    
    
    
    var nickname: String!
    
    var chatMessages = [[String: Any]]()
    
    var bannerLabelTimer: Timer!
    
    
    // MARK: - LifeCycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectedUserUpdateNotification(notification:)), name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDisconnectedUserUpdateNotification(notification:)), name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserTypingNotification(notification:)), name: NSNotification.Name(rawValue: "userTypingNotification"), object: nil)
        
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeGestureRecognizer.direction = .down
        swipeGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        configureTableView()
        configureNewsBannerLabel()
        configureOtherUserStatusLabel()
        
        tvMessageEditor.delegate = self

        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.shared.getChatMessage { messageInfo in
            DispatchQueue.main.async {
                
                self.chatMessages.append(messageInfo)
                self.tableView.reloadData()
                
            }
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    
    // MARK: - IBAction Methods
    
    @IBAction func sendMessage(_ sender: AnyObject) {

        if tvMessageEditor.text.count > 0 {
            
            SocketIOManager.shared.sendMessage(message: tvMessageEditor.text!, nickname: self.nickname)
            tvMessageEditor.text = nil
            dismissKeyboard()
            
        }
        
        
    }

    
    // MARK: - Custom Methods
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        
//        tableView.registerNib(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "idCellChat")
        tableView.estimatedRowHeight = 90.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    
    func configureNewsBannerLabel() {
        
        lblNewsBanner.layer.cornerRadius = 15.0
        lblNewsBanner.clipsToBounds = true
        lblNewsBanner.alpha = 0.0
        
    }
    
    
    func configureOtherUserStatusLabel() {
        
        otherUserStatusLabel.isHidden = true
        otherUserStatusLabel.text = ""
        
    }
    
    
    @objc func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {return}
        
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
                    
        UIView.animate(withDuration: duration) { [unowned self] in
            
            self.bottomConstraint.constant = keyboardFrame.size.height - view.safeAreaInsets.bottom
            
        }
                
        
    }
    
    
    @objc func handleKeyboardWillHideNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {return}
        
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: duration) { [unowned self] in
            
            self.bottomConstraint.constant = 0
            
        }
        
        
    }
    
    @objc func handleConnectedUserUpdateNotification(notification: Notification) {
        
        let connectedUserInfo = notification.object as! [String: AnyObject]
        let connectedUserNickname = connectedUserInfo["nickname"] as! String
        lblNewsBanner.text = "User \(connectedUserNickname) was just connected."
        showBannerLabelAnimated()
        
        
    }
    
    @objc func handleDisconnectedUserUpdateNotification(notification: Notification) {
        
        let disconnectedUserNickname = notification.object as! String
        lblNewsBanner.text = "User \(disconnectedUserNickname) has left."
        showBannerLabelAnimated()
        
    }
    
    @objc func handleUserTypingNotification(notification: Notification){
        
        print("호출")
        
        if let typingUserDictionary = notification.object as? [String: AnyObject] {
            
            var names = ""
            var totalTypingUser = 0
            
            for (typingUser, _) in typingUserDictionary {
                
                if typingUser != self.nickname {
                    
                    names = (names == "") ? typingUser : "\(names), \(typingUser)"
                    totalTypingUser += 1
                    
                }
                
            }
            
            if totalTypingUser > 0 {
                
                let verb = (totalTypingUser > 1) ? "are" : "is"
                
                otherUserStatusLabel.text = "\(names) \(verb) now typing a message..."
                otherUserStatusLabel.isHidden = false
                
            }
            else {
                
                otherUserStatusLabel.isHidden = true
                
            }
            
            print(names)
            
        }
        
    }
    
    /*
    func scrollToBottom() {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
            if self.chatMessages.count > 0 {
                let lastRowIndexPath = NSIndexPath(forRow: self.chatMessages.count - 1, inSection: 0)
                self.tblChat.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
        
    }*/
    
    
    func showBannerLabelAnimated() {
        
        UIView.animate(withDuration: 0.75) {
            self.lblNewsBanner.alpha = 1.0
        } completion: { [unowned self] _ in
            
            self.bannerLabelTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(hideBannerLabel), userInfo: nil, repeats: false)
            
        }
        
    }
    
    
    @objc func hideBannerLabel() {
        
        if bannerLabelTimer != nil {
            
            bannerLabelTimer.invalidate()
            bannerLabelTimer = nil
            
        }
        
        UIView.animate(withDuration: 0.75) { [unowned self] in
            
            self.lblNewsBanner.alpha = 0.0
            
        }
    }

    
    
    @objc func dismissKeyboard() {
        
        if tvMessageEditor.isFirstResponder {
            
            tvMessageEditor.resignFirstResponder()
            
            SocketIOManager.shared.sendStopTypingMessage(nickname: self.nickname)
            
        }
        
    }
    
    
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        let senderNickname = currentChatMessage["nickname"] as! String
        let message = currentChatMessage["message"] as! String
        let date = currentChatMessage["date"] as! String
        
        if senderNickname == self.nickname {
            
            cell.lblChatMessage.textAlignment = .right
            cell.lblMessageDetails.textAlignment = .right
//            cell.lblChatMessage.textColor = lblNewsBanner.backgroundColor
            
            
        }
        
        cell.lblChatMessage.text = message
        cell.lblMessageDetails.text = "by \(senderNickname) @ \(date)"
        
        cell.lblChatMessage.textColor = .darkGray
        
        
        return cell
        
    }
    
    // MARK: UITextViewDelegate Methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        SocketIOManager.shared.sendStartTypingMessage(nickname: self.nickname)
        
        return true
    }

    
    // MARK: UIGestureRecognizerDelegate Methods
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    
    
    
}



