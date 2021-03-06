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

public class LWatch: NSObject {
    
    
    private var VC: UIViewController!
    private var speed: Double!
    private var lotView: LOTAnimationView!
    private var fileName: String!
    private var timer : Timer?
    private var c = 0.0
    private var frames = 20.0
    private var size: CGSize!
    private var lotCollection: [UIImage] = []
    private var done: (() -> Void)!
    
    public init(VC: UIViewController, fileName: String, loadSpeed: Double = 0.1, size: CGSize, frames: Int) {
        print("ININTI")
        super.init()
        print("ININTI2")
        self.VC = VC
        self.speed = loadSpeed
        self.frames = Double(frames)
        self.size = size
        self.fileName = fileName
        
//        print("DELAGATE!!!")
//        session.delegate = self
//        session.activate()
        

        
        self.lotView = LOTAnimationView(name: self.fileName)
        
        // UserDefaults.standard.set(false, forKey: self.fileName + "Saved")
        
    }
    
    
    
   
    
    public func load(finished: @escaping (() -> Void)) {
        self.done = finished
        if let isSaved = UserDefaults.standard.object(forKey: self.fileName + "Saved") {
            if (!(isSaved as! Bool)) {
                print("not saved")
                self.lotView.frame = CGRect(x: -self.size.width, y: -self.size.height, width: self.size.width, height: self.size.height)
                self.VC.view.addSubview(self.lotView)
                self.timer =  Timer.scheduledTimer(timeInterval: self.speed, target: self, selector:#selector(self.watchLot), userInfo: nil, repeats: true)
            }else {
                print("saved")
                //self.loadSavedImages()
                self.done()
            }
        } else {
            print("not saved")
            self.lotView.frame = CGRect(x: -self.size.width, y: -self.size.height, width: self.size.width, height: self.size.height)
            self.VC.view.addSubview(self.lotView)
            self.timer =  Timer.scheduledTimer(timeInterval: self.speed, target: self, selector:#selector(self.watchLot), userInfo: nil, repeats: true)
        }
        
    }
    
//    func loadSavedImages() {
//        let savedCount = UserDefaults.standard.object(forKey: self.fileName + "SavedCount") as! Int
//        for i in 0...(savedCount-1) {
//            self.lotCollection.append(getSavedImage(named: self.fileName + String(i) + ".png") ?? UIImage())
//        }
//    }
    
//    func getSavedImage(named: String) -> UIImage? {
//        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
//            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
//        }
//        return nil
//    }
    
    
    @objc private func watchLot() {
        
        if (self.c > 1) {
            self.timer?.invalidate()
//            self.sendToWatch()
           
            var count = 0
            for im in self.lotCollection {
                let gotIt = saveImage(image: im, i: count)
                if (gotIt == true && count == self.lotCollection.count - 1) {
                    UserDefaults.standard.set(true, forKey: (self.fileName + "Saved"))
                    UserDefaults.standard.set(self.lotCollection.count, forKey: (self.fileName + "SavedCount"))
                    print("SAVED")
                    break
                }
                count += 1
            }
            self.done()
        }
        self.lotCollection.append(self.shootView(vi: lotView))
        lotView.play(fromProgress: CGFloat(self.c), toProgress: CGFloat(self.c), withCompletion: nil)
        self.c = self.c + (1.0 / self.frames)
    }
    
//    private func sendToWatch() {
//        for image in self.lotCollection {
//            self.session.sendMessageData(image.pngData() ?? Data(), replyHandler: {(data) in
//
//            }, errorHandler: {(error) in
//                print(error.localizedDescription)
//            })
//
//        }
//    }
    
    private func shootView(vi:UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: vi.bounds)
        return renderer.image { rendererContext in
            vi.layer.render(in: rendererContext.cgContext)
        }
    }
    
    func saveImage(image: UIImage, i: Int) -> Bool {
        let data = image.pngData() // UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
        let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL
        do {
            try data?.write(to: directory?.appendingPathComponent(self.fileName + String(i) + ".png")! ?? URL(fileURLWithPath: "blank.png"))
            return true
        } catch {
            return false
        }
    
         
    }
    
    
    
    
}
