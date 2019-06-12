//
//  AVPlayer.swift
//  CelerNetworkProject
//
//  Created by Maksym Voskresenskyy on 6/12/19.
//  Copyright © 2019 Maksym Voskresenskyy. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
