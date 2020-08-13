//
//  ConversationTableViewCell.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 8/4/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = CGColor(srgbRed: 0.15686, green: 0.262745, blue: 0.3058823, alpha: 1)
        imageView.layer.borderWidth = 2.2
        return imageView
    }()

    private let userNameLabel: UILabel = {
       let label = UILabel()
//        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.font = UIFont(name: "Avenir-Heavy", size: 24)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
       let label = UILabel()
//        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userImageView)
        contentView.addSubview(userMessageLabel)
//        contentView.backgroundColor = UIColor(displayP3Red: 0.85882, green: 0.92941, blue: 0.964705, alpha: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height-20)/2)
        userMessageLabel.frame = CGRect(x: userImageView.right + 10, y: userNameLabel.bottom + 5, width: contentView.width - 20 - userImageView.width, height: (contentView.height-20)/2)

    }
    
    public func configure(with model : Conversation) {
        self.userMessageLabel.text = model.latest_message.text
        self.userNameLabel.text = model.name
        
        let path = "images/\(model.other_user_email)_profile_picture.png"
        print("image url path \(path)")
        StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image: \(error)")
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
