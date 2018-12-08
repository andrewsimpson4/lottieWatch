//
//  lottieWatchWait.swift
//  lottieWatch
//
//  Created by Andrew Simpson on 12/7/18.
//  Copyright © 2018 Andrew Simpson. All rights reserved.
//

import Foundation
import WatchConnectivity


public class LWatchConnection: NSObject, WCSessionDelegate {
    
    private var files: [String]!
    private var session = WCSession.default
    private var allLots: [String: [UIImage]] = [:]
    
    public init(files: [String]) {
        super.init()
        self.files = files
        session.delegate = self
        session.activate()
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { print( "PHONE ACTIVE!")}
    public func sessionDidBecomeInactive(_ session: WCSession) { }
    public func sessionDidDeactivate(_ session: WCSession) { }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("got request")
        if (message["request"] as! String == "all") {
            print("all")
            for file in self.files {
                print(file)
                if let isSaved = UserDefaults.standard.object(forKey: file + "Saved") {
                    print(isSaved)
                    if (isSaved as! Bool) {
                        loadSavedImages(file: file)
                        print(self.allLots)
                        replyHandler(allLots)
                    }
                }
            }
        }
    }
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        if (message["request"] as! String == "all") {
//            for file in self.files {
//                if let isSaved = UserDefaults.standard.object(forKey: file + "Saved") {
//                    if (isSaved as! Bool) {
//                        loadSavedImages(file: file)
//                    }
//                }
//            }
//        }
    }
    
    func loadSavedImages(file: String) {
        let savedCount = UserDefaults.standard.object(forKey: file + "SavedCount") as! Int
        print(savedCount)
            for i in 0...(savedCount-1) {
                print(file + String(i) + ".png")
                self.allLots[file]?.append(getSavedImage(named: file + String(i) + ".png") ?? UIImage())
            }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
}
