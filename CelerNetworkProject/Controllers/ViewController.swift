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
    @IBOutlet weak var icarousel: iCarousel!
    
    var graphics = [Graphic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScaling)
        let cellHeight = floor(screenSize.height * cellScaling)
        
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let insetY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = self.photosCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        self.photosCollectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)*/
        
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self
        
        self.icarousel.delegate = self
        self.icarousel.dataSource = self
        
        self.icarousel.type = .custom
        
        APINetwork.shared.pullGraphicsData() { (graphics, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            self.graphics = graphics
            
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
                self.icarousel.reloadData()
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
    
    /*func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let indexPathRight = NSIndexPath(row: indexPath.row, section: indexPath.section)
        let rightCell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPathRight as IndexPath) as! ImageCollectionViewCell
        
        rightCell.pictureImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 75)
    }*/
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if collectionView == self.photosCollectionView {
            let totalCellWidth = 80 * collectionView.numberOfItems(inSection: 0)
            let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)
            
            let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }*/
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //if collectionView == self.videoCollectionView {
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
       /* } else {
            let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ImageCollectionViewCell
            
            cell.pictureImageView.loadImageUsingCacheWithUrlString(urlString: self.graphics[indexPath.row].imageUrl)
            
            return cell
        }*/
    }
}

extension ViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        print("carousel - \(self.graphics.count)")
        return self.graphics.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        /*if let view = view as? UIImageView {
            itemView = view
        } else {*/
            itemView = UIImageView()
            
            itemView.frame = CGRect(x: 0, y: 600, width: 100, height: 150)
            /*if (UIScreen.main.bounds.height > 850) {
                itemView.frame = CGRect(x: 0, y: 700, width: 370, height: 220)
                //postTimeLabel.frame = CGRect(x: 15, y: 577.5, width: 250, height: 30)
                //infoImageView.frame = CGRect(x: itemView.bounds.width - 40, y: 580.5, width: 23, height: 23)
            } else if (UIScreen.main.bounds.height < 700 && UIScreen.main.bounds.width < 400) {
                itemView.frame = CGRect(x: 0, y: 700, width: 340, height: 260)
                //postTimeLabel.frame = CGRect(x: 15, y: 420, width: 250, height: 30)
                //infoImageView.frame = CGRect(x: itemView.bounds.width - 40, y: 423, width: 23, height: 23)
            } else if (UIScreen.main.bounds.width == 414 && UIScreen.main.bounds.height == 736) {
                itemView.frame = CGRect(x: 0, y: 700, width: 370, height: 240)
                //postTimeLabel.frame = CGRect(x: 15, y: 497.5, width: 250, height: 30)
                //infoImageView.frame = CGRect(x: itemView.bounds.width - 40, y: 500.5, width: 23, height: 23)
            } else {
                itemView.frame = CGRect(x: 0, y: 700, width: 340, height: 270) // 540
                //postTimeLabel.frame = CGRect(x: 15, y: 497.5, width: 250, height: 30)
                //infoImageView.frame = CGRect(x: itemView.bounds.width - 40, y: 500.5, width: 23, height: 23)
            }*/
            
        //}
        
        DispatchQueue.main.async {
            itemView.loadImageUsingCacheWithUrlString(urlString: self.graphics[index].imageUrl)
        }
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        var result : CGFloat
        switch option {
        case .spacing:
            result = 2.0
        default:
            result = value
        }
        return result
    }
    
    //    https://github.com/nicklockwood/iCarousel/issues/404 for the code
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        
        //  Change these two to modify the look of the carousel
        let centerItemZoom: CGFloat = 1.3//1.1
        let centerItemSpacing: CGFloat = 0.9 //0.9
        
        let spacing: CGFloat = self.carousel(carousel, valueFor: .spacing, withDefault: 1.0)
        let absClampedOffset = min(1.0, fabs(offset))
        let clampedOffset = min(1.0, max(-1.0, offset))
        let scaleFactor = 1.0 + absClampedOffset * (1.0/centerItemZoom - 1.0)
        let offset = (scaleFactor * offset + scaleFactor * (centerItemSpacing - 1.0) * clampedOffset) * carousel.itemWidth * spacing
        
        var transform = CATransform3DTranslate(transform, offset, 0.0, -absClampedOffset)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        transform = CATransform3DRotate(transform, .pi / 30 * absClampedOffset, 0, offset, 0)
        return transform
    }
    
   /* func carouselWillBeginDragging(_ carousel: iCarousel) {
        print("will begin dragging")
         let indexPath = IndexPath(row: carousel.currentItemIndex , section: 0)
        videoCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
    }*/
    
    func carouselDidEndDragging(_ carousel: iCarousel, willDecelerate decelerate: Bool) {
        let indexPath = IndexPath(row: carousel.currentItemIndex , section: 0)
        videoCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let center = self.view.convert(self.videoCollectionView.center, to: self.videoCollectionView)
        let index = videoCollectionView!.indexPathForItem(at: center)
        
        icarousel.scrollToItem(at: index!.row, animated: true)
        
        /*let centerOffsetX = (self.photosCollectionView.contentSize.width - self.photosCollectionView.frame.size.width) / 2
        let centerOffsetY = self.photosCollectionView.frame.size.height / 2
        let centerPoint = CGPoint(x: centerOffsetX, y: centerOffsetY)
        
       // let center = self.view.convert(view.center, to: self.photosCollectionView)
        let index = photosCollectionView!.indexPathForItem(at: centerPoint)
        
        
        collectionView(self.photosCollectionView, didSelectItemAt: index!)*/
    }
    
   /* func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.photosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }*/
}


