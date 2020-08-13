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
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(tipLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        contentView.frame = contentView.frame.inset(by: margins)
        contentView.layer.borderColor =  CGColor(srgbRed: 0.15686, green: 0.262745, blue: 0.3058823, alpha: 1)
        contentView.layer.borderWidth = 2.5
        contentView.layer.cornerRadius = 10.0
        tipLabel.frame = CGRect(x: 20, y: 5, width: contentView.width - 15, height: (contentView.height))
//        contentView.backgroundColor = UIColor(displayP3Red: 0.6196078, green: 0.84313725, blue: 0.8980392, alpha: 1)
        
    }
    
    public func configure(text : String, r : CGFloat, g : CGFloat, b : CGFloat) {
        self.tipLabel.text = text
        contentView.backgroundColor = UIColor(displayP3Red: r, green: g, blue: b, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

