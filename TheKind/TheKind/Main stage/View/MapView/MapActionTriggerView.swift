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

    @IBOutlet var photoStripView: UIView!
    @IBOutlet var photoStripCollectionView: UICollectionView!
    @IBOutlet var expandedCircleViews: UIView!
    @IBOutlet var newCircleView: UIView!
    @IBOutlet var existentExpandedCircleView: UIView!
    @IBOutlet var circleNameTextField: KindTransparentTextField!
    @IBOutlet var insideExpandedCircleViewYConstraint: NSLayoutConstraint!
    @IBOutlet var labelCircleName: UILabel!
    @IBOutlet var enterCircleButton: UIButton!
    @IBOutlet var lockerView: UIView!
    @IBOutlet var lockTopImage: UIImageView!
    @IBOutlet var lockBottomImage: UIImageView!
    
    @IBOutlet var mapBoxView: MGLMapView! {
        didSet {
            mapBoxView.maximumZoomLevel = MAXZOOMLEVEL
        }
    }
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var photoStripDistanceToNameConstraint: NSLayoutConstraint!
    @IBOutlet var lineWidthConstraint: NSLayoutConstraint!
    @IBOutlet var createCircleYConstraint: NSLayoutConstraint!
    
    var locationManager: CLLocationManager?
    var selectedAnnotation: CircleAnnotationView?
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    var currentlyExpandedCircleId: String = ""
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var creationMode: Bool = false
    
    // INIT VALUES
    // HERE: Maybe add a little bit more space from top of jungchatlogger and map.
    let MAXZOOMLEVEL: Double = 18
    let FLYOVERZOOMLEVEL: Double = 14
    let MAXSCIRCLESCALE: CGFloat = 6.0
    var openDrawerDistance: CGFloat = -220.0
    let hiddenDrawerDistance: CGFloat = -220.0 //-330
    let iphoneXFamilyOpenDrawerAdj:CGFloat = 48
    let iphoneXFamilyExpandedCircleInnerContentAdj: CGFloat = 16 //10
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
        
        configMapbox()
        
        adjustScreenforXFamily()
        
        circleNameTextField.delegate = self
        mapBoxView.delegate = self
        locationManager?.delegate = self
        self.talkbox?.delegate = self
        
        circleNameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        locationManager = CLLocationManager()

        locationServicesSetup()
        //setup annotation observer
        plotAnnotations()
        
        delay(bySeconds: 1) {
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
            self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
                                                             longitude: -122.389246),
                                      zoomLevel: 14, animated: false)
        }

        adaptLineToTextSize(circleNameTextField)
        
        let tapLockerGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnLocker))
        lockerView.addGestureRecognizer(tapLockerGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        mapBoxView.addGestureRecognizer(longPressGesture)
        photoStripCollectionView?.register(UINib(nibName: "PhotoStripCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoStripCollectionViewCell")
        photoStripCollectionView.dataSource = self
        photoStripCollectionView.delegate = self
        
        

    }

    override func layoutSubviews() {
        let overlay = self.createOverlay(frame: self.frame,
                                         xOffset: self.frame.midX,
                                         yOffset: self.frame.midY,
                                         radius: 90.0)
        
        self.expandedCircleViews.addSubview(overlay)
        self.expandedCircleViews.sendSubviewToBack(overlay)
    }
    
    fileprivate func configMapbox() {
        mapBoxView.styleURL = MGLStyle.darkStyleURL
        mapBoxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapBoxView.tintColor = .lightGray
        mapBoxView.logoView.isHidden = true
        mapBoxView.attributionButton.isHidden = true
    }
    
    fileprivate func adjustScreenforXFamily() {
        if UIScreen.isPhoneXfamily {
            openDrawerDistance += iphoneXFamilyOpenDrawerAdj
            insideExpandedCircleViewYConstraint.constant = iphoneXFamilyExpandedCircleInnerContentAdj
            createCircleYConstraint.constant += iphoneXFamilyExpandedCircleInnerContentAdj
            photoStripDistanceToNameConstraint.constant += iphoneXFamilyExpandedCircleInnerContentAdj
            self.layoutIfNeeded()
            
        }
    }
    
    fileprivate func locationServicesSetup() {
        //TODO: COntrol for locationmanager absense
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.startUpdatingLocation()
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
                if let coordinate = locationManager?.location?.coordinate {
                    self.mapBoxView.setCenter(coordinate,
                                              zoomLevel: 14, animated: false)
                } else {
                    self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
                                                                     longitude: -122.389246),
                                              zoomLevel: 14, animated: false)
                }

                print("Access")
            @unknown default:
                print("Locations services resulted something unknown")
            }
        } else {
            print("Location services are not enabled")
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
            self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
                                                             longitude: -122.389246),
                                      zoomLevel: 14, animated: false)
        }
    }
    
    
    func plotAnnotations() {
        CircleAnnotationManagement.sharedInstance.circleAnnotationObserver = { [unowned self](circleAnnotationSets) in
            var pointAnnotations = [KindPointAnnotation]()
            for set in circleAnnotationSets {
                let point = KindPointAnnotation(circleAnnotationSet: set)
                pointAnnotations.append(point)
            }
            
            self.mapBoxView.addAnnotations(pointAnnotations)
        }
        
    }
    
    
    ///JUNG ACTIONS
    
    override func talk() {

        

    }
    
    @IBAction func enterCircleTouched(_ sender: UIButton) {
        CircleAnnotationManagement.sharedInstance.updateCircleSettings(circleId: self.currentlyExpandedCircleId, isprivate: false, name: "OUTRO NOME") { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            print("updated successfully")
            
            
        }
        
    }
    
    
    override func activate() {
            KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.MapView.rawValue
            KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
            
            //work on the map before showing
            clearJungChatLog()
            UIView.animate(withDuration: 0.4, animations: {
                self.mainViewController?.jungChatLogger.backgroundColor = UIColor.clear
            }) { (completed) in
                CircleAnnotationManagement.sharedInstance.retrieveCirclesCloseToPlayer() {
                    //present map after annotations are there.
                    // the observer will fire, see: plotAnnotations()
                    self.alpha = 0
                    self.isHidden = false
                    self.talkbox?.delegate = self
                    UIView.animate(withDuration: 1) {
                        self.alpha = 1
                    }
                }

            }
            
            self.talk()
    }
    
    func clearJungChatLog() {
        self.mainViewController?.jungChatLogger.resetJungChat()
        self.mainViewController?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }
    
    func describeCircle(circleID: String) {

        if creationMode {
            let txt = "You are creating a circle.-Click the locker to toggle between public and private.-If private only invited people can join.-Name the circle and hit save when you are done."
            
            let actions: [KindActionType] = [.none, .none,.none, .none]
            let actionViews: [ActionViewName] = [.none,.none,.none, .none]
            let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
            self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
        } else {
            //This info comes from the Jung API
            let dominantKind = "founder"
            let chanceScore = "high"
            let privateKey = "will"
            let txt = "This place is dominated by the \(dominantKind) kind.-You have \(chanceScore) chances of making friends here.-You \(privateKey) need a key to join this circle."
            
            let actions: [KindActionType] = [.none, .none,.none]
            let actionViews: [ActionViewName] = [.none,.none,.none]
            let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
            self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
        }

    }
    

    override func leftOptionClicked() {
        guard let annotation = selectedAnnotation else {return}
        if creationMode {
            creationMode = false
        }
        deActivateOnDeselection(annotation) {
            print("returned")
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)

        }
    }
    
    override func rightOptionClicked() {
        if creationMode {
            createNewCircle(latitude, longitude) {
                let txt = "Done."
                let actions: [KindActionType] = [.none]
                let actionViews: [ActionViewName] = [.none]
                self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, action: actions, actionView: actionViews))
                guard let annotation = self.selectedAnnotation else {return}
                self.deActivateOnDeselection(annotation) {
                    print("returned")
                    self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
                }
                self.creationMode = false
            }

        } else {
                let actions: [KindActionType] = [KindActionType.fadeOutView,KindActionType.activate]
                let actionViews: [ActionViewName] = [ActionViewName.MapView, ActionViewName.GameBoard]
                self.talkbox?.displayRoutine(routine: self.talkbox?.routineWithNoText(action: actions, actionView: actionViews, options: nil))
        }

    }
}

extension MapActionTriggerView: MGLMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }

    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        
        guard let kindAnnotation = annotation as? KindPointAnnotation else {
            return nil
        }
        
        let reuseIdentifier = UUID.init().description + "_" +  String(annotation.coordinate.longitude)
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CircleAnnotationView
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CircleAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = annotationBounds
        }
        
        if let circleDetails = kindAnnotation.circleDetails {
            annotationView?.circleDetails = circleDetails
        }
        
        return annotationView
    }
    

    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        
        guard let annotationView = annotationView as? CircleAnnotationView else {return}
        guard let coordinates = annotationView.circleDetails?.location else {return}
        self.selectedAnnotation = annotationView
        if let name = annotationView.circleDetails?.circlePlotName, !name.isEmpty {
            labelCircleName.attributedText = formatLabelTextWithLineSpacing(text: name)
        }
        
        self.mapBoxView.setCenter(coordinates, zoomLevel: MAXZOOMLEVEL,animated: true)
        //This takes care of all the animations.
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
        self.existentExpandedCircleView.alpha = 0
        self.existentExpandedCircleView.isUserInteractionEnabled = false
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
    

    fileprivate func activateOnSelection(_ annotationView: CircleAnnotationView, completion: ((_ circleId: String)->())?) {
        UIView.animate(withDuration: 1, animations: {
            //scaling
            annotationView.transform = CGAffineTransform(scaleX: self.MAXSCIRCLESCALE, y: self.MAXSCIRCLESCALE)
            annotationView.alpha = 0.32
            
        }) { (Completed) in
            self.prepareViewsForDetailingCircle(annotationView: annotationView) {
                if let circleId = annotationView.circleDetails?.circleId {
                    self.currentlyExpandedCircleId = circleId
                    completion?(circleId)
                }
            }
        }
    }

    fileprivate func prepareViewsForDetailingCircle(annotationView: CircleAnnotationView, completion: (()->())?) {
        // If full transform happened. (sometimes a bug in the map cuts off the animation)
        if !annotationView.transform.isIdentity {
            self.clearJungChatLog()
            //check if scale is 100% open otherwise won't show panels
            if annotationView.transform.a == self.MAXSCIRCLESCALE {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.expandedCircleViews.alpha = 1
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.4, animations: {
                        // show internal area only if its not a new circle being created
                        if let name = annotationView.circleDetails?.circlePlotName, !name.isEmpty {
                            self.toggleInnerCircleView(open:true, newCircle: false)
                        } else {
                            self.toggleInnerCircleView(open:true,newCircle: true)
                        }
                    })
                    completion?()
                    
                })
                
            }            
        } else {
            // If it did cut off, cancel interaction.
            annotationView.setSelected(false, animated: false)
        }
    }
    
    private func toggleInnerCircleView(open: Bool, newCircle: Bool) {
        self.expandedCircleViews.isUserInteractionEnabled = true
        if !newCircle {
            self.existentExpandedCircleView.isUserInteractionEnabled = open ? true:false
            self.existentExpandedCircleView.alpha = open ? 1:0
        } else {
            self.newCircleView.alpha = open ? 1:0
            self.newCircleView.isUserInteractionEnabled = open ? true:false
        }
        
    }
    
    
    fileprivate func deActivateOnDeselection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        //self.insideExpandedCircleView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
            annotationView.alpha = 0.9
            annotationView.button.alpha = 0
            self.clearJungChatLog()
            self.expandedCircleViews.alpha = 0
            self.expandedCircleViews.isUserInteractionEnabled = false
        }) { (completed) in
            delay(bySeconds: 0.5, closure: {
                
                //self.mainViewController?.circleDetailsHost.alpha = 0
                if let completion = completion {
                    completion()
                }

                
            })


        }
        
        
    }
    
    func showInnerCircleControls() {
        
    }
    
}
