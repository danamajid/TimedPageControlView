//
//  TimedPageControlView.swift
//  Five Videos
//
//  Created by Dana Majid on 12/27/16.
//  Copyright © 2016 Dana Majid. All rights reserved.
//

import UIKit

public enum ScrollDirection {
    case none, left, right
}

@objc public class TimedPageButton: UIButton {
    var progressLayer: CALayer = CALayer()
    public var completePercentage: Float = 0 {
        didSet {
            layoutSubviews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        progressLayer.backgroundColor = UIColor.white.cgColor
        layer.masksToBounds = true
        layer.insertSublayer(progressLayer, above: layer)
    }
    
    override public func layoutSubviews() {
        progressLayer.cornerRadius = max(1, (layer.cornerRadius * min(1, CGFloat(completePercentage / 0.2))))
        progressLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * CGFloat(completePercentage), height: bounds.height)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc public class TimedPageControlView: UIView {
    var widthConstraints: [NSLayoutConstraint?] = []
    var collapsedWidth: CGFloat
    var expandedWidth: CGFloat = 0
    var totalWidth: CGFloat = 0
    var totalWidthCollapsed: CGFloat = 0
    var spacing: CGFloat = 3
    var totalPages: Int
    var _loaded = false
    public var scrollDirection: ScrollDirection?
    
    public init(collapsedWidth: CGFloat!, total: Int) {
        totalPages = total
        self.collapsedWidth = collapsedWidth
        super.init(frame: CGRect.zero)
        
        for index in 0...totalPages - 1 {
            let page: TimedPageButton = createPageAnchor(index: index)
            page.translatesAutoresizingMaskIntoConstraints = false
            
            widthConstraints.append(nil)
            addSubview(page)
            
            var prevPage: TimedPageButton?
            let timedPageButtonsubviews = subviews.filter{ $0 is TimedPageButton }
            if (index > 0 && index < timedPageButtonsubviews.count) {
                prevPage = timedPageButtonsubviews[index - 1] as? TimedPageButton
            }
            
            let top = NSLayoutConstraint(item: page, attribute: .top, relatedBy: .equal, toItem: page.superview!, attribute: .top, multiplier: 1, constant: 0)
            var left:NSLayoutConstraint
            
            let h = NSLayoutConstraint(item: page, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: collapsedWidth)
            let w = NSLayoutConstraint(item: page, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: collapsedWidth)
            widthConstraints[index] = w
            
            if (index == 0) {
                totalWidthCollapsed += collapsedWidth
                left = NSLayoutConstraint(item: page, attribute: .left, relatedBy: .equal, toItem: page.superview!, attribute: .left, multiplier: 1, constant: 0)
            } else {
                totalWidthCollapsed += collapsedWidth + spacing
                left = NSLayoutConstraint(item: page, attribute: .left, relatedBy: .equal, toItem: prevPage, attribute: .right, multiplier: 1, constant: spacing)
            }
            
            NSLayoutConstraint.activate([top, left, w, h])
        }
    }
    
    override public func layoutSubviews() {
        if (!_loaded) {
            expandedWidth = frame.size.width - totalWidthCollapsed + collapsedWidth
            updateConstraintsForPageAnchors(targetViewIndex: 0, percentComplete: 1)
            _loaded = true
        }
    }
    
    func createPageAnchor(index:Int) -> TimedPageButton {
        let button = TimedPageButton(type: .system)
        button.layer.cornerRadius = collapsedWidth / 2
        button.tag = index + 1
        button.addTarget(self, action: #selector(pageAnchorTapped), for: .touchUpInside)
        
        return button
    }
    
    func pageAnchorTapped(sender : TimedPageButton) {
        updateConstraintsForPageAnchors(targetViewIndex: (sender.tag - 1), percentComplete: 1)
    }
    
    func ensureAppropriateWidth(width: CGFloat) -> CGFloat {
        return max(collapsedWidth, min(expandedWidth, width))
    }
    
    func updateConstraintsForPageAnchors(targetViewIndex: Int, percentComplete: CGFloat) {
        let timedPageButtonSubviews = subviews.filter{ $0 is TimedPageButton } as! [TimedPageButton]
        
        for (index, item) in widthConstraints.enumerated() {
            if (index == targetViewIndex) {
                item?.constant = ensureAppropriateWidth(width: expandedWidth * percentComplete)
                timedPageButtonSubviews[index].progressLayer.opacity = Float(1) * Float(percentComplete)
            } else if (scrollDirection == .right && index == targetViewIndex + 1 || scrollDirection == .left && index == targetViewIndex + 1) {
                item?.constant = ensureAppropriateWidth(width: collapsedWidth + expandedWidth * (1 - percentComplete))
                timedPageButtonSubviews[index].progressLayer.opacity = Float(1) * Float(1 - percentComplete)
            } else {
                item?.constant = ensureAppropriateWidth(width: collapsedWidth)
                timedPageButtonSubviews[index].progressLayer.opacity = 0
            }
        }
    }
    
    public func changePage(fractionalPage: CGFloat) {
        let complete = fractionalPage.truncatingRemainder(dividingBy: 1)
        let safeComplete = max(0, min(1, complete))
        let currentPage = Int(fractionalPage)
        
        
        updateConstraintsForPageAnchors(targetViewIndex: currentPage, percentComplete: max(0, 1 - safeComplete))
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
