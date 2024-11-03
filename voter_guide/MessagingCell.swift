//
//  MessagingCell.swift
//  voter_guide
//
//  Created by Ash Bhat on 11/3/24.
//

import UIKit
import PhotosUI

protocol MessagingCellDelegate: AnyObject {
    func didGetImage(image: UIImage)
}

class MessagingCell: UITableViewCell {
    
    weak var delegate: MessagingCellDelegate?
    let profileImageView = UIImageView()
    let textView = UITextView()
    let animatingtextView = UITextView()
    var timer: Timer?
    
    let actionButton = UIButton()
    
    let shimmerLabel = ShimmerLabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    func setup() {
        self.selectionStyle = .none
    }
    
    func setAnimationState(state: AIState) {
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        self.addViews(views: [shimmerLabel, profileImageView])
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            profileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20),
            
            shimmerLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            shimmerLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15)
        ])
        
        profileImageView.image = UIImage(systemName: "archivebox", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 24)))
        profileImageView.contentMode = .center
        profileImageView.largeContentImageInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        profileImageView.tintColor = .label

        shimmerLabel.font = UIFont.preferredFont(forTextStyle: .body)
        shimmerLabel.text = state.rawValue
        shimmerLabel.shimmerColor = .tertiarySystemBackground
        shimmerLabel.textColor = .label
        
        profileImageView.layer.cornerRadius = 25
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.systemFill.cgColor

        
    }
    
    func setData(data: MessageStruct, shouldAnimate: Bool) {
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        if data.role == "assistant" {
            self.addViews(views: [profileImageView, textView, animatingtextView])
            
            NSLayoutConstraint.activate([
                profileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
                profileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
                profileImageView.widthAnchor.constraint(equalToConstant: 50),
                profileImageView.heightAnchor.constraint(equalToConstant: 50),
                
                textView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
                textView.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0),
                textView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.8, constant: -40),
                animatingtextView.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 0),
                animatingtextView.topAnchor.constraint(equalTo: textView.topAnchor, constant: 0),
                animatingtextView.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0),
                animatingtextView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0)
            ])
            
            if data.actions.isEmpty {
                NSLayoutConstraint.activate([
                    textView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
                ])
            }
            else {
                self.addViews(views: [actionButton])
                NSLayoutConstraint.activate([
                    textView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -10),
                    actionButton.leadingAnchor.constraint(equalTo: self.textView.leadingAnchor, constant: 0),
                    actionButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
                ])
                
                actionButton.setTitle("Upload ID", for: .normal)
                actionButton.setTitleColor(.label, for: .normal)
                actionButton.backgroundColor = .systemFill
                actionButton.layer.cornerRadius = 10
                actionButton.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
                
                // Create a menu with actions
                let uploadAction = UIAction(title: "Upload from Photos", image: UIImage(systemName: "photo")) { _ in
                    self.presentPhotoPicker()
                }
                let takePhotoAction = UIAction(title: "Take Photo", image: UIImage(systemName: "camera")) { _ in
                    // Handle taking a photo
                    print("Take Photo selected")
                }
                
                let menu = UIMenu(title: "", children: [uploadAction, takePhotoAction])

                // Set the menu for the button
                actionButton.menu = menu
                actionButton.showsMenuAsPrimaryAction = true
            }
            
            profileImageView.image = UIImage(systemName: "archivebox", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 24)))
            profileImageView.contentMode = .center
            profileImageView.largeContentImageInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
            profileImageView.tintColor = .label
            
            textView.textContainerInset = .zero

            textView.isScrollEnabled = false
            textView.isEditable = false
            animatingtextView.isEditable = false
        
            animatingtextView.textContainerInset = .zero
            
            
            textView.attributedText = self.attributedString(from: data.content)
            textView.textColor = .label
            textView.font = UIFont.preferredFont(forTextStyle: .body)
            textView.alpha = 0.1
            textView.layer.borderWidth = 0
            textView.layer.borderColor = UIColor.clear.cgColor
            
            animatingtextView.alpha = 1
            animatingtextView.textColor = .label
//            animatingtextView.text = data.content
            animatingtextView.font = UIFont.preferredFont(forTextStyle: .body)
            
            profileImageView.layer.cornerRadius = 25
            profileImageView.layer.borderWidth = 2
            profileImageView.layer.borderColor = UIColor.systemFill.cgColor
            
            if shouldAnimate {
                animateText(content: data.content)
            } else {
                textView.alpha = 1.0
                animatingtextView.attributedText = self.attributedString(from: data.content)
            }
        }
        else {
            self.addViews(views: [textView])
            
            NSLayoutConstraint.activate([
                textView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
                textView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
                textView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.8, constant: -40),
                textView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            ])
            animatingtextView.alpha = 0
            textView.alpha = 1
            textView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
            textView.layer.cornerRadius = 10
            textView.layer.borderWidth = 2
            textView.layer.borderColor = UIColor.systemFill.cgColor
            textView.font = UIFont.preferredFont(forTextStyle: .body)
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.attributedText = self.attributedString(from: data.content)
            animatingtextView.isEditable = false
            
        }
    }
    
    private func animateText(content: String) {
        animatingtextView.text = "" // Start with an empty string
        let words = content.split(separator: " ") // Split content into words
        var currentIndex = 0
        
        // Invalidate any previous timer before starting a new one
        timer?.invalidate()
        
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .light, view: self.textView)
        impactGenerator.prepare()
        // Run a timer on a background queue to minimize UI thread congestion
        
        var textCache: String = ""
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if currentIndex < words.count {
                let word = words[currentIndex]
                
                let newText = (textCache) + (self.animatingtextView.text?.isEmpty ?? true ? "" : " ") + word
                textCache = newText
                currentIndex += 1
                
                // Batch UI updates to main thread for smoother rendering
                DispatchQueue.main.async {
                    self.animatingtextView.attributedText = self.attributedString(from: newText)
                    impactGenerator.impactOccurred()
                }
            } else {
                timer.invalidate()
            }
        }
        
        // Ensure the timer runs in the common run loop mode to prevent interruptions
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func addViews(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(view)
        }
    }
    
    func attributedString(from text: String) -> NSAttributedString {
        let fullRange = NSRange(location: 0, length: text.count)
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]
        )
        
        // Regular expression to find headers that start with '#'
        let headerRegexPattern = "^(#{1,6})\\s*(.*?)$"
        
        do {
            let headerRegex = try NSRegularExpression(pattern: headerRegexPattern, options: [.anchorsMatchLines])
            let headerMatches = headerRegex.matches(in: text, options: [], range: fullRange)
            
            // Iterate over each match and apply header style
            for match in headerMatches.reversed() {
                let headerLevel = match.range(at: 1).length // Number of '#' indicates the header level
                if let headerContentRange = Range(match.range(at: 2), in: text) {
                    let headerText = String(text[headerContentRange])
                    let headerFont = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize - CGFloat(headerLevel - 1) * 2)
                    let headerAttributedString = NSAttributedString(
                        string: headerText,
                        attributes: [
                            NSAttributedString.Key.font: headerFont,
                            NSAttributedString.Key.foregroundColor: UIColor.label
                        ]
                    )
                    
                    // Replace the range in the mutable attributed string
                    attributedString.replaceCharacters(in: match.range, with: headerAttributedString)
                }
            }
            
            // Regular expression to find text within "**" for bold styling
            let boldRegexPattern = "\\*\\*(.*?)\\*\\*"
            let boldRegex = try NSRegularExpression(pattern: boldRegexPattern, options: [])
            let boldMatches = boldRegex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))
            
            // Iterate over each match and apply bold style
            for match in boldMatches.reversed() {
                if let boldRange = Range(match.range(at: 1), in: attributedString.string) {
                    let boldText = String(attributedString.string[boldRange])
                    let boldAttributedString = NSAttributedString(
                        string: boldText,
                        attributes: [
                            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
                            NSAttributedString.Key.foregroundColor: UIColor.label
                        ]
                    )
                    
                    // Replace the range in the mutable attributed string
                    attributedString.replaceCharacters(in: match.range, with: boldAttributedString)
                }
            }
        } catch {
            print("Error creating regex: \(error)")
        }
        
        return attributedString
    }

    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}


extension MessagingCell: PHPickerViewControllerDelegate {
    // Inside your view controller
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // Only show images
        configuration.selectionLimit = 1 // Allow only one selection

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.parentViewController?.present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard let result = results.first else { return }

        // Ensure the item provider can load the image
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let error = error {
                    print("Error loading image: \(error)")
                    return
                }

                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.delegate?.didGetImage(image: image)
                    }
                }
            }
        }
    }
}



extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
