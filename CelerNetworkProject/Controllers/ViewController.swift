//
//  ViewController.swift
//  CelerNetworkProject
//
//  Created by Maksym Voskresenskyy on 6/10/19.
//  Copyright © 2019 Maksym Voskresenskyy. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var isfirstTimeTransform = true
    
    var graphics = [Graphic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self
        
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        
        APINetwork.shared.pullGraphicsData() { (graphics, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            self.graphics = graphics
            
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
                self.imageCollectionView.reloadData()
            }
        }
    }
    
    func adjustCellSizes(indexRow: Int) {
        var index = indexRow
        let duration = 0.2
        var cell: UICollectionViewCell = self.imageCollectionView.cellForItem(at: IndexPath(row: Int(index), section: 0))!
        
        if (index == 0) { // If first index
            UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            index += 1
            cell = self.imageCollectionView.cellForItem(at: IndexPath(row: Int(index), section: 0))!
            UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                cell.transform = CGAffineTransform.identity;
            }, completion: nil)
            
            index -= 1 // left
            if let cell = self.imageCollectionView.cellForItem(at: IndexPath(row: Int(index), section: 0)) {
                UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8);
                }, completion: nil)
            }
            
            index += 1
            index += 1 // right
            if let cell = self.imageCollectionView.cellForItem(at: IndexPath(row: Int(index), section: 0)) {
                UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8);
                }, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.graphics.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (collectionView == videoCollectionView) {
            return 0
        } else {
            return 100
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == self.videoCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            let cellWidth : CGFloat = 100.0
            let edgeInsets = (self.view.frame.size.width / 2) - 50
            return UIEdgeInsets(top: 50, left: edgeInsets, bottom: 0, right: edgeInsets)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.videoCollectionView {
            let itemWidth = collectionView.bounds.width
            let itemHeight = collectionView.bounds.height
            return CGSize(width: itemWidth, height: itemHeight)
        } else {
            switch collectionView.indexPathsForSelectedItems?.first {
            case .some(indexPath):
                return CGSize(width: 100, height: 150)
            default:
                return CGSize(width: 100, height: 150)
                //return CGSize(width: 80, height: 125)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.videoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCollectionViewCell
            
            let videoURL = URL(string: self.graphics[indexPath.row].videoUrl)
            let player = AVPlayer(url: videoURL!)
            let playerLayer = cell.avPlayerView.layer as! AVPlayerLayer
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer.frame = CGRect(x: 0, y: 50, width: cell.frame.size.width, height: cell.frame.size.width)
            playerLayer.player = player
            player.play()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
                player.seek(to: CMTime.zero)
                player.play()
            }
            return cell
        } else {
            let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            
            cell.imageView.loadImageUsingCacheWithUrlString(urlString: self.graphics[indexPath.row].imageUrl)
            
            if (indexPath.row == 0 && isfirstTimeTransform) {
                isfirstTimeTransform = false
            }else{
                cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }

            return cell
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Simulate "Page" Function
        if scrollView.isEqual(videoCollectionView) {
            let pageWidth: Float = 200
            let currentOffset: Float = Float(videoCollectionView.contentOffset.x)
            
            let targetOffset: Float = Float(targetContentOffset.pointee.x)
            var newTargetOffset: Float = 0
            
            if targetOffset > currentOffset {
                newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
            } else {
                newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
            }
            
            if newTargetOffset < 0 {
                newTargetOffset = 0
            } else if (newTargetOffset > Float(scrollView.contentSize.width)) {
                newTargetOffset = Float(Float(scrollView.contentSize.width))
            }

            if (Int(newTargetOffset) % Int((2.0 * pageWidth)) == 0) {
                imageCollectionView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset) / 2, y: scrollView.contentOffset.y), animated: true)
            } else {
                newTargetOffset = Float(Int(newTargetOffset) + Int(pageWidth))
                imageCollectionView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset) / 2, y: scrollView.contentOffset.y), animated: true)
            }
            
            let center = self.view.convert(self.videoCollectionView.center, to: self.videoCollectionView)
            let index = videoCollectionView!.indexPathForItem(at: center)!.row
            
            self.adjustCellSizes(indexRow: index)
        } else {
            let pageWidth: Float = 200
            let currentOffset: Float = Float(scrollView.contentOffset.x)
            let targetOffset: Float = Float(targetContentOffset.pointee.x)
            var newTargetOffset: Float = 0
            
            if targetOffset > currentOffset {
                newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
            } else {
                newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
            }
            
            if newTargetOffset < 0 {
                newTargetOffset = 0
            } else if (newTargetOffset > Float(scrollView.contentSize.width)) {
                newTargetOffset = Float(Float(scrollView.contentSize.width))
            }
            
            targetContentOffset.pointee.x = CGFloat(currentOffset)
            scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: true)
            
            let index = newTargetOffset / pageWidth
            videoCollectionView.scrollToItem(at: IndexPath(row: Int(index), section: 0), at: .right, animated: true)
            self.adjustCellSizes(indexRow: Int(index))
        }
    }
}
