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
    @IBOutlet var newExpandedCircleView: UIView!
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
    
    var createCircleName: String = ""
    var createIsPrivateKey: Bool = false
    var locationManager: CLLocationManager?
    var selectedAnnotationView: CircleAnnotationView?
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
//    var openDrawerDistance: CGFloat = -220.0
//    let hiddenDrawerDistance: CGFloat = -220.0 //-330
    let iphoneXFamilyOpenDrawerAdj:CGFloat = 48
    lazy var iphoneXFamilyExpandedCircleInnerContentAdj: CGFloat = -self.safeAreaInsets.bottom - 50//10
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
        configMapbox()

    }
    
    fileprivate func configMapbox() {
        mapBoxView.styleURL = MGLStyle.darkStyleURL
        mapBoxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapBoxView.tintColor = .lightGray
        mapBoxView.logoView.isHidden = true
        mapBoxView.attributionButton.isHidden = true
        
        self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
                                                         longitude: -122.389246),
                                  zoomLevel: 14, animated: false)
    }
    
    fileprivate func adjustScreenforXFamily() {
        if UIScreen.isPhoneXfamily {
            createCircleYConstraint.constant = -5
            insideExpandedCircleViewYConstraint.constant = -40
            self.layoutIfNeeded()
            
        }
    }
    
    fileprivate func locationServicesSetup() {
        //TODO: COntrol for locationmanager absense
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.startUpdatingLocation()
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access to location services")
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

                //print("Access")
            @unknown default:
                print("Location services test resulted something unknown")
            }
        } else {
            //print("Location services are not enabled")
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
    
       // Updating circle this should go somewhere else.
//        CircleAnnotationManagement.sharedInstance.updateCircleSettings(circleId: self.currentlyExpandedCircleId, isprivate: false, name: "OUTRO NOME") { (err) in
//            if let err = err {
//                fatalError(err.localizedDescription)
//            }
//            //print("updated successfully")
//
//
//        }
        
    }
    
    
    override func activate() {
            KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.MapView.rawValue
            KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
        
            mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
            //work on the map before showing
            backToTheMapReset()
            self.alpha = 0
            self.isHidden = false
            self.talkbox?.delegate = self
            UIView.animate(withDuration: 0.4, animations: {
                self.mainViewController?.jungChatLogger.backgroundColor = UIColor.clear
                self.alpha = 1

            }) { (completed) in
                CircleAnnotationManagement.sharedInstance.retrieveCirclesCloseToPlayer() {
                    // the observer will fire, see: plotAnnotations()
                    UIView.animate(withDuration: 0.4) {
                        self.mapBoxView.alpha = 1
                    }
                }

            }
            
            self.talk()
    }
    
    override func deactivate() {
        self.mainViewController?.jungChatLogger.resetJungChat()
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
        self.fadeOutView()
    }
    
    func clearJungChatLog() {
        self.mainViewController?.jungChatLogger.resetJungChat()
        self.mainViewController?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }
    
    func describeCircle(set: CircleAnnotationSet) {
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
        if creationMode {
            createCircleName = ""
            circleNameTextField.text = "[tap to name it]"
            adaptLineToTextSize(circleNameTextField)
            
            explainerCircleCreation()
        } else {
            explainerCircleExploration(set: set)
        }

    }

    
    
    override func leftOptionClicked() {
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
        // USER CANCELLED CREATION
        if self.creationMode {
            guard let annotationView = selectedAnnotationView else {fatalError("LIXO!!!!")}
            UIView.animate(withDuration: 0.4, animations: {
                 self.expandedCircleViews.alpha = 0
            }) { (completed) in
                if let annotation = annotationView.annotation {
                    self.mapBoxView.removeAnnotation(annotation)
                    self.selectedAnnotationView = nil
                }
                DispatchQueue.main.async {
                    self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
                }
                
                self.backToTheMapReset()
                
                self.creationMode = false
            }
        } else {
            // USER HITS BACK TO THE MAP
            guard let selectedAnnotationView = selectedAnnotationView else {fatalError("LIXO!!!!")}
            self.deActivateOnDeselection(selectedAnnotationView) {
                self.mapBoxView.deselectAnnotation(selectedAnnotationView.annotation, animated: false)
                self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
            }
        }
    }
    
    //SAVE
    override func rightOptionClicked() {
        self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
        if creationMode {
            createNewCircle() { (circleAnnotationSet) in
                guard let annotationSet = circleAnnotationSet else {
                    self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
                    self.explainerNameCircleBeforeSavingIt()
                    return
                }
                
                self.explainerCircleSavedSuccessfully()
                
                guard let selectedAnnotationView = self.selectedAnnotationView else {return}
                
                //gets the payload with the circle details
                selectedAnnotationView.circleDetails = annotationSet
      
                self.deActivateOnDeselection(selectedAnnotationView) {
                    self.mapBoxView.deselectAnnotation(selectedAnnotationView.annotation, animated: false)
                    self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
                }
                
                self.creationMode = false
            }

        } else {
                let actions: [KindActionType] = [KindActionType.deactivate,KindActionType.activate]
                let actionViews: [ActionViewName] = [ActionViewName.MapView, ActionViewName.GameBoard]
                self.talkbox?.displayRoutine(routine: self.talkbox?.routineWithNoText(action: actions, actionView: actionViews, options: nil))
        }

    }
}

extension MapActionTriggerView: MGLMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }

    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {

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
        
        guard let annotationView = annotationView as? CircleAnnotationView else {fatalError()}
        guard let coordinates = annotationView.circleDetails?.location else {fatalError()}
      
        self.selectedAnnotationView = annotationView
        
        //Extract annotation details here.
        guard let circleDetails = annotationView.circleDetails else {fatalError("annotation carries no details to be plotted")}
        
        labelCircleName.attributedText = formatLabelTextWithLineSpacing(text: circleDetails.circlePlotName)
        enterCircleButton.alpha = circleDetails.isPrivate ? 1:0
        
        self.mapBoxView.setCenter(coordinates, zoomLevel: MAXZOOMLEVEL,animated: true)
        //This takes care of all the animations.
        activateOnSelection(annotationView) { (set) in
            self.describeCircle(set: set)
        }

    }
    

    func mapView(_ mapView: MGLMapView, didDeselect annotationView: MGLAnnotationView) {
//        guard let annotationView = annotationView as? CircleAnnotationView else {return}
//        deActivateOnDeselection(annotationView,completion: nil)
    }
    
    
    //MAP IS DRAGGED.
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        self.existentExpandedCircleView.alpha = 0
        self.existentExpandedCircleView.isUserInteractionEnabled = false
        // If there is an active annotation and this annotation is REALLY open.
        if let annotationView = selectedAnnotationView, !annotationView.transform.isIdentity {
            
            deActivateOnDeselection(annotationView) {
                annotationView.setSelected(false, animated: false)
            }
            
            //Remove circle if added on long press.
            if creationMode {
                if let annotation = annotationView.annotation {
                    self.mapBoxView.removeAnnotation(annotation)
                }
                self.creationMode = false
            }
            
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
            
        }
    }
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    

    fileprivate func activateOnSelection(_ annotationView: CircleAnnotationView, completion: ((_ circleAnnotationSet: CircleAnnotationSet)->())?) {
        backToTheMapReset()
        UIView.animate(withDuration: 1, animations: {
            //scaling
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 0
            //**
            annotationView.transform = CGAffineTransform(scaleX: self.MAXSCIRCLESCALE, y: self.MAXSCIRCLESCALE)
            annotationView.alpha = 0.32
            
        }) { (Completed) in
            self.prepareViewsForDetailingCircle(annotationView: annotationView) {
                if let set = annotationView.circleDetails {
                    completion?(set)
                }
            }
        }
    }

    fileprivate func prepareViewsForDetailingCircle(annotationView: CircleAnnotationView, completion: (()->())?) {
        
        if !annotationView.transform.isIdentity {
            if annotationView.transform.a == self.MAXSCIRCLESCALE {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.expandedCircleViews.isUserInteractionEnabled = true
                    self.expandedCircleViews.alpha = 1
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.toggleInnerCircleView(newCircle: self.creationMode)
                    })
                    completion?()
                })
                
            }            
        } else {
            // If it did cut off, cancel interaction.
            //annotationView.setSelected(false, animated: false)
        }
    }
    
    
    private func toggleInnerCircleView(newCircle: Bool) {
        if !newCircle {
            self.existentExpandedCircleView.isUserInteractionEnabled = true
            self.existentExpandedCircleView.alpha = 1
        } else {
            self.newExpandedCircleView.alpha = 1
            self.newExpandedCircleView.isUserInteractionEnabled = true
        }
        
    }
    
    func resetInnerCircleViews() {
        self.existentExpandedCircleView.isUserInteractionEnabled = false
        self.existentExpandedCircleView.alpha = 0
        self.newExpandedCircleView.alpha = 0
        self.newExpandedCircleView.isUserInteractionEnabled = false
    }
    
    
    fileprivate func backToTheMapReset() {
        self.clearJungChatLog()
        self.expandedCircleViews.isUserInteractionEnabled = false
        self.resetInnerCircleViews()
    }
    
    fileprivate func deActivateOnDeselection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        //self.insideExpandedCircleView.alpha = 0
        print("here")
        backToTheMapReset()
        
        UIView.animate(withDuration: 1, animations: {
            self.expandedCircleViews.alpha = 0
        }) { (completed) in
    
            UIView.animate(withDuration: 1, animations: {
                self.mainViewController?.hudView.hudCenterDisplay.alpha = 1
                annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                annotationView.alpha = 0.9
                annotationView.button.alpha = 0
            })
            
            self.selectedAnnotationView = nil

            if let completion = completion {
                completion()
            }
        }
        
        
    }
    
    func showInnerCircleControls() {
        
    }
    
}
