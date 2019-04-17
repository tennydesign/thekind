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
class MapActionTriggerView: KindActionTriggerView, UIGestureRecognizerDelegate {

    @IBOutlet var photoStripView: UIView!
    @IBOutlet var photoStripCollectionView: UICollectionView!
    @IBOutlet var photoStripLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var photoStripViewTopConstraint: NSLayoutConstraint!
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
    @IBOutlet var addUserBtn: UIButton!
    
    @IBOutlet var mapBoxView: MGLMapView! {
        didSet {
            mapBoxView.maximumZoomLevel = MAXZOOMLEVEL
        }
    }
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var lineWidthConstraint: NSLayoutConstraint!
    @IBOutlet var createCircleYConstraint: NSLayoutConstraint!
    
    var createCircleName: String = ""
    var circleIsInviteOnly: Bool = false
    var locationManager: CLLocationManager?
    var selectedAnnotationView: CircleAnnotationView?
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    var currentlyExpandedCircleId: String = ""
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var isNewCircle: Bool = false
    var usersInCircleImageViews: [UIImageView] = []
    var longPressGesture: UIGestureRecognizer!
    
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
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
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
        //HERE

        // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        
        // make your class the delegate of the pan gesture
        panGesture.delegate = self
        
        // add the gesture to the mapView
        mapBoxView.addGestureRecognizer(panGesture)
        
        configMapbox()

    }
    
    // This is to setup didDragMap delegate.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
            photoStripViewTopConstraint.constant = 200
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
    
    }
    
    
    override func activate() {
            KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.MapView.rawValue
            KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
        
            mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
            //work on the map before showing
            toogleCircleAndMapViews(isOnMap: true)
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
        self.deselectAnnotationAndBackToMap()
        self.mainViewController?.jungChatLogger.resetJungChat()
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = true

        self.fadeOutView()

    }
    
    func clearJungChatLog() {
        self.mainViewController?.jungChatLogger.resetJungChat()
        self.mainViewController?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }
    
    func describeCircle(set: CircleAnnotationSet) {
        if isNewCircle {
            createCircleName = ""
            circleNameTextField.text = "tap to name it..."
            adaptLineToTextSize(circleNameTextField)
            
            explainerCircleCreation()
        } else {
            explainerCircleExploration(set: set)
        }

    }

    
    
    func removeCancelledAnnotation(_ annotationView: CircleAnnotationView) {
        //Remove instead of deselect.
        if let annotation = annotationView.annotation {
            self.mapBoxView.removeAnnotation(annotation)
            self.selectedAnnotationView = nil
        }
    }
    
    override func leftOptionClicked() {
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
        // USER CANCELLED CREATION
        if self.isNewCircle {
            removeAnnotationAndBackToMap()
        } else {
            // USER HITS BACK TO THE MAP
            deselectAnnotationAndBackToMap()
        }
    }

    
    //SAVE
    
    override func rightOptionClicked() {
        self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
        
        //Grab the selectedAnnotation (even on create longpress will generate a template selectedAnnotation, see longpress handle)
        guard let selectedAnnotationView = self.selectedAnnotationView else {return}
        
        if isNewCircle {
            //CREATE CIRCLE
            createNewCircle() { (circleAnnotationSet) in
                guard let annotationSet = circleAnnotationSet else {
                    self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
                    self.explainerNameCircleBeforeSavingIt()
                    return
                }
                
                //gets the payload with the circle details
                selectedAnnotationView.circleDetails = annotationSet
                
                self.resetInnerCreateCircleViewComponents()
                
                self.deselectAnnotationAndBackToMap()

                self.isNewCircle = false
            }

        } else {
            //JOIN CIRCLE
            let actions: [KindActionType] = [KindActionType.deactivate,KindActionType.activate]
            let actionViews: [ActionViewName] = [ActionViewName.MapView, ActionViewName.GameBoard]
            self.talkbox?.displayRoutine(routine: self.talkbox?.routineWithNoText(action: actions, actionView: actionViews, options: nil))
           
            //Happens behind the scenes.
            //Will delay 2 second to allow alpha into board, and then it will deselect the annotation and turn Map to normal state.
            delay(bySeconds: 2) {
                self.deactivate()
            }
        }

    }
    
    @IBAction func addUserBtnClicked(_ sender: UIButton) {
        //TODO
    }
    
}

