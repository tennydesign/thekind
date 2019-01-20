//
//  MapView.swift
//  TheKind
//
//  Created by Tenny on 1/18/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import Mapbox
import MapKit

class MapView: KindActionTriggerView, MGLMapViewDelegate, CLLocationManagerDelegate {
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet var mainView: UIView!
    var locationManager: CLLocationManager?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        locationManager = CLLocationManager()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MapView", owner: self, options: nil)
        addSubview(mainView)
        
        mapView.styleURL = MGLStyle.darkStyleURL
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .lightGray
        
        
        mapView.delegate = self
        locationManager?.delegate = self
        self.talkbox?.delegate = self
        
        
       delay(bySeconds: 1) {
            if let coordinate = self.locationManager?.location?.coordinate {
                 self.mapView.setCenter(coordinate, zoomLevel: 14, animated: true)
            } else {
                 self.mapView.setCenter(CLLocationCoordinate2D(latitude: 45.52954,
                                                         longitude: -122.72317),
                                  zoomLevel: 14, animated: false)
            }
        }

        // TODO: This will come from Firestore filtered by proximity.
        let coordinates = [
            CLLocationCoordinate2D(latitude: 37.774997, longitude: -122.394977)
        ]
        
        var pointAnnotations = [MGLPointAnnotation]()
        for coordinate in coordinates {
            let point = MGLPointAnnotation()
            point.coordinate = coordinate
            point.title = "\(coordinate.latitude), \(coordinate.longitude)"
            pointAnnotations.append(point)
        }
        
        mapView.addAnnotations(pointAnnotations)
    }
    
    
    override func activate() {
        self.alpha = 0
        self.isHidden = false
        self.talkbox?.delegate = self
        UIView.animate(withDuration: 1) {
            self.alpha = 1
        }
    }

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = circleAnnotation(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = CGRect(x: 0, y: 0, width: 80, height: 80)
            
            // Set the annotation view’s background color to a value determined by its longitude.
            annotationView!.backgroundColor = UIColor.clear
            
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

}


class circleAnnotation: MGLAnnotationView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor(r: 176, g: 38, b: 65).cgColor
        alpha = 0.9
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.4
        layer.borderWidth = selected ? bounds.width / 1 : 2
        layer.add(animation, forKey: "borderWidth")
    }
    
}
