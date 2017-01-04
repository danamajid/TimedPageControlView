//
//  Cell.swift
//  TimedPageControlView
//
//  Created by Dana Majid on 1/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

@objc class Cell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 100, width: frame.width, height: 40)
        titleLabel.text = "Swipe left/right!"

        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

