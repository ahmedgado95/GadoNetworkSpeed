//
//  GadoNetworkSpeed.swift
//  AGNetworkSpeed
//
//  Created by Ahmed Gado on 06/09/2021.
//  Copyright © 2021 ahmed gado. All rights reserved.
//

import UIKit
protocol NetworkSpeedDelegate: AnyObject {
    func callIfSpeedIsChangeed(networkStatus: NetworkStatus)
   }
public enum NetworkStatus : String {
    case poor
    case good
    case disConnected
}

class AGNetworkSpeed: UIViewController {
    
    weak var delegate: NetworkSpeedDelegate?
    var startTime = CFAbsoluteTime()
    var stopTime = CFAbsoluteTime()
    var bytesDidReceived: CGFloat = 0
    var speedURL:String?
    var speedCompletionHandler: ((_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void)? = nil
    var timerForSpeed:Timer?
    
    func networkSpeedStart(UrlForSpeed:String!){
        speedURL = UrlForSpeed
        timerForSpeed = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(didSpeedChange), userInfo: nil, repeats: true)
    }
    func networkSpeedTestStop(){
        timerForSpeed?.invalidate()
    }
    @objc func didSpeedChange(){
        downloadSpeed(withTimout: 2.0, completionHandler: {(_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void in
            print("%0.1f Kb Per Sec = \(megabytesPerSecond)")
            if (error as NSError?)?.code == -1009
            {
                self.delegate?.callIfSpeedIsChangeed(networkStatus: .disConnected)
            }
            else if megabytesPerSecond == -1.0
            {
                self.delegate?.callIfSpeedIsChangeed(networkStatus: .poor)
            }
            else
            {
                self.delegate?.callIfSpeedIsChangeed(networkStatus: .good)
            }
        })
    }
}
extension AGNetworkSpeed: URLSessionDataDelegate, URLSessionDelegate {

func downloadSpeed(withTimout timeout: TimeInterval, completionHandler: @escaping (_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void) {

    // you set any relevant string with any file
    let urlForSpeedTest = URL(string: speedURL!)

    startTime = CFAbsoluteTimeGetCurrent()
    stopTime = startTime
    bytesDidReceived = 0
    speedCompletionHandler = completionHandler
    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForResource = timeout
    let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

    guard let checkedUrl = urlForSpeedTest else { return }

    session.dataTask(with: checkedUrl).resume()
}

func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    bytesDidReceived += CGFloat(data.count)
    stopTime = CFAbsoluteTimeGetCurrent()
}

func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    let elapsed = (stopTime - startTime) //as? CFAbsoluteTime
    let speed: CGFloat = elapsed != 0 ? bytesDidReceived / (CGFloat(CFAbsoluteTimeGetCurrent() - startTime)) / 1024.0 : -1.0
    // treat timeout as no error (as we're testing speed, not worried about whether we got entire resource or not
    if error == nil || ((((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == NSURLErrorTimedOut) {
        speedCompletionHandler?(speed, nil)
    }
    else {
        speedCompletionHandler?(speed, error)
    }
  }
}
