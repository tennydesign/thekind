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
import Lottie
import RxCocoa
import RxSwift

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
    private var bag = DisposeBag()
    
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

    }
    
    override func layoutSubviews() {

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
        //activatePlotMovingAnnotationCallBacks()
        //using Rx
        activateCirclePlotterRxObserver()
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
       // mapBoxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
    
    
    
    
    override func activate() {
        Bundle.main.loadNibNamed("MapView", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        mainView.alpha = 0

        circleNameTextField.delegate = self
        mapBoxView.delegate = self
        locationManager.delegate = self
        
        self.talkBox2?.delegate = self
        
        photoStripCollectionView.dataSource = self
        photoStripCollectionView.delegate = self
        
        photoStripCollectionView?.register(UINib(nibName: "PhotoStripCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoStripCollectionViewCell")
        
        //screen adjustments.
        adjustScreenforXFamily()

        let overlay = self.createOverlay(frame: self.frame,
                                         xOffset: self.frame.midX,
                                         yOffset: self.frame.midY,
                                         radius: 90.0)
        self.overlayExpandedCircleViews.addSubview(overlay)
        self.overlayExpandedCircleViews.sendSubviewToBack(overlay)
        
        gesturesAndActionsSetup()
        
        locationServicesSetup()
        
        activateCallBacks()
        
        configMapbox()
        
        KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] = ViewForActionEnum.mapView.rawValue
        KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)

        self.alpha = 0
        self.isHidden = false
        
        self.mainViewController2?.listCircleView.delegate = self
        self.mainViewController2?.jungChatLogger.backgroundColor = UIColor.clear
        self.mainViewController2?.jungChatLogger.bottomGradient.fadeIn(0.3)

        
        self.logCurrentLandingView(tag: ViewForActionEnum.mapView.rawValue)
        self.fadeInView() //fades in the view, not the map yet.
        
        prepareMapViewsForPresentation() { viewsAreReady in
            self.tryToFetchUserLocation() { coordinates in
                guard let coordinates = coordinates else {return}
                self.plotAnnotations(coordinates: coordinates)
            }
        }
    }
    
    
    fileprivate func tryToFetchUserLocation(completion: @escaping ((CLLocationCoordinate2D?)->())) {
        var latitude: CLLocationDegrees?
        var longitude: CLLocationDegrees?
        
        var hasCoordinates: Bool {
            get {
                return ((latitude != nil) && (longitude != nil))
            }
        }
        
        var attempts: Int = 0
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            attempts+=1
            
            print("attempt \(attempts)")
            latitude = self.locationManager.location?.coordinate.latitude
            longitude = self.locationManager.location?.coordinate.longitude
            
            if attempts == 5 && !hasCoordinates {
                timer.invalidate()
                print("We tried 5 times to grab location and failed 5 times")
                self.cantFindLocationExplainer()
                attempts = 0
                completion(nil)
                return
            }
            //if ((latitude != nil) && (longitude != nil)) {
            if hasCoordinates {
                completion(CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                print("Got location at attempt \(attempts)")
                timer.invalidate()
                attempts = 0
            }
        }
    }
    
    fileprivate func plotAnnotations(coordinates: CLLocationCoordinate2D) {
        //present map
        let group = DispatchGroup()
        group.enter()
        self.plotCirclesUserIsAdmin() {
            group.leave()
            group.enter()
            self.plotCirclesAroundUser(latitude: coordinates.latitude, longitude: coordinates.longitude, completion: { (plotted) in
                print("1 executed geoFireTestingQuery")
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            self.showMap()
        }
    }
    
    func showMap() {
        self.mapBoxView.fadeIn(0.4) {
            self.talk()
        }
        
    }
    
    func plotCirclesAroundUser(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: ((Bool)->())?) {
        CircleAnnotationManagement.sharedInstance.getCirclesWithinRadiusObserver(latitude: latitude, longitude: longitude, radius: 0.6, completion: {
            print("3 executed geoFireTestingQuery")
            completion?(true)
        })
    }
    

    func plotCirclesUserIsAdmin(completion: (()->())?) {
        guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
        CircleAnnotationManagement.sharedInstance.retrieveAllCirclesUserIsAdmin() { (sets) in
            if let sets = sets {
                sets.forEach({ (set) in
                    let pointAnnotation:MGLPointAnnotation = KindPointAnnotation(circleAnnotationSet: set)
                    let isAlreadyPlotted = self.mapBoxView.annotations?.contains{$0.title == set.circleId || $0.title == uid } ?? false
                    if !isAlreadyPlotted {
                        pointAnnotation.title = set.circleId
                        self.mapBoxView.addAnnotation(pointAnnotation)
                    }
                })
                completion?()
            }
        }
    }
    
    func prepareMapViewsForPresentation(completion: ((Bool)->())?) {
        mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        mapBoxView.isUserInteractionEnabled = true
        overlayExpandedCircleViews.isUserInteractionEnabled = false
        mainViewController2?.bottomCurtainView.isUserInteractionEnabled = false
        borderProtectionLeft.isUserInteractionEnabled = true
        borderProtectionRight.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5, animations: {
            self.mainViewController2?.hudView.hudCenterDisplay.alpha = 1
            self.mainViewController2?.hudView.listViewStack.alpha = 1
            self.overlayExpandedCircleViews.alpha = 0
        }) { (completed) in
            completion?(true)
        }
        
    }
    

    
    // Plotters. Show and hide circles. using Rx
    func activateCirclePlotterRxObserver() {
        CircleAnnotationManagement.sharedInstance.circlePlotterObserver.share()
            .subscribe(onNext: { [weak self] set in
                self?.circlePlotterOverMap(set: set, view: self)
            })
            .disposed(by: bag)
    }
    
    private func circlePlotterOverMap(set: CircleAnnotationSet?, view: MapActionTriggerView?) {
        guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
        if set != nil {
            let isAlreadyPlotted = view?.mapBoxView.annotations?.contains{$0.title == set!.circleId || $0.title == uid } ?? false
            if isAlreadyPlotted {
                //unlpot
                if let annotation = (view?.mapBoxView.annotations?.filter{$0.title == set!.circleId}.first) {
                    if set!.admin != uid { // user does not own it
                        self.mapBoxView.removeAnnotation(annotation)
                    }
                }
            } else {
                //plot
                let pointAnnotation:MGLPointAnnotation = KindPointAnnotation(circleAnnotationSet: set!)
                pointAnnotation.title = set!.circleId
                view?.mapBoxView.addAnnotation(pointAnnotation)
            }
        }
    }
    
    override func deactivate() {
        self.fadeOut(0.5) {
            self.deActivateOnDeselection(completion: nil)
            CircleAnnotationManagement.sharedInstance.removeAllGeoFireObservers()
            self.locationManager.stopUpdatingLocation()
            self.mainView.removeFromSuperview()
        }
    }
    
    func clearJungChatLog() {
        //self.mainViewController?.jungChatLogger.resetJungChat()
        //self.talkbox?.clearJungChat()
        self.mainViewController2?.jungChatLogger.hideOptionLabels(true, completion: nil)
    }
    
    ///JUNG ACTIONS
    
    override func talk() {
        //Jung should talk here
        mapExplainer()
        
    }

    
    override func leftOptionClicked() {
        //self.clearJungChatLog()
        self.deActivateOnDeselection(completion: nil)
        
    }
    
    //HERE: MAKE SAVE CIRCLE SAVE LIST OF USERS TOO
    override func rightOptionClicked() {
        //self.clearJungChatLog()
         if self.circleIsInEditMode { //save circle
            self.saveCircle()
         } else { // enter circle
            self.explainerNavigator(destination: .GameBoard)
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
            self.doneExplainer()
            
        }
    }
    
     //Btns in UserInCirclePhotoStripCellProtocol
    @IBAction func deleteBtnClicked(_ sender: UIButton) {
        guard let set = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails else {return}
        let detail = "Removing a circle will make it disappear from the map. "
        let message = "Remove \(set.circlePlotName ?? "circle")?"
        setupConfirmationBtn(withMessage: message, detail: detail, action: .removeCircle)

    }
    
    
    
    @IBAction func enterCircleTouched(_ sender: UIButton) {
        
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
        mainViewController2?.searchView.activate()
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
                //self.clearJungChatLog()
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


extension MapActionTriggerView: ConfirmationViewProtocol {
    
    func setupConfirmationBtn(withMessage: String, detail: String?, action: ConfirmButtonActions) {
        mainViewController2?.confirmationView.delegate = self
        mainViewController2?.confirmationView.actionEnum = action
        mainViewController2?.confirmationView.confirmAction.setTitle(withMessage, for: .normal)
        mainViewController2?.confirmationView.detailsLabel.text = detail ?? ""
        mainViewController2?.confirmationView.activate()
    }
    
    func userConfirmed() {
        guard let action = mainViewController2?.confirmationView.actionEnum else {return}
        switch action {
        case .removeUserFromCircle:
            guard let user = selectedKindUser, let id = user.uid else {return}
            CircleAnnotationManagement.sharedInstance.removeUserFromCircle(userId: id) {
                print("user removed from array in Firebase")
                self.mainViewController2?.confirmationView.deactivate()
            }
        case .transferCircleToUser:
            print("hello makeUserAdminForCircleBtn")
            guard let user = selectedKindUser, let id = user.uid else {return}
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.admin = id
            saveCircleSetIfNotTemporary() {
                self.mainViewController2?.confirmationView.deactivate()
            }
            
        case .removeCircle:
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.deleted = true
            saveCircleSetIfNotTemporary() {
                self.mainViewController2?.confirmationView.deactivate()
            }
        case .makeCircleStealth:
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.stealthMode = self.circleIsStealthMode
            saveCircleSetIfNotTemporary() {
                self.mainViewController2?.confirmationView.deactivate()
            }
        }
        
        
    }
    
    func userCancelled() {
        mainViewController2?.confirmationView.deactivate()
    }
    
    
}
