//
//  CWLocationer.swift
//  CWLocationer
//
//  Created by Coulson_Wang on 2017/7/10.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//

import UIKit
import CoreLocation

typealias LocationResultBlock = (_ location: CLLocation?, _ errorMsg: String?) -> ()

enum CWLocationAccuracy {
    case BestForNavigation
    case BestBest
    case TenMeters
    case HundredMeters
    case Kilometer
    case ThreeKilometers
}

class CWLocationer: NSObject {
    
    static let sharedInstance : CWLocationer = CWLocationer()
    
    fileprivate lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        /// 请求授权
        if #available(iOS 8.0, *) {
            if let infoDict = Bundle.main.infoDictionary {
                let whenInUse = infoDict["NSLocationAlwaysUsageDescription"]
                let awaysUse = infoDict["NSLocationAlwaysUsageDescription"]
                
                if awaysUse != nil {
                    locationManager.requestAlwaysAuthorization()
                } else if whenInUse != nil {
                    locationManager.requestWhenInUseAuthorization()
                } else {
                    print("未配置权限请求的Description")
                }
            }
        }
        return locationManager
    }()
    
    fileprivate var resultBlock: LocationResultBlock?
    
    // MARK:- 对外方法
    
    /// 持续请求定位
    func getCurrentLocation(desiredAccuracy : CWLocationAccuracy?, resultBlock: @escaping LocationResultBlock) -> Void{
        self.resultBlock = resultBlock
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = handleWithAccuracy(accuracy: desiredAccuracy)
            locationManager.startUpdatingLocation()
        } else {
            resultBlock(nil, "设备不支持定位服务")
        }
    }
    
    /// 请求一次定位
    func getCurrentLocationForOnce(desiredAccuracy : CWLocationAccuracy?, resultBlock : @escaping LocationResultBlock) -> Void {
        self.resultBlock = resultBlock
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = handleWithAccuracy(accuracy: desiredAccuracy)
            locationManager.requestLocation()
        } else {
            resultBlock(nil, "设备不支持定位服务")
        }
    }
}


// MARK:- 请求回调
extension CWLocationer : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            if let resultBlock = resultBlock {
                resultBlock(nil,"没有获取到位置信息")
            }
            return
        }
        if let resultBlock = resultBlock {
            resultBlock(location,nil)
        }
    }
}

// MARK:- 工具方法
extension CWLocationer {
    fileprivate func handleWithAccuracy(accuracy: CWLocationAccuracy?) -> CLLocationAccuracy {
        guard let accuracy = accuracy else {
            return kCLLocationAccuracyBest
        }
        switch accuracy {
        case .BestForNavigation:
            return kCLLocationAccuracyBestForNavigation
        case .BestBest:
            return kCLLocationAccuracyBest
        case .TenMeters:
            return kCLLocationAccuracyNearestTenMeters
        case .HundredMeters:
            return kCLLocationAccuracyHundredMeters
        case .Kilometer:
            return kCLLocationAccuracyKilometer
        case .ThreeKilometers:
            return kCLLocationAccuracyThreeKilometers
        }
    }
}
