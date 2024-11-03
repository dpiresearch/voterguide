//
//  MessageBox.swift
//  voter_guide
//
//  Created by Ash Bhat on 11/2/24.
//
import UIKit

protocol MessageBoxDelegate: AnyObject {
    func didSendMessageText(_ message: String)
}

class MessageBox: UIView {
    
    weak var delegate: MessageBoxDelegate?
    let emptyLabel = UILabel(frame: .zero)
    let containerView = UIView()
    let textView = UITextView()
    let sendButton = UIButton()
    let micButton = UIButton()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    func setup() {
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        let views = [textView, sendButton, micButton, emptyLabel]
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            textView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -5),
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            micButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            micButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            emptyLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            emptyLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10)
        ])
        
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = self
        
        containerView.layer.cornerRadius = 10
        containerView.layer.cornerCurve = .continuous
        
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.systemFill.cgColor
        
        sendButton.setImage(UIImage(systemName: "arrow.up.circle", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 25))), for: .normal)
        sendButton.tintColor = .secondaryLabel
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        micButton.setImage(UIImage(systemName: "keyboard", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 25))), for: .normal)
        micButton.tintColor = .secondaryLabel
        micButton.addTarget(self, action: #selector(micButtonTapped), for: .touchUpInside)
        
        emptyLabel.text = "Message VoterGuide"
        emptyLabel.textColor = .secondaryLabel
        
    }
    
    @objc func micButtonTapped() {
        if textView.isFirstResponder {
            self.textView.resignFirstResponder()
        }
        else {
            self.textView.becomeFirstResponder()
        }
    }
    
    @objc func sendButtonTapped() {
        self.delegate?.didSendMessageText(self.textView.text)
        self.textView.text = ""
        self.textViewDidChange(self.textView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension MessageBox: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        emptyLabel.isHidden = textView.text.count > 0
        sendButton.setImage(UIImage(systemName: textView.text.count > 0 ? "arrow.up.circle.fill" : "arrow.up.circle", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 25))), for: .normal)
        sendButton.tintColor = textView.text.count > 0 ? .label : .secondaryLabel
        sendButton.isEnabled = textView.text.count > 0
    }
}
