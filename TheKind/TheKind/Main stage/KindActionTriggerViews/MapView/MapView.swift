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

// TODO: Refactor this.




struct CircleAnnotationSet {
    var coordinate: CLLocationCoordinate2D
    var circleName: String?
    var isPrivate: Bool
}





class MapActionTriggerView: KindActionTriggerView {
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    
    @IBOutlet var enterCircleView: UIView!
    @IBOutlet var labelCircleName: UILabel!
    @IBOutlet var enterCircleButton: UIButton!
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet var mainView: UIView!
    var locationManager: CLLocationManager?
    
    var selectedAnnotation: CircleAnnotationView?
    
    
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
        
        mapView.maximumZoomLevel = 18
        
        
       delay(bySeconds: 1) {
            if let coordinate = self.locationManager?.location?.coordinate {
                 self.mapView.setCenter(coordinate, zoomLevel: 14, animated: true)
            } else {
                // TODO: Eliminate this - Only for testing purposes.
                 self.mapView.setCenter(CLLocationCoordinate2D(latitude: 45.52954,
                                                         longitude: -122.72317),
                                  zoomLevel: 14, animated: false)
            }
        }
        generateAnnotations()
    }
    
    
    override func activate() {
        self.alpha = 0
        self.isHidden = false
        self.talkbox?.delegate = self
        UIView.animate(withDuration: 1) {
            self.alpha = 1
        }
    }

}

extension MapActionTriggerView: MGLMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }
    
    func generateAnnotations() {
        var pointAnnotations = [MGLPointAnnotation]()
        
        // TODO: This comes from the FIRESTORE database
        // retrieveCircleDataSetWithinRange(range: CLLocationCoordinate2D, radius: CGFloat)
        let circleDataset = [CircleAnnotationSet.init(coordinate: CLLocationCoordinate2D(latitude: 37.774997, longitude: -122.394977), circleName: "Phil Coffee Berry", isPrivate: true),
                                 CircleAnnotationSet.init(coordinate: CLLocationCoordinate2D(latitude: 37.774836, longitude: -122.387258), circleName: "Marina", isPrivate: true)]
        

        for circle in circleDataset {
            let point = MGLPointAnnotation()
            point.coordinate = circle.coordinate
            point.title = circle.circleName ?? "---"//"\(coordinate.latitude), \(coordinate.longitude)"
            pointAnnotations.append(point)
        }
        
        mapView.addAnnotations(pointAnnotations)
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CircleAnnotationView
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CircleAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        
        //TODO: guard let returning  nil if no title.
        annotationView?.circleName = annotation.title ?? "---"
        annotationView?.alpha = 0.9
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        
        if let annotationView = annotationView as? CircleAnnotationView {
            selectedAnnotation = annotationView
            mapView.setCenter((annotationView.annotation?.coordinate)!, zoomLevel: 18,animated: true)
            
            //Filling label.
            labelCircleName.attributedText = formatLabelTextWithLineSpacing(text: annotationView.circleName ?? "---")
            
            UIView.animate(withDuration: 1, animations: {
                //scaling
                annotationView.transform = CGAffineTransform(scaleX: 6, y: 6)
                annotationView.alpha = 0.32
                
            }) { (Completed) in
                if !annotationView.transform.isIdentity {
                    UIView.animate(withDuration: 0.3, animations: {
                        // presenting button and label
                        self.enterCircleView.alpha = 1
                        self.enterCircleView.isUserInteractionEnabled = true
                    })
                } else {
                    // just to deal with the Map bug of clicking too close to the edge
                    annotationView.setSelected(false, animated: false)
                    self.enterCircleView.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    
    func mapView(_ mapView: MGLMapView, didDeselect annotationView: MGLAnnotationView) {
        if let annotationView = annotationView as? CircleAnnotationView {
            mapView.setCenter((annotationView.annotation?.coordinate)!, zoomLevel: 14,animated: true)
            self.enterCircleView.alpha = 0
            UIView.animate(withDuration: 1) {
                annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                annotationView.alpha = 0.9
                annotationView.button.alpha = 0
                self.enterCircleView.isUserInteractionEnabled = false
            }
            selectedAnnotation = nil
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        self.enterCircleView.alpha = 0
        if let annotation = selectedAnnotation {
            UIView.animate(withDuration: 1, animations: {
                annotation.transform = CGAffineTransform(scaleX: 1, y: 1)
                annotation.alpha = 0.9
                annotation.button.alpha = 0
                self.enterCircleView.isUserInteractionEnabled = false
                annotation.setSelected(false, animated: false)
            }) { (completed) in
                
            }
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
}


class CircleAnnotationView: MGLAnnotationView {
    var circleName: String?
    let button = UIButton(type: .system)
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    
    
    func commonInit() {

    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = bounds.width / 2
        layer.backgroundColor = UIColor(r: 176, g: 38, b: 65).cgColor
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0

    }

    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

 
//        // Animate the border width in/out, creating an iris effect.
//        let animation = CABasicAnimation(keyPath: "borderWidth")
//        animation.duration = 0.4
//        layer.borderWidth = selected ? bounds.width / 1 : 2
//        layer.add(animation, forKey: "borderWidth")
//

    }
    
    
}
