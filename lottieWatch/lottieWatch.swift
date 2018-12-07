//
//  lottieWatch.swift
//  lottieConvert
//
//  Created by Andrew Simpson on 12/2/18.
//  Copyright © 2018 Andrew Simpson. All rights reserved.
//

import Foundation
import UIKit
import Lottie
import WatchConnectivity

public class LWatch: NSObject, WCSessionDelegate {
    
    
    private var VC: UIViewController!
    private var speed: Double!
    private var lotView: LOTAnimationView!
    private var fileName: String!
    private var timer : Timer?
    private var c = 0.0
    private var frames = 20.0
    private var size: CGSize!
    private var lotCollection: [UIImage] = []
    private var session : WCSession!
    private var done: (() -> Void)!
    
    public init(VC: UIViewController, fileName: String, loadSpeed: Double = 0.1, size: CGSize, frames: Int) {
        super.init()
        self.VC = VC
        self.speed = loadSpeed
        self.frames = Double(frames)
        self.size = size
        self.fileName = fileName
        if WCSession.isSupported() {
            print("DELAGATE!!!")
            session = WCSession.default
            session.delegate = self
            session.activate()
            
            watchConnectionStatus()
            
        }
        
       self.lotView = LOTAnimationView(name: self.fileName)
    
    }
    

    
    private func watchConnectionStatus(){
        
        print("isPaired",session.isPaired)
        print("session.isWatchAppInstalled",session.isWatchAppInstalled)
        print(session.watchDirectoryURL)
        
    }
    
    public func load(finished: @escaping (() -> Void)) {
        self.done = finished
        self.lotView.frame = CGRect(x: -self.size.width, y: -self.size.height, width: self.size.width, height: self.size.height)
        self.VC.view.addSubview(self.lotView)

        
        self.timer =  Timer.scheduledTimer(timeInterval: self.speed, target: self, selector:#selector(self.watchLot), userInfo: nil, repeats: true)

    }
    
    
   @objc private func watchLot() {

        if (self.c > 1) {
            self.timer?.invalidate()
            self.sendToWatch()
            self.done()
        }
        self.lotCollection.append(self.shootView(vi: lotView))
        lotView.play(fromProgress: CGFloat(self.c), toProgress: CGFloat(self.c), withCompletion: nil)
        self.c = self.c + (1.0 / self.frames)
    }
    
    private func sendToWatch() {
        for image in self.lotCollection {
            self.session.sendMessageData(image.pngData() ?? Data(), replyHandler: {(data) in
                
            }, errorHandler: nil)
        }
    }
    
    private func shootView(vi:UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: vi.bounds)
        return renderer.image { rendererContext in
            vi.layer.render(in: rendererContext.cgContext)
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { print( "PHONE ACTIVE!")}
    public func sessionDidBecomeInactive(_ session: WCSession) { }
    public func sessionDidDeactivate(_ session: WCSession) { }
    
    
    
}
