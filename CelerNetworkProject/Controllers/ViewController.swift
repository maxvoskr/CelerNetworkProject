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
    
    var graphics = [Graphic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self
        
        APINetwork.shared.pullGraphicsData() { (graphics, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            self.graphics = graphics
            
            DispatchQueue.main.async {
                self.videoCollectionView.reloadData()
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
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.width
        let itemHeight = collectionView.bounds.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    }
}

