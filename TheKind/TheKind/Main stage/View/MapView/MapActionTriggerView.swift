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
    let mapViewModel = MapViewModel()
    @IBOutlet var enterCircleView: UIView!
    @IBOutlet var labelCircleName: UILabel!
    @IBOutlet var enterCircleButton: UIButton!
    @IBOutlet var mapBoxView: MGLMapView! {
        didSet {
            mapBoxView.maximumZoomLevel = 18
            //setup observer
            generateAnnotations()
        }
    }
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
        
        mapBoxView.styleURL = MGLStyle.darkStyleURL
        mapBoxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapBoxView.tintColor = .lightGray
        
        
        mapBoxView.delegate = self
        locationManager?.delegate = self
        self.talkbox?.delegate = self
        
        
       delay(bySeconds: 1) {
            if let coordinate = self.locationManager?.location?.coordinate {
                 self.mapBoxView.setCenter(coordinate, zoomLevel: 14, animated: true)
            } else {
                // TODO: Eliminate this - Only for testing purposes.
                 self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 45.52954,
                                                         longitude: -122.72317),
                                  zoomLevel: 14, animated: false)
            }
        }
        
        //This is triggering the viewmodel
        //This will be eslwhere - DATALAYER?
        mapViewModel.circleDataSet = [CircleAnnotationSet.init(coordinate: CLLocationCoordinate2D(latitude: 37.774997, longitude: -122.394977), circleName: "Phil Coffee Berry", isPrivate: true),
         CircleAnnotationSet.init(coordinate: CLLocationCoordinate2D(latitude: 37.774836, longitude: -122.387258), circleName: "Marina", isPrivate: true)]
        
    }
    
    
    override func activate() {
        self.alpha = 0
        self.isHidden = false
        self.talkbox?.delegate = self
        UIView.animate(withDuration: 1) {
            self.alpha = 1
            self.mainViewController?.jungChatWindow.alpha = 0
            self.mainViewController?.topCurtainView.alpha = 0
        }
    }

}

extension MapActionTriggerView: MGLMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }
    
    func generateAnnotations() {
        // Whenever the MapViewModel receives the data this fires.
        mapViewModel.annotationIndexObserver = { [unowned self](circleDataset) in
            var pointAnnotations = [MGLPointAnnotation]()
            for circle in circleDataset {
                let point = MGLPointAnnotation()
                point.coordinate = circle.coordinate
                //TODO: Without a name shouldn't be displayed.
                point.title = circle.circleName ?? "---"//"\(coordinate.latitude), \(coordinate.longitude)"
                pointAnnotations.append(point)
            }
            
            self.mapBoxView.addAnnotations(pointAnnotations)
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        guard let titleName = annotation.title else {return nil}
        let reuseIdentifier = titleName! + "-" + String(annotation.coordinate.longitude)
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CircleAnnotationView
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CircleAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        
        //TODO: guard let returning  nil if no title.
        annotationView?.circleName = titleName!
        annotationView?.alpha = 0.9
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        
        guard let annotationView = annotationView as? CircleAnnotationView else {return}
            
        //Get the selected annotation for deactivating it in case map-moves: mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool)
        selectedAnnotation = annotationView
        guard let coordinates = annotationView.annotation?.coordinate else {return}
        mapView.setCenter(coordinates, zoomLevel: 18,animated: true)

        guard let name = annotationView.circleName else {return}
        labelCircleName.attributedText = formatLabelTextWithLineSpacing(text: name)
        
        activateOnSelection(annotationView, completion: nil)
    
        
    }
    
    
    func mapView(_ mapView: MGLMapView, didDeselect annotationView: MGLAnnotationView) {
        guard let annotationView = annotationView as? CircleAnnotationView else {return}
        mapView.setZoomLevel(14, animated: true)
        
        deActivateOnDeselection(annotationView,completion: nil)
    }
    
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        self.enterCircleView.alpha = 0
        // If there is an active annotation and this annotation is REALLY open.
        if let annotationView = selectedAnnotation, !annotationView.transform.isIdentity {
            deActivateOnDeselection(annotationView) {
                annotationView.setSelected(false, animated: false)
                self.selectedAnnotation = nil
                
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    fileprivate func activateOnSelection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        // If all went fine with coordinate and name, animate.
        UIView.animate(withDuration: 1, animations: {
            //scaling
            annotationView.transform = CGAffineTransform(scaleX: 6, y: 6)
            annotationView.alpha = 0.32
            
        }) { (Completed) in
            // If full transform happened. (sometimes a bug in the map cuts off the animation)
            if !annotationView.transform.isIdentity {
                self.mainViewController?.moveBottomCurtain(distance: 90) {
                    print("done activateOnSelection")
                    UIView.animate(withDuration: 0.5, animations: {
                        self.mainViewController?.circleDetailsHost.alpha = 1
                    })
                    
                }
                UIView.animate(withDuration: 0.3, animations: {
                    // presenting button and label
                    self.enterCircleView.alpha = 1
                    self.enterCircleView.isUserInteractionEnabled = true
                })
            } else {
                // If it did cut off, cancel interaction.
                annotationView.setSelected(false, animated: false)
                self.enterCircleView.isUserInteractionEnabled = false
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    fileprivate func deActivateOnDeselection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        self.enterCircleView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
            annotationView.alpha = 0.9
            annotationView.button.alpha = 0
            self.enterCircleView.isUserInteractionEnabled = false
        }) { (completed) in
            delay(bySeconds: 0.5, closure: {
                self.mainViewController?.circleDetailsHost.alpha = 0
                self.mainViewController?.moveBottomCurtain(distance: -90) {
                    
                    // completed.
                    if let completion = completion {
                        completion()
                    }
                }
                
            })


        }
        
        
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
