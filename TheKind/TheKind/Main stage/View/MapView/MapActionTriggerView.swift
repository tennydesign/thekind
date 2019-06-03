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
    

    @IBOutlet var deactivationMessageLabel: UILabel!
    @IBOutlet var borderProtectionLeft: UIView!
    @IBOutlet var borderProtectionRight: UIView!
    @IBOutlet var photoStripView: UIView!
    @IBOutlet var photoStripCollectionView: UICollectionView!
    @IBOutlet var photoStripLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var photoStripViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var overlayExpandedCircleViews: UIView!
    @IBOutlet var presentExpandedCircleView: UIView!
    @IBOutlet var circleNameTextField: KindTransparentTextField!
    @IBOutlet var lineUnderTexboxView: UIView!
    @IBOutlet var deleteCircleBtn: UIButton!
    
    
    @IBOutlet var stealthModeBtn: UIButton!
    @IBOutlet var circleNameTextFieldView: UIView!
    @IBOutlet var insideExpandedCircleViewYConstraint: NSLayoutConstraint!
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
    var circleIsPrivate: Bool = false 
    var circleIsStealthMode: Bool = false
    var circleIsInEditMode: Bool = false 
    
    var userIsAdmin: Bool = false
    var locationManager = CLLocationManager()

    var usersInCircle: [KindUser] = [] {
        didSet {
            self.photoStripCollectionView.reloadData()
        }
    }
    
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var longPressGesture: UIGestureRecognizer!
    var selectedKindUser: KindUser?
    
    let MAXZOOMLEVEL: Double = 18
    let FLYOVERZOOMLEVEL: Double = 14
    let MAXSCIRCLESCALE: CGFloat = 6.0
    let iphoneXFamilyOpenDrawerAdj:CGFloat = 48
    lazy var iphoneXFamilyExpandedCircleInnerContentAdj: CGFloat = -self.safeAreaInsets.bottom - 50//10
    let annotationBounds: CGRect = CGRect(x: 0, y: 0, width: 30, height: 30)

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
        locationManager.delegate = self
        self.talkbox?.delegate = self
        photoStripCollectionView.dataSource = self
        photoStripCollectionView.delegate = self

        photoStripCollectionView?.register(UINib(nibName: "PhotoStripCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoStripCollectionViewCell")

        gesturesAndActionsSetup()

        locationServicesSetup()

        activateCallBacks()
        

        
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
    
    func gesturesAndActionsSetup() {
        circleNameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        let tapLockerGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnLocker))
        lockerView.addGestureRecognizer(tapLockerGesture)
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        mapBoxView.addGestureRecognizer(longPressGesture)
        
        // This was at LayoutSubviews
        // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        // make your class the delegate of the pan gesture
        panGesture.delegate = self
        // add the gesture to the mapView
        mapBoxView.addGestureRecognizer(panGesture)
    }
    
    func activateCallBacks() {
        //setup annotation plotter observer
        activatePlotMovingAnnotationCallBacks()
        // setupCircleInformationObserver
        activateSetChangedOnCircleCallBack()
        activateUserAddedToTemporaryCircleListCallBack()
        activateUserRemovedFromTemporaryCircleListCallBack()
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
        mapBoxView.compassView.isHidden = true
        
        self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
                                                         longitude: -122.389246),
                                  zoomLevel: 14, animated: false)
    }
    
    fileprivate func adjustScreenforXFamily() {
        if UIScreen.isPhoneXfamily {
          //  expandedCircleViewYConstraint.constant = -5
            insideExpandedCircleViewYConstraint.constant = -30
            photoStripViewTopConstraint.constant = 130
            self.layoutIfNeeded()
            
        }
    }
    
    
    
    
    
    ///JUNG ACTIONS
    
    override func talk() {
        //Jung should talk here
        mapExplainer()
        
    }
    
    
    
    
    @IBAction func enterCircleTouched(_ sender: UIButton) {
    
    }
    
    
    override func activate() {
        KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.MapView.rawValue
        KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)

        self.alpha = 0
        self.isHidden = false
        self.talkbox?.delegate = self
        self.mainViewController?.listCircleView.delegate = self
        self.mainViewController?.jungChatLogger.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.3) {
            self.mainViewController?.jungChatLogger.bottomGradient.alpha = 1
        }
        
        self.fadeInView() //fades in the view, not the map yet.

        prepareMapViewsForPresentation() {
            var latitude: CLLocationDegrees?
            var longitude: CLLocationDegrees?
            
            var attempts: Int = 0
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                attempts+=1
                print("attempt \(attempts)")
                latitude = self.locationManager.location?.coordinate.latitude
                longitude = self.locationManager.location?.coordinate.longitude
                
                if attempts == 5 {
                    timer.invalidate()
                    print("We tried 5 times to grab location and failed 5 times")
                    self.cantFindLocationExplainer()
                    attempts = 0
                }
                
                if ((latitude != nil) && (longitude != nil)) {
                    //present map
                    print("Got location at attempt \(attempts)")
                    UIView.animate(withDuration: 0.4, animations: {
                        self.mapBoxView.alpha = 1
                    }, completion: { (completed) in
                        self.talk()
                    })
                    
                    self.plotCirclesUserIsAdmin()
                    //plot circles && setup the observers
                    // Will call self.plotCircleCloseToPlayerCallback?(set)
                    
                    CircleAnnotationManagement.sharedInstance.getCirclesWithinRadiusObserver(latitude: latitude!, longitude: longitude!, radius: 0.6, completion: {
                        print("executed geoFireTestingQuery")
                    })
                    
                    timer.invalidate()
                    attempts = 0
                }
            }
        }
    
    }
    
    func plotCirclesUserIsAdmin() {
        guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
        CircleAnnotationManagement.sharedInstance.retrieveAllCirclesUserIsAdmin() { (sets) in
            sets?.forEach({ (set) in
                let pointAnnotation:MGLPointAnnotation = KindPointAnnotation(circleAnnotationSet: set)
                let isAlreadyPlotted = self.mapBoxView.annotations?.contains{$0.title == set.circleId || $0.title == uid } ?? false
                if !isAlreadyPlotted {
                    pointAnnotation.title = set.circleId
                    self.mapBoxView.addAnnotation(pointAnnotation)
                }
            })
        }
    }
    
    // Plotters. Show and hide circles.
    func activatePlotMovingAnnotationCallBacks() {
        
        CircleAnnotationManagement.sharedInstance.plotCircleCloseToPlayerCallback = { [unowned self](set) in
            guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
            let isAlreadyPlotted = self.mapBoxView.annotations?.contains{$0.title == set.circleId || $0.title == uid } ?? false
            
            if !isAlreadyPlotted {
                let pointAnnotation:MGLPointAnnotation = KindPointAnnotation(circleAnnotationSet: set)
                pointAnnotation.title = set.circleId
                self.mapBoxView.addAnnotation(pointAnnotation)
            }
        }
        
        
        CircleAnnotationManagement.sharedInstance.unPlotCircleCloseToPlayerCallback = { [unowned self](set) in
            guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
            let isAlreadyPlotted = self.mapBoxView.annotations?.contains{$0.title == set.circleId} ?? false
            if isAlreadyPlotted {
                if let annotation = (self.mapBoxView.annotations?.filter{$0.title == set.circleId}.first) {
                    if set.admin != uid { // user does not own it
                        self.mapBoxView.removeAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    override func deactivate() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }
        self.deActivateOnDeselection(completion: nil)
       // self.fadeOutView()
    }
    
    func clearJungChatLog() {
        self.mainViewController?.jungChatLogger.resetJungChat()
        self.mainViewController?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }
    

    
    override func leftOptionClicked() {
        self.clearJungChatLog()
        self.deActivateOnDeselection(completion: nil)
        
    }
    
    //HERE: MAKE SAVE CIRCLE SAVE LIST OF USERS TOO
    override func rightOptionClicked() {
        //self.clearJungChatLog()
         if self.circleIsInEditMode { //save circle
            self.saveCircle()
         } else { // enter circle
            self.explainerGoToGameBoard()
        }
    }
    

    
    func saveCircle() {
        guard let location = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.location else {return}
        
        let mapSnapShot: CrumbSnapShot = CrumbSnapShot(location: location)
        
        //Snaps a photo from the region for listing purposes.
        mapSnapShot.snapMapPhoto { (image) in
            // let imageInNoir = image.noir
            guard let uploadData = image.jpegData(compressionQuality: 0.7) else {
                fatalError("error compressing image")
            }
            
            self.saveLoadingExplainer()
            
            //Uploads it.
            CircleAnnotationManagement.sharedInstance.uploadMapSnap(mapImageData: uploadData, completion: { (url) in
                if let urlstring = url {
                    CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.locationSnapShot = urlstring
                }
                
                //Update or Save Circle
                self.updateCircleSettings()
            })
        }
    }
    
    fileprivate func updateCircleSettings() {
        CircleAnnotationManagement.sharedInstance.updateCircleSettings() { (circleAnnotationSet,completed)  in
            if completed == false {
                //print(err)
                self.explainerSaveFailed()
                return
            }
            
            guard let set = circleAnnotationSet else {
                //Save failed. Treat it here.
                self.explainerSaveFailed()
                return
            }
            
            // New Circle Only: This finds the newest created circle and gives it its official circleId
            if CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation {
                // Give right ID to temporary circle
                // This is what differentiates it from "temporary" to "persisted"
                // isSelectedTemporaryCircleAnnotation will return false from now on.
                
                guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
                guard let annotation = (self.mapBoxView.annotations?.filter{$0.title == uid}.first) as? KindPointAnnotation else {return}
                annotation.title = set.circleId
                annotation.circleDetails = set
            }
            
            
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails = set
            self.deActivateOnDeselection(completion: nil)
            
        }
    }
    
     //Btns in UserInCirclePhotoStripCellProtocol
    @IBAction func deleteBtnClicked(_ sender: UIButton) {
        guard let set = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails else {return}
        let detail = "Removing a circle will make it disappear from the map. "
        let message = "Remove \(set.circlePlotName ?? "circle")?"
        setupConfirmationBtn(withMessage: message, detail: detail, action: .removeCircle)

    }
    

    func deleteUserFromCircleBtn(userId:String) {
        guard let user = selectedKindUser, let name = user.name else {return}
        let message = "Remove \(name)"
        let detail = "Removed users can't join private circles."
        setupConfirmationBtn(withMessage: message, detail: detail, action: .removeUserFromCircle)
    }
    
    
    
    func makeUserAdminForCircleBtn(userId:String) {
        guard let user = selectedKindUser, let name = user.name else {return}
        let message = "Transfer circle to \(name) "
        let detail = "You will lose your admin access to this circle."
        setupConfirmationBtn(withMessage: message, detail: detail, action: .transferCircleToUser)
    }
    
    @IBAction func addUserBtnClicked(_ sender: UIButton) {
        print("add user clicked")
        mainViewController?.searchView.activate()
    }
 
    // CIRCLE SET OBSERVER
    func activateSetChangedOnCircleCallBack() {
        CircleAnnotationManagement.sharedInstance.setChangedOnCircleCallback = { [unowned self] set in
            self.setupUIWithSetInfo()
            CircleAnnotationManagement.sharedInstance.loadCircleUsersProfile() { (kindUsers) in
                self.usersInCircle = kindUsers ?? []
                print("reloaded")
            }

        }
    }
    
    //TODO: ACL (for real)
    // CONTROL for: Only circles you belong or are public get downloaded from FB.
    // Should be a query.
    func showAccessDeniedLabel(message: String) {
        self.deactivationMessageLabel.text = message
        self.deactivationMessageLabel.alpha = 1
        UIView.animate(withDuration: 0.4, delay: 1.2, options: .curveEaseIn, animations: {
            self.deactivationMessageLabel.alpha = 0
        }, completion: { (completed) in
            
        })
    }
    
    //THis gets called everytime there is a Set update on Firestore
    func setupUIWithSetInfo() {
        guard let set =  CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails else {return}
        
        //Checks again just in case user was already opening the circle before flag.
        if set.deleted {
            deActivateOnDeselection() {
                self.showAccessDeniedLabel(message: "Deactivated by admin.")
                self.clearJungChatLog()
            }
            return
        }
        
        if !set.circlePlotName.isEmpty {
            self.circlePlotName = set.circlePlotName
            self.circleNameTextField.attributedText = formatLabelTextWithLineSpacing(text: set.circlePlotName)
        }
        
        self.userIsAdmin = checkIfIsAdmin(set.admin)
        self.circleIsPrivate = set.isPrivate
        
        if self.userIsAdmin || self.circleIsInEditMode {
            self.toggleEditMode(on: true)
        } else {
            self.toggleEditMode(on: false)
        }
        
        if !CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation{
            self.toggleDeleteCircleButton(on: self.userIsAdmin)
        }
        
        self.toggleLock(closed: self.circleIsPrivate)
        
        
        
    }
    
    func saveCircleSetIfNotTemporary(completion: (()->())?) {
        if !CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation {
            CircleAnnotationManagement.sharedInstance.updateCircleSettings { (set, err) in
                CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails = set
                completion?()
            }
        }
    }
    
    //triggered when user is added at the SearchView FOR TEMPORARY CIRCLES only.
    func activateUserAddedToTemporaryCircleListCallBack() {
        CircleAnnotationManagement.sharedInstance.userAddedToTemporaryCircleListCallback  = { [unowned self] user in
            self.usersInCircle.append(user)
        }
    }
    
    func activateUserRemovedFromTemporaryCircleListCallBack() {
        CircleAnnotationManagement.sharedInstance.userRemovedFromTemporaryCircleListCallback  = { [unowned self] user in
            self.usersInCircle.removeAll{ $0.uid == user.uid}
        }
    }

}


