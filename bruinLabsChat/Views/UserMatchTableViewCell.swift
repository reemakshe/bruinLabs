//
//  UserMatchTableViewCell.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 8/7/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit

class UserMatchTableViewCell: UITableViewCell {
    
    static let identifier = "UserMatchTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userGoalsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userImageView)
        contentView.addSubview(userGoalsLabel)
        contentView.backgroundColor = UIColor(displayP3Red: 0.717, green: 0.863, blue: 0.949, alpha: 0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height-20)/2)
        userGoalsLabel.frame = CGRect(x: userImageView.right + 10, y: userNameLabel.bottom + 5, width: contentView.width - 20 - userImageView.width, height: (contentView.height-20)/2)
        
    }
    
    public func configure(user : ChatAppUser) {
        let goalsString = (user.goals).joined(separator: ", ")
        self.userGoalsLabel.text = "goals: \(goalsString)"
        self.userNameLabel.text = user.username
        
        let path = "images/\(user.safeEmail)_profile_picture.png"
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
