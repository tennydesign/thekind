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

class MapActionTriggerView: KindActionTriggerView {

    @IBOutlet var insideExpandedCircleView: UIView!
    @IBOutlet var labelCircleName: UILabel!
    @IBOutlet var enterCircleButton: UIButton!
    @IBOutlet var mapBoxView: MGLMapView! {
        didSet {
            mapBoxView.maximumZoomLevel = MAXZOOMLEVEL
            //setup observer
            plotAnnotations()
        }
    }
    @IBOutlet var mainView: UIView!
    
    
    var locationManager: CLLocationManager?
    var selectedAnnotation: CircleAnnotationView?
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    let mapViewViewModel = MapViewViewModel()
    let circleAnnotationModel = CircleAnnotationModel()
    
    let MAXZOOMLEVEL: Double = 18
    let FLYOVERZOOMLEVEL: Double = 14
    let MAXSCIRCLESCALE: CGFloat = 6.0
    let MOVEDRAWERDISTANCE: CGFloat = 90.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
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
        
        locationManager = CLLocationManager()
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

        
        
        
    }
    
    
    override func activate() {
        //load annotations.
        mapViewViewModel.retrieveCirclesCloseToPlayer() {
            //present map after annotations are there.
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

}

extension MapActionTriggerView: MGLMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }
    
    func plotAnnotations() {
        // Whenever the MapViewModel receives the data this fires.
        mapViewViewModel.annotationIndexObserver = { [unowned self](circleAnnotationSets) in
            var pointAnnotations = [KindPointAnnotation]()
            for item in circleAnnotationSets {
                let point = KindPointAnnotation()
                point.circleDetails = item
                point.coordinate = item.coordinate
                // Only lots if it has a name.
                if let title = item.circlePlotName {
                    point.title = title //"\(coordinate.latitude), \(coordinate.longitude)"
                    pointAnnotations.append(point)
                }
            }
            
            self.mapBoxView.addAnnotations(pointAnnotations)
        }
        
    }
    

    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        let annotationBounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        guard let kindAnnotation = annotation as? KindPointAnnotation else {
            return nil
        }

        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        guard let titleName = kindAnnotation.circleDetails?.circlePlotName else {return nil}
        let reuseIdentifier = titleName + String(annotation.coordinate.longitude)
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CircleAnnotationView
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CircleAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = annotationBounds
        }
        
        annotationView?.circleDetails = kindAnnotation.circleDetails
        
        return annotationView
    }
    

    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        
        guard let annotationView = annotationView as? CircleAnnotationView else {return}
            
        //Get the selected annotation for deactivating it in case map-moves: mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool)
        selectedAnnotation = annotationView
        guard let coordinates = annotationView.circleDetails?.coordinate else {return}
        mapView.setCenter(coordinates, zoomLevel: MAXZOOMLEVEL,animated: true)

        guard let name = annotationView.circleDetails?.circlePlotName else {return}
        labelCircleName.attributedText = formatLabelTextWithLineSpacing(text: name)
        
        activateOnSelection(annotationView, completion: nil)

    }
    

    func mapView(_ mapView: MGLMapView, didDeselect annotationView: MGLAnnotationView) {
        guard let annotationView = annotationView as? CircleAnnotationView else {return}
        mapView.setZoomLevel(FLYOVERZOOMLEVEL, animated: true)
        
        deActivateOnDeselection(annotationView,completion: nil)
    }
    
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        self.insideExpandedCircleView.alpha = 0
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
        UIView.animate(withDuration: 1, animations: {
            //scaling
            annotationView.transform = CGAffineTransform(scaleX: self.MAXSCIRCLESCALE, y: self.MAXSCIRCLESCALE)
            annotationView.alpha = 0.32
            
        }) { (Completed) in
            // If full transform happened. (sometimes a bug in the map cuts off the animation)
            if !annotationView.transform.isIdentity {
                self.mainViewController?.moveMapBottomPanel(distance: self.MOVEDRAWERDISTANCE) {
                    print("done activateOnSelection")
                    //check if scale is 100% open otherwise won't show detailsview
                    if annotationView.transform.a == self.MAXSCIRCLESCALE {
                        UIView.animate(withDuration: 0.6, animations: {
                            self.mainViewController?.circleDetailsHost.alpha = 1
                        })
                    }
                    
                }
                // presenting button and label
                self.insideExpandedCircleView.alpha = 1
                self.insideExpandedCircleView.isUserInteractionEnabled = true

            } else {
                // If it did cut off, cancel interaction.
                annotationView.setSelected(false, animated: false)
                self.insideExpandedCircleView.isUserInteractionEnabled = false
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    fileprivate func deActivateOnDeselection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        self.insideExpandedCircleView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
            annotationView.alpha = 0.9
            annotationView.button.alpha = 0
            self.insideExpandedCircleView.isUserInteractionEnabled = false
        }) { (completed) in
            delay(bySeconds: 0.5, closure: {
                self.mainViewController?.circleDetailsHost.alpha = 0
                self.mainViewController?.moveMapBottomPanel(distance: -self.MOVEDRAWERDISTANCE) {
                    
                    // completed.
                    if let completion = completion {
                        completion()
                    }
                }
                
            })


        }
        
        
    }
    
}
