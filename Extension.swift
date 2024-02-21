//
//  a.swift
//  TestView
//
//  Created by Dev on 21/2/2567 BE.
//

//import Foundation
//import UIKit
//
import UIKit

private var kIsLoadingMoreKey: UInt8 = 0
private var kOnRefreshKey: UInt8 = 0
private var kOnLoadMoreKey: UInt8 = 0
private var kOriginalContentInsetAdjustmentBehaviorKey: UInt8 = 0

extension UIScrollView {
    private var isLoadingMore: Bool {
        get { objc_getAssociatedObject(self, &kIsLoadingMoreKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &kIsLoadingMoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var refreshAction: (() -> Void)? {
        get { objc_getAssociatedObject(self, &kOnRefreshKey) as? (() -> Void) }
        set { objc_setAssociatedObject(self, &kOnRefreshKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    private var loadMoreAction: (() -> Void)? {
        get { objc_getAssociatedObject(self, &kOnLoadMoreKey) as? (() -> Void) }
        set { objc_setAssociatedObject(self, &kOnLoadMoreKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    private var originalContentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        get { objc_getAssociatedObject(self, &kOriginalContentInsetAdjustmentBehaviorKey) as? UIScrollView.ContentInsetAdjustmentBehavior ?? .never }
        set { objc_setAssociatedObject(self, &kOriginalContentInsetAdjustmentBehaviorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var loadMoreIndicator: UIActivityIndicatorView? {
        return self.viewWithTag(999) as? UIActivityIndicatorView
    }
    
    func configureRefreshControl(tintColor: UIColor = .gray, onRefresh: @escaping () -> Void) {
        self.originalContentInsetAdjustmentBehavior = self.contentInsetAdjustmentBehavior
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = tintColor
        refreshControl.addTarget(self, action: #selector(executeRefresh(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        self.refreshAction = {
            onRefresh()
        }
    }
    
    @objc private func executeRefresh(_ sender: UIRefreshControl) {
        self.refreshAction?()
        self.contentInsetAdjustmentBehavior = .automatic
    }
    
    func configureLoadMoreControl(tintColor: UIColor = .gray, onLoadMore: @escaping () -> Void) {
        guard loadMoreIndicator == nil else { return }
        
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.tag = 999 // Unique tag to identify
        indicator.color = tintColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isHidden = true
        self.addSubview(indicator)
        
        // ปรับปรุง Constraint ใหม่: ตั้งค่าตำแหน่งของ indicator ให้อยู่ด้านล่างสุดของ content
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        self.loadMoreAction = onLoadMore
    }
    
    func stopPullRefresh(){
        if let isRefreshing = self.refreshControl?.isRefreshing, isRefreshing && self.originalContentInsetAdjustmentBehavior == .never{
            self.contentInsetAdjustmentBehavior = self.originalContentInsetAdjustmentBehavior
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    func startLoadingMore() {
        guard !isLoadingMore, let indicator = self.loadMoreIndicator else { return }
        isLoadingMore = true
        indicator.isHidden = false
        indicator.startAnimating()
        self.loadMoreAction?()
    }
    
    func stopLoadingMore() {
        isLoadingMore = false
        self.loadMoreIndicator?.isHidden = true
        self.loadMoreIndicator?.stopAnimating()
    }
    
    func scrollViewDidEndDragging(willDecelerate decelerate: Bool) {
        let offsetY = self.contentOffset.y
        let contentHeight = self.contentSize.height
        let height = self.frame.size.height
        
        if offsetY > contentHeight - height {
            startLoadingMore()
        }
    }
}
