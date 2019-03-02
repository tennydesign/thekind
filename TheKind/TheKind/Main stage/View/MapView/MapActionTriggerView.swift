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
//REFACTOR THE UP AND DOWN FOR DRAWER
class MapActionTriggerView: KindActionTriggerView {

    @IBOutlet var insideExpandedCircleViewYConstraint: NSLayoutConstraint!
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
    
    // INIT VALUES
    let MAXZOOMLEVEL: Double = 18
    let FLYOVERZOOMLEVEL: Double = 14
    let MAXSCIRCLESCALE: CGFloat = 6.0
    var openDrawerDistance: CGFloat = -180.0
    let hiddenDrawerDistance: CGFloat = -280
    let iphoneXFamilyOpenDrawerAdj:CGFloat = 48
    let iphoneXFamilyExpandedCircleInnerContentAdj: CGFloat = 10
    let annotationBounds: CGRect = CGRect(x: 0, y: 0, width: 30, height: 30)
    // ======
    
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
        mapBoxView.logoView.isHidden = true
        mapBoxView.attributionButton.isHidden = true
        
        if UIScreen.isPhoneXfamily {
            openDrawerDistance += iphoneXFamilyOpenDrawerAdj
            insideExpandedCircleViewYConstraint.constant = iphoneXFamilyExpandedCircleInnerContentAdj
            self.layoutIfNeeded()
        }
        
        mapBoxView.delegate = self
        locationManager?.delegate = self
        self.talkbox?.delegate = self
        locationManager = CLLocationManager()
        
        //TODO: COntrol for locationmanager absense
        delay(bySeconds: 1) {
//            if let coordinate = self.locationManager?.location?.coordinate {
//                 self.mapBoxView.setCenter(coordinate, zoomLevel: 14, animated: true)
//            } else {
//                // TODO: Eliminate this - Only for testing purposes.
//                 self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
//                                                         longitude: -122.389246),
//                                  zoomLevel: 14, animated: false)
//            }
            
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
            self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
                                                             longitude: -122.389246),
                                      zoomLevel: 14, animated: false)
        }

        
        
    }
    
    
    
    override func talk() {

        

    }
    
    override func activate() {
        if mainViewController?.kindUserManager != nil {
            mainViewController?.kindUserManager.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.MapView.rawValue
            
            //work on the map before showing
            clearJungChatLog()
            UIView.animate(withDuration: 0.4, animations: {
                self.mainViewController?.jungChatLogger.alpha = 0
            }) { (completed) in
                self.mainViewController?.moveBottomPanel(distance: self.hiddenDrawerDistance) {
                    self.mapViewViewModel.retrieveCirclesCloseToPlayer() {
                        //present map after annotations are there.
                        self.alpha = 0
                        self.isHidden = false
                        self.talkbox?.delegate = self
                        UIView.animate(withDuration: 1) {
                            self.alpha = 1
                        }
                    }
                }
            }
            
            self.talk()
        } else {
            fatalError("Cant find user manager in UserNameView - We need a user manager for onboarding logging")
        }
        

    }
    
    func clearJungChatLog() {
        self.mainViewController?.jungChatLogger.resetJungChat()
        self.mainViewController?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }
    
    func describeCircle(circleID: Int) {
        // check ID and retrieve routine
        let txt = "An Angel's heaven.-You have high chances of making friends here.-You need the key to enter this circle."
        let actions: [KindActionType] = [.none, .none,.none]
        let actionViews: [ActionViewName] = [.none,.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Back to map", opt2: "Join this circle.", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    

    override func leftOptionClicked() {
        guard let annotation = selectedAnnotation else {return}
        deActivateOnDeselection(annotation) {
            print("returned")
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
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
                // Only plot if it has a name.
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
        
        activateOnSelection(annotationView) { (circleId) in
            self.describeCircle(circleID: circleId)
        }

    }
    

    func mapView(_ mapView: MGLMapView, didDeselect annotationView: MGLAnnotationView) {
        guard let annotationView = annotationView as? CircleAnnotationView else {return}
        mapView.setZoomLevel(FLYOVERZOOMLEVEL, animated: true)
        
        deActivateOnDeselection(annotationView,completion: nil)
    }
    
    //MAP IS DRAGGED.
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
    

    fileprivate func activateOnSelection(_ annotationView: CircleAnnotationView, completion: ((_ circleId: Int)->())?) {
        UIView.animate(withDuration: 1, animations: {
            //scaling
            annotationView.transform = CGAffineTransform(scaleX: self.MAXSCIRCLESCALE, y: self.MAXSCIRCLESCALE)
            annotationView.alpha = 0.32
            
        }) { (Completed) in
            // If full transform happened. (sometimes a bug in the map cuts off the animation)
            if !annotationView.transform.isIdentity {
                self.clearJungChatLog()
                self.mainViewController?.moveBottomPanel(distance: self.openDrawerDistance){
                    //check if scale is 100% open otherwise won't show Jung
                    if annotationView.transform.a == self.MAXSCIRCLESCALE {
                        UIView.animate(withDuration: 0.4, animations: {
                            self.mainViewController?.jungChatLogger.alpha = 1
                            self.insideExpandedCircleView.alpha = 1
                        })
                        self.insideExpandedCircleView.isUserInteractionEnabled = true
                        
                        if let circleId = annotationView.circleDetails?.circleId {
                            if let completion = completion {
                                    completion(circleId)
                            }
                        }

                        }
                    }
                    
                } else {
                // If it did cut off, cancel interaction.
                annotationView.setSelected(false, animated: false)
                self.insideExpandedCircleView.isUserInteractionEnabled = false
            }
        }
    }
    
    fileprivate func deActivateOnDeselection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        self.insideExpandedCircleView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
            annotationView.alpha = 0.9
            annotationView.button.alpha = 0
            self.mainViewController?.jungChatLogger.alpha = 0
            self.clearJungChatLog()
            self.insideExpandedCircleView.isUserInteractionEnabled = false
        }) { (completed) in
            delay(bySeconds: 0.5, closure: {
                
                //self.mainViewController?.circleDetailsHost.alpha = 0
                self.mainViewController?.moveBottomPanel(distance: self.hiddenDrawerDistance) {
                    if let completion = completion {
                        completion()
                    }
                }
                
            })


        }
        
        
    }
    
}
