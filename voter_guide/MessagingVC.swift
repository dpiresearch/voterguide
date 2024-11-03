//
//  ViewController.swift
//  voter_guide
//
//  Created by Ash Bhat on 11/2/24.
//

import UIKit

enum AIState: String {
    case None
    case UploadingId = "Scanning Id"
    case SearchingRecord = "Searching Voter Record"
    case Thinking = "Thinking..."
}

class MessagingVC: UIViewController {
    
    var ai_state: AIState = .None
    let tableView = UITableView()
    let messageBox = MessageBox()
    
    var bottomConstraint: NSLayoutConstraint?
    
    var messageIdToAnimate: String?
    
    var base_system_prompt =  CoreDataSingleton.shared.driverIdInfo != nil ? "You are an AI designed to help you find information about your local elections. You **do** have the ability to get real time information by using the function call get_realtime_election_information. You must use this function whenever you can as opposed to ever telling the user that you don't have access to realtime information." : "You are an AI designed to help you find information about your local elections. You **do** have the ability to get real time information by using the function call get_realtime_election_information. You must use this function whenever you can as opposed to ever telling the user that you don't have access to realtime information."
    
    var default_message: String = CoreDataSingleton.shared.driverIdInfo != nil ? "Hello! I'm voter guide. I'm here to help you figure out how to vote.\n\nWhat would you like to do?" : "Hello! I'm voter guide. Please upload your driver's ID to get started."
    
    var actions: [MesssageActions] {
        if CoreDataSingleton.shared.driverIdInfo != nil {
            return []
        }
        else {
            return [.upload_driver_id]
        }
    }
    
    lazy var messages: [MessageStruct] = [
        MessageStruct(role: "system", content: base_system_prompt),
        MessageStruct(role: "assistant", content: default_message, actions: self.actions)
    ]
    
    
    
    var visible_messages: [MessageStruct] {
        return self.messages.filter({
            $0.role != "system" && $0.function == nil
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium

        let formattedDate = dateFormatter.string(from: currentDate)
        
        self.messages[0].content = self.base_system_prompt + " The current date and time is \(formattedDate). Please take this into account when answering questions about whether a place is closed or not."
        
        self.setupNav()
        self.setupUI()
        
        self.messageIdToAnimate = self.visible_messages.last(where: {$0.role == "assistant"})?.id
        
        messageBox.delegate = self
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

}

extension MessagingVC: MessageBoxDelegate {
    
    func didSendMessageStruct(_ message: MessageStruct) {
        self.messages.append(message)
        Cloud.connection.chat(messages: self.messages) { message, error in
            if let message = message {
                self.processMessage(message: message)
            }
            else {
                let message = MessageStruct(role: "assistant", content: "Sorry – I'm having trouble connecting to Gemini. Please try again.")
                self.messages.append(message)
                self.messageIdToAnimate = message.id
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToLastMessage()
                }
            }
        }
    }
    
    func didSendMessageText(_ message: String) {
        let message = MessageStruct(role: "user", content: message)
        self.messages.append(message)
        self.tableView.reloadData()
        self.scrollToLastMessage()

        
        Cloud.connection.chat(messages: self.messages) { message, error in
            if let message = message {
                self.processMessage(message: message)
            }
            else {
                let message = MessageStruct(role: "assistant", content: "Sorry – I'm having trouble connecting to Gemini. Please try again.")
                self.messages.append(message)
                self.messageIdToAnimate = message.id
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToLastMessage()
                }
            }
        }
        
//      make api request to get response
    }
    
    func processMessage(message: MessageStruct) {
        
        if message.function != nil {
            if message.function?.name == "get_voting_places" {
                let address = message.function?.arguments["registered_address"] as? String
                if let address = address {
                    self.get_voting_places(address: address)
                }
                else {
                    let message = MessageStruct(role: "assistant", content: "Sorry – I'm having trouble connecting to Gemini. Please try again.")
                    self.messages.append(message)
                    self.messageIdToAnimate = message.id
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToLastMessage()
                    }
                }
                
            }
            if message.function?.name == "query_internet_for_realtime_results" {
                let query = message.function?.arguments["query"] as? String
                if let query = query {
                    self.make_online_query(query: query)
                }
                else {
                    let message = MessageStruct(role: "assistant", content: "Sorry – I'm having trouble connecting to Gemini. Please try again.")
                    self.messages.append(message)
                    self.messageIdToAnimate = message.id
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToLastMessage()
                    }
                }
            }
            if message.function?.name == "get_realtime_election_information" {
                let query = message.function?.arguments["query"] as? String
                if let query = query {
                    self.make_online_query(query: query)
                }
                else {
                    let message = MessageStruct(role: "assistant", content: "Sorry – I'm having trouble connecting to Gemini. Please try again.")
                    self.messages.append(message)
                    self.messageIdToAnimate = message.id
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToLastMessage()
                    }
                }
            }
        }
        else if message.content.count > 0 {
            self.messages.append(message)
            self.messageIdToAnimate = message.id
            DispatchQueue.main.async {
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.scrollToLastMessage()
                })
            }
        }
        
        

    }
    
    private func scrollToLastMessage() {
        let lastIndex = IndexPath(row: self.visible_messages.count - 1, section: 0)
        self.tableView.scrollToRow(at: lastIndex, at: .top, animated: false)
    }
    
    private func scrollToBottom() {
        let lastIndex = IndexPath(row: self.visible_messages.count - 1, section: 0)
        self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
    }
}


// UI Setup
extension MessagingVC {
    func setupNav() {
        self.title = "VoterGuide"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .done, target: self, action: #selector(leftBarButtonTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(rightBarButtonTapped))
        
        self.navigationItem.rightBarButtonItem?.tintColor = .label
        self.navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    func setupUI() {
        let views = [tableView, messageBox]
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        bottomConstraint = messageBox.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageBox.topAnchor),
            
            messageBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomConstraint!,
            messageBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessagingCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // Adjust bottom constraint when the keyboard shows
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        bottomConstraint?.constant = -keyboardHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { completed in
            self.scrollToBottom()
        })
    }

    // Reset bottom constraint when the keyboard hides
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc func leftBarButtonTapped() {
        
    }
    
    @objc func rightBarButtonTapped() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium

        let formattedDate = dateFormatter.string(from: currentDate)
        
        self.messages = [
            MessageStruct(role: "system", content: self.base_system_prompt + " The current date and time is \(formattedDate). Please take this into account when answering questions about whether a place is closed or not."),
            MessageStruct(role: "assistant", content: default_message, actions: self.actions)
        ]
        
        self.messageIdToAnimate = self.messages.last?.id
        self.tableView.reloadData()
        
    }
}

extension MessagingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let addional_cell_count = self.ai_state != .None ? 1 : 0
        return self.visible_messages.count + addional_cell_count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.visible_messages.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessagingCell
            cell.setAnimationState(state: self.ai_state)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessagingCell
        let message = self.visible_messages[indexPath.row]
        cell.setData(data: message, shouldAnimate: message.id == self.messageIdToAnimate)
        cell.delegate = self
        if message.id == self.messageIdToAnimate {
            self.messageIdToAnimate = nil
        }
        return cell
    }
}

extension MessagingVC: MessagingCellDelegate {
    func didGetImage(image: UIImage) {
        self.removeActions()
        self.ai_state = .UploadingId
        self.scanId(image: image)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func scanId(image: UIImage) {
        Cloud.connection.processDriversLicense(image: image) { info, error in
            print("info: ", info ?? "no info")
            
            DispatchQueue.main.async {
                self.ai_state = .None
                self.tableView.reloadData()
            }
        }
    }
    
    func removeActions() {
        var messages = self.messages
        for (index, message) in messages.enumerated() {
            var message = message
            message.actions = []
            messages[index] = message
        }
        
        self.messages = messages
    }
}
