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

class Obstacle {
    var date: NSDate
    var userName: String
    var coordintes: CLLocationCoordinate2D
    
    init(json: [String: AnyObject]) {
        userName = json["user_name"] as! String
        
        let d = json["date"] as! Double
        date = NSDate(timeIntervalSince1970:d/1000.0)
        
        let lat = json["latitude"] as! Double
        let lon = json["longitude"] as! Double
        coordintes = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, CCHMapClusterControllerDelegate {

    @IBOutlet weak var obstacleBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var firebase = Firebase(url: "https://roadcurb.firebaseio.com/obstacles")
    
    lazy var clManager: CLLocationManager = {
        let clm = CLLocationManager()
        clm.requestAlwaysAuthorization()
        
        return clm
    }()

    var annotations = [MKPointAnnotation]()
    
    lazy var dateFormater: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateStyle = .ShortStyle
        return df
    }()
    
    lazy var mapClusterController: CCHMapClusterController = {
        let mcc = CCHMapClusterController(mapView: self.mapView)
        mcc.delegate = self
        return mcc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clManager.delegate = self
        mapView.showsUserLocation = true
        
        obstacleBtn.roundCornerWith(5.0)
        obstacleBtn.userInteractionEnabled = false
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(userLocation.location!.coordinate, span)
        
        mapView.setRegion(region, animated: true)
        obstacleBtn.userInteractionEnabled = true
        print("coordinates \(userLocation.coordinate)")
        firebase.queryOrderedByChild("latitude").queryStartingAtValue(region.center.latitude - 1).queryEndingAtValue(region.center.latitude + 1).observeEventType(.Value) { [unowned self] (snapshot: FDataSnapshot!) -> Void in
            print("\(snapshot.key) -> \(snapshot.value)")
            for (_, v) in snapshot.value as! NSDictionary {
                let obstacle = Obstacle(json: v as! [String: AnyObject])

                guard (obstacle.coordintes.longitude > region.center.longitude - 1.0) &&
                    (obstacle.coordintes.longitude < region.center.longitude + 1.0) else {
                        continue
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = obstacle.coordintes
                annotation.title = obstacle.userName
                annotation.subtitle = self.dateFormater.stringFromDate(obstacle.date)
                self.annotations.append(annotation)
            }
        
            self.mapClusterController.addAnnotations(self.annotations, withCompletionHandler: nil)
        }
    }
    
    
    //MARK: CCHMapClusterControllerDelegate
    func mapClusterController(mapClusterController: CCHMapClusterController!, titleForMapClusterAnnotation mapClusterAnnotation: CCHMapClusterAnnotation!) -> String! {
        return "Test"
    }
    
    func mapClusterController(mapClusterController: CCHMapClusterController!, subtitleForMapClusterAnnotation mapClusterAnnotation: CCHMapClusterAnnotation!) -> String! {
        return "subtitle"
    }
    
    //MARK: IBActions
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
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let lon = 100000
            let lat = 100000
            
            for _ in 0...100 {
                srandom(UInt32(NSDate().timeIntervalSinceNow))
                
                var rand = Int(arc4random())
                let la = (Double(Int(coordinates.latitude * 10.0)) + (Double(rand % lat) / 1e5)) / 10.0
                rand = Int(arc4random())
                let lo = (Double(Int(coordinates.longitude * 10.0)) + (Double(rand % lon) / -1e5)) / 10.0
                self.firebase.push([
                    "latitude": la,
                    "longitude": lo,
                    "date": kFirebaseServerValueTimestamp,
                    "user_name": "User Name"
                    ])
            }
        })
        
    }
}

extension Firebase {
    func push(obj: AnyObject) {
        self.childByAutoId().setValue(obj)
    }
}

extension UIView {
    func roundCornerWith(radius: CGFloat) {
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.masksToBounds = true
    }
}

