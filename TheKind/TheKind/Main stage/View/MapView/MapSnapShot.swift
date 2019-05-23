//
//  MapSnapShot.swift
//  TheKind
//
//  Created by Tenny on 5/17/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class CrumbSnapShot {
    
    let mapSnapShotOptions = MKMapSnapshotter.Options()
    let snapLocation: CLLocationCoordinate2D
    
    init(location: CLLocationCoordinate2D) {
        snapLocation = location
        mapSnapShotOptions.region = MKCoordinateRegion(center: snapLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapSnapShotOptions.scale = UIScreen.main.scale
        mapSnapShotOptions.size = CGSize(width: 100, height: 100)
        mapSnapShotOptions.showsBuildings = true
        mapSnapShotOptions.showsPointsOfInterest = true
        
    }
    
    func getSnapper() -> MKMapSnapshotter {
        return MKMapSnapshotter(options: mapSnapShotOptions)
    }
    
    func snapMapPhoto(completion: ((UIImage)->())?) {
        let locationToSnap = snapLocation
        let crumbSnapShot = CrumbSnapShot(location: locationToSnap)
        let snapper: MKMapSnapshotter = crumbSnapShot.getSnapper()
        
        snapper.start { mapsnapshot, error in
            
            guard let mapsnapshot = mapsnapshot, error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(crumbSnapShot.mapSnapShotOptions.size, true, 0)
            
            let imageToDraw = mapsnapshot.image.noir ?? mapsnapshot.image
            imageToDraw.draw(at: .zero)

            let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
//            let pinImage = pinView.image
            let pinImage = UIImage(named: "circleIcon")

            var point = mapsnapshot.point(for: locationToSnap)

//            let pinCenterOffset = pinView.centerOffset
            point.x -= pinView.bounds.size.width / 2
            point.y -= pinView.bounds.size.height / 2
//            point.x += pinCenterOffset.x
//            point.y += pinCenterOffset.y
            pinImage?.draw(at: point)
            
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {return}
            
            UIGraphicsEndImageContext()
            completion?(image)
        
        }
    }
}



