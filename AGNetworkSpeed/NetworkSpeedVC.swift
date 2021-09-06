//
//  NetworkSpeedVC.swift
//  AGNetworkSpeed
//
//  Created by Ahmed Gado on 06/09/2021.
//  Copyright © 2021 ahmed gado. All rights reserved.
//

import UIKit

class NetworkSpeedVC: UIViewController , NetworkSpeedDelegate {

    

    let test = AGNetworkSpeed()
    override func viewDidLoad() {
        super.viewDidLoad()
        test.delegate = self
        test.networkSpeedTestStop()
        test.networkSpeedStart(UrlForSpeed: "https://weather.com/weather/today/l/29.99,30.98?par=google")
        // Do any additional setup after loading the view.
    }
    
    func callIfSpeedIsChangeed(networkStatus: NetworkStatus) {
        switch networkStatus {
        case .poor:
            print("poor")
        case .good:
            print("good")
        case .disConnected:
            print("disConnected")
        }
    }
    

}
