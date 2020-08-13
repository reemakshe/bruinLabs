//
//  UserMatchTableViewCell.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 8/7/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit

class TipsTableViewCell: UITableViewCell {
    
    static let identifier = "TipsTableViewCell"

    private let tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 24)
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(tipLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tipLabel.frame = CGRect(x: 20, y: 5, width: contentView.width - 5, height: (contentView.height))
        
    }
    
    public func configure(text : String) {
        self.tipLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

