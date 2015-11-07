//
//  ViewController.swift
//  RoadCurb
//
//  Created by Andrei Nechaev on 11/7/15.
//  Copyright © 2015 RoadCurb. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var obstacleBtn: UIButton!
    var firebase = Firebase(url: "https://roadcurb.firebaseio.com/obstacles")
    @IBOutlet weak var mapView: MKMapView!
    lazy var clManager: CLLocationManager = {
        let clm = CLLocationManager()
        clm.requestAlwaysAuthorization()
        
        return clm
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        clManager.delegate = self
        mapView.showsUserLocation = true
        
        obstacleBtn.layer.borderColor = UIColor.whiteColor().CGColor
        obstacleBtn.layer.cornerRadius = obstacleBtn.bounds.width / 2
        obstacleBtn.layer.masksToBounds = true
        
        obstacleBtn.userInteractionEnabled = false
        
        firebase.queryStartingAtValue(" ").observeEventType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            print("\(snapshot.key) -> \(snapshot.value)")
//            for (_, v) in snapshot.value as! NSDictionary {
//                if let dict = v as? NSDictionary {
//                    let date = dict.valueForKey("date")
//                    if let date = date as? NSNumber {
//                        print("Date = \(NSDate(timeIntervalSince1970:date.doubleValue/1000.0))")
//                    }
//                }
//            }
        }

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(userLocation.location!.coordinate, span)
        
        mapView.setRegion(region, animated: true)
        obstacleBtn.userInteractionEnabled = true
    }
    
    @IBAction func obstacleBtnPressed(sender: UIButton) {
        let coordinates = mapView.userLocation.coordinate
        print("User location \(mapView.userLocation.coordinate)")
        let kFirebaseServerValueTimestamp = [".sv": "timestamp"]
        
        firebase.push([
            "latitude": coordinates.latitude,
            "longitude": coordinates.longitude,
            "date": kFirebaseServerValueTimestamp,
            "user_name": "User Name"
            ])
        
//        let lon = 73984638
//        let lat = 40759211
//        
//        
//        srandom(UInt32(NSDate().timeIntervalSince1970))
//        
//        for i in 0...100 {
//            let rand = random()
//            let la = Double(rand * i % lat) / 1e6
//            let lo = Double(rand * i % lon) / -1e6
//            firebase.push([
//                "latitude": la,
//                "longitude": lo,
//                "date": kFirebaseServerValueTimestamp,
//                "user_name": "User Name"
//                ])
//        }
     
    }
}

extension Firebase {
    func push(obj: AnyObject) {
        self.childByAutoId().setValue(obj)
    }
}

