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


class MapActionTriggerView: KindActionTriggerView, UIGestureRecognizerDelegate {
    

    @IBOutlet var borderProtectionLeft: UIView!
    @IBOutlet var borderProtectionRight: UIView!
    @IBOutlet var photoStripView: UIView!
    @IBOutlet var photoStripCollectionView: UICollectionView!
    @IBOutlet var photoStripLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var photoStripViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var overlayExpandedCircleViews: UIView!
    @IBOutlet var presentExpandedCircleView: UIView!
    @IBOutlet var circleNameTextField: KindTransparentTextField!

    
    @IBOutlet var circleNameTextFieldView: UIView!
    @IBOutlet var insideExpandedCircleViewYConstraint: NSLayoutConstraint!
    @IBOutlet var labelCircleName: UILabel!
    @IBOutlet var lockerView: UIView!
    @IBOutlet var lockTopImage: UIImageView!
    @IBOutlet var lockBottomImage: UIImageView!
    @IBOutlet var addUserBtn: UIButton!
    var selectedPhotoStripCellIndexPath: Int?

    
    @IBOutlet var mapBoxView: MGLMapView! {
        didSet {
            mapBoxView.maximumZoomLevel = MAXZOOMLEVEL
        }
    }
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var newCirclelineWidthConstraint: NSLayoutConstraint!
    @IBOutlet var expandedCircleViewYConstraint: NSLayoutConstraint!
    
    var circlePlotName: String = ""
    var circleIsPrivate: Bool = false {
        didSet{
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.isPrivate = circleIsPrivate
        }
    }
    
    var circleIsInEditMode: Bool = false 
    
    var userIsAdmin: Bool = false
    var locationManager: CLLocationManager?

    var usersInCircle: [KindUser] = [] {
        didSet {
            self.photoStripCollectionView.reloadData()
        }
    }
    var selectedAnnotationView: CircleAnnotationView? {
        set {
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView = selectedAnnotationView
        }
        get {
            return CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView
        }
    }
    
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var longPressGesture: UIGestureRecognizer!
    var selectedKindUser: KindUser?
    
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
        
        //screen adjustments.
        adjustScreenforXFamily()
        
        circleNameTextField.delegate = self
        mapBoxView.delegate = self
        locationManager?.delegate = self
        self.talkbox?.delegate = self
        photoStripCollectionView.dataSource = self
        photoStripCollectionView.delegate = self
      
        circleNameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        let tapLockerGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnLocker))
        lockerView.addGestureRecognizer(tapLockerGesture)
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        mapBoxView.addGestureRecognizer(longPressGesture)
        

        photoStripCollectionView?.register(UINib(nibName: "PhotoStripCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoStripCollectionViewCell")

        
        // This was at LayoutSubviews
        // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        
        // make your class the delegate of the pan gesture
        panGesture.delegate = self
        
        // add the gesture to the mapView
        mapBoxView.addGestureRecognizer(panGesture)

        locationManager = CLLocationManager()
        locationServicesSetup()
        //setup annotation plotter observer
        plotAnnotations()
        
        
        // setupCircleInformationObserver
        updateCircleInformationOnObserver()
        userAddedToTemporaryCircleListObserver()
        userRemovedFromTemporaryCircleListObserver()
    }

    
    // prepares the overlay at expandedCircleViews (black alpha with a hole in the center)
    override func layoutSubviews() {
        let overlay = self.createOverlay(frame: self.frame,
                                         xOffset: self.frame.midX,
                                         yOffset: self.frame.midY,
                                         radius: 90.0)
        
        self.overlayExpandedCircleViews.addSubview(overlay)
        self.overlayExpandedCircleViews.sendSubviewToBack(overlay)
        
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
            expandedCircleViewYConstraint.constant = -5
            insideExpandedCircleViewYConstraint.constant = -40
            photoStripViewTopConstraint.constant = 200
            self.layoutIfNeeded()
            
        }
    }
    
    fileprivate func locationServicesSetup() {
        //TODO: COntrol for locationmanager absense here
        
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
        //Jung should talk here
    }
    
    @IBAction func enterCircleTouched(_ sender: UIButton) {
    
    }
    
    
    override func activate() {
        KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.MapView.rawValue
        KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)

        self.alpha = 0
        self.isHidden = false
        self.talkbox?.delegate = self
        self.mainViewController?.jungChatLogger.backgroundColor = UIColor.clear
        self.fadeInView() //fades in the view, not the map yet.
    
        presentMapViews() {
            //start loader
            CircleAnnotationManagement.sharedInstance.retrieveCirclesCloseToPlayer() {
                // the observer will fire, see: plotAnnotations()
                UIView.animate(withDuration: 0.4) {
                    self.mapBoxView.alpha = 1 //fades in the map.
                    //stop loader
                }
            }
        }
        

    }
    
    override func deactivate() {
        self.fadeOutView()
    }
    
    func clearJungChatLog() {
        self.mainViewController?.jungChatLogger.resetJungChat()
        self.mainViewController?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }
    
    func initializeCircleExplainer() {
        
        if circleIsInEditMode {
            //showEditInnerCircleViews() //TODO: Animate
            explainerCircleCreation()
            
        } else {
            explainerCircleExploration()
            showPresentInnerCircleViews()
        }

    }

    
    

    
    override func leftOptionClicked() {
        // THis will reset the cached Set before closing the circle (ignoring any variable changes that may have occurred in the client)
        if let set = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails {
            CircleAnnotationManagement.sharedInstance.retrieveCircleById(circleId: set.circleId) { (set) in
                self.deActivateOnDeselection(completion: nil)
                CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails = set
            }
        } else {
            self.deActivateOnDeselection(completion: nil)
        }

    }

    //HERE: MAKE SAVE CIRCLE SAVE LIST OF USERS TOO
    override func rightOptionClicked() {

        if circleIsInEditMode { //save circle
            CircleAnnotationManagement.sharedInstance.updateCircleSettings() { (circleAnnotationSet,err)  in
                if let err = err {
                    print(err)
                    return
                }
                
                guard let set = circleAnnotationSet else {
                    //Save failed. Treat it here.
                    self.explainerNameCircleBeforeSavingIt()
                    return
                }
                
                // New Circle Only: This finds the newest created circle and gives it its official circleId
                if CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation {
                    // Give right ID to temporary circle
                    // This will switch it from temporary to permanent
                    // isSelectedTemporaryCircleAnnotation will return false from now on.
                    
                    guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
                    guard let annotation = (self.mapBoxView.annotations?.filter{$0.title == uid}.first) as? KindPointAnnotation else {return}
                    annotation.title = set.circleId
                    annotation.circleDetails = set
                }
                

                CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails = set
                self.deActivateOnDeselection(completion: nil)
                
            }
        } else { // enter circle
            explainerGoToGameBoard()
        }

    }
    
    @IBAction func addUserBtnClicked(_ sender: UIButton) {
        print("add user clicked")
        mainViewController?.searchView.activate()
    }
 
    // CIRCLE SET OBSERVER
    func updateCircleInformationOnObserver() {
        CircleAnnotationManagement.sharedInstance.userListChangedOnCircleObserver = { [unowned self] set in
    
            //get unew set information and update UI
            self.userIsAdmin = self.checkIfIsAdmin(set.admin)
            self.toggleAddUserButton(on: self.userIsAdmin)
            self.toggleEditMode(on: self.userIsAdmin)
            CircleAnnotationManagement.sharedInstance.loadCircleUsersProfile() { (kindUsers) in
                self.usersInCircle = kindUsers ?? []
                print("reloaded")
            }

        }
    }
    
    //triggered when user is added at the SearchView FOR TEMPORARY CIRCLES only.
    func userAddedToTemporaryCircleListObserver() {
        CircleAnnotationManagement.sharedInstance.userAddedToTemporaryCircleListObserver  = { [unowned self] user in
            self.usersInCircle.append(user)
        }
    }
    
    func userRemovedFromTemporaryCircleListObserver() {
        CircleAnnotationManagement.sharedInstance.userRemovedFromTemporaryCircleListObserver  = { [unowned self] user in
            self.usersInCircle.removeAll{ $0.uid == user.uid}
        }
    }

}

