//
//  ViewController.swift
//  TimedPageControlView
//
//  Created by Dana Majid on 01/03/2017.
//  Copyright (c) 2017 Dana Majid. All rights reserved.
//

import UIKit
import TimedPageControlView

class ViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    var pagingView: TimedPageControlView!
    var currentPage = 0
    var currentActivePage = 0
    var currentActivePageProgress: Float = 0.0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up collection view
        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout);
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "cell");
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .gray
        collectionView.frame = view.frame
        view.addSubview(collectionView)
        
        
        // Set up paging control view
        pagingView = TimedPageControlView(collapsedWidth: 10, total: 5)
        pagingView.translatesAutoresizingMaskIntoConstraints = false
        pagingView.alpha = 0.5
        view.addSubview(pagingView!);
        
        
        // Layout our paging control view
        let top = NSLayoutConstraint(item: pagingView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -40)
        let center = NSLayoutConstraint(item: pagingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let h = NSLayoutConstraint(item: pagingView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
        let w = NSLayoutConstraint(item: pagingView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120)
        NSLayoutConstraint.activate([top, center, w, h])
        
        // Simulate timer
        startTimer()
    }
    
    func startTimer() {
        currentActivePageProgress = 0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateProgressForCurrentPage), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {

    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        pagingView.scrollDirection = .none
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetX: CGFloat = scrollView.contentOffset.x;
        let pageWidth: CGFloat = scrollView.frame.size.width;
        
        let fractionalPage: CGFloat = currentOffsetX / pageWidth
        
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0) {
            pagingView.scrollDirection = .left
        } else {
            pagingView.scrollDirection = .right
        }
        
        if(!fractionalPage.isNaN) {
            currentPage = lround(Double(fractionalPage))
            pagingView.changePage(fractionalPage: min(fractionalPage, 4))
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        currentActivePage = currentPage
        startTimer()
    }
    
    func updateProgressForCurrentPage() {
        currentActivePageProgress = Float(currentActivePageProgress) + 0.01

        setProgressOfPage(tag: currentActivePage + 1, progress: Float(currentActivePageProgress))
        if (currentActivePageProgress >= 1) {
            timer?.invalidate()
            scrollToPage(page: currentActivePage + 1, animated: true)
        }
    }
    
    func setProgressOfPage(tag: Int, progress: Float) {
        if let pageProgress = pagingView.viewWithTag(tag) as? TimedPageButton {
            pageProgress.completePercentage = progress
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height);
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func scrollToPage(page: Int, animated: Bool) {
        if (page > 5 || page < 0) {
            return;
        }
        
        var frame: CGRect = self.collectionView.frame
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        self.collectionView.scrollRectToVisible(frame, animated: animated)
    }
}

