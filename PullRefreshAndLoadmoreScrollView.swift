//
//  PullRefreshAndLoadmoreScrollView.swift
//  PullRefreshAndLoadmoreScroll
//
//  Created by Oni on 21/2/2567 BE.
//

import UIKit

class PullRefreshAndLoadmoreScrollView: NSObject {
    
    var onRefresh: (() -> Void)?
    var onLoadMore: (() -> Void)?
    
    private let refreshControl = UIRefreshControl()
    private var loadMoreView: UIView?
    private var isLoadingMore = false
    private var scrollView : UIScrollView?
    private var contentInset:UIScrollView.ContentInsetAdjustmentBehavior!
    private var edgeInsets:UIEdgeInsets!
    private var observation: NSKeyValueObservation?

    init(scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
        self.contentInset = scrollView.contentInsetAdjustmentBehavior
        self.edgeInsets = scrollView.contentInset
        self.scrollView = scrollView
        setupRefreshControl(for: scrollView)
        setupLoadMoreControl(for: scrollView)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        observeScrollView()
    }
    
    deinit {
        observation?.invalidate()
    }
    
    private func observeScrollView() {
        observation = scrollView?.observe(\.contentOffset, options: [.new]) { [weak self] scrollView, _ in
            self?.scrollViewDidScroll(scrollView)
        }
    }
    
    private func setupRefreshControl(for scrollView: UIScrollView){
        if scrollView is UITableView {
            (scrollView as! UITableView).refreshControl = refreshControl
        } else if scrollView is UICollectionView {
            (scrollView as! UICollectionView).refreshControl = refreshControl
        } else {
            scrollView.addSubview(refreshControl)
        }
    }
    
    

    private func setupLoadMoreControl(for scrollView: UIScrollView) {
        let loadMoreView = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.bounds.size.width, height: 50))
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: loadMoreView.frame.size.height / 2)
        loadMoreView.addSubview(activityIndicator)
        activityIndicator.tintColor = .blue
        activityIndicator.backgroundColor = .green
        activityIndicator.startAnimating()
        self.loadMoreView = loadMoreView
        self.loadMoreView?.backgroundColor = .yellow
        updateLoadMoreControl(for: scrollView)
    }
    

    private func updateLoadMoreControl(for scrollView: UIScrollView) {
        guard let loadMoreView = loadMoreView else { return }

        if scrollView is UITableView {
            (scrollView as! UITableView).addSubview(loadMoreView)
        } else if scrollView is UICollectionView {
            (scrollView as! UICollectionView).addSubview(loadMoreView)
        } else {
            scrollView.addSubview(loadMoreView)
        }

        loadMoreView.isHidden = true // Initially hidden
    }

    @objc private func refresh() {
        scrollView?.contentInsetAdjustmentBehavior = .automatic
        onRefresh?()
    }

    public func endRefreshing() {
        scrollView?.contentInsetAdjustmentBehavior = contentInset
        refreshControl.endRefreshing()
    }

    public func beginLoadMore() {
        guard let loadMoreView = loadMoreView, !isLoadingMore else { return }
        scrollView?.contentInsetAdjustmentBehavior = .automatic
        isLoadingMore = true
        loadMoreView.isHidden = false
    }

    public func endLoadMore() {
        scrollView?.contentInsetAdjustmentBehavior = contentInset
        scrollView?.contentInset = edgeInsets
        isLoadingMore = false
        loadMoreView?.isHidden = true
    }
    
    private func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isLoadingMore else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height - 100, contentHeight > height {
            if scrollView is UITableView {
                
            }else{
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            }
            updateLoadMoreViewPosition()
            beginLoadMore()
            onLoadMore?()
        }
    }
    
    private func updateLoadMoreViewPosition() {
        guard let scrollView = scrollView, let loadMoreView = loadMoreView else { return }
        let loadMoreViewHeight = loadMoreView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        loadMoreView.frame.origin.y = contentHeight
        scrollView.contentInset.bottom = loadMoreViewHeight
    }
}


