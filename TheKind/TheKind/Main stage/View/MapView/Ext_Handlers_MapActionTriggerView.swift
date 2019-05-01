//
//  Ext_Create_MapActionTriggerView.swift
//  TheKind
//
//  Created by Tenny on 3/27/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import MapKit
import Mapbox

extension MapActionTriggerView: UITextFieldDelegate {
    
    
    func adaptLineToTextSize(_ textField: UITextField) {
        let textBoundingSize = textField.frame.size
        guard let text = textField.text else {return}
        let frameForText = estimateFrameFromText(text, bounding: textBoundingSize, fontSize: textField.font!.pointSize, fontName: textField.font!.fontName)// UIFont.systemFont(ofSize: 16).fontName)//SECONDARYFONT)
        
        lineWidthConstraint.constant = frameForText.width
        UIView.animate(withDuration: 1) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        adaptLineToTextSize(textField)
        guard let circleName = textField.text, !(circleName.trimmingCharacters(in: .whitespaces).isEmpty) else {return}
        
        createCircleName = circleName
        if selectedAnnotationView != nil {
            selectedAnnotationView?.circleDetails?.circlePlotName = createCircleName
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        adaptLineToTextSize(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func resetInnerCreateCircleViewComponents() {
        self.circleNameTextField.text = ""
        self.adaptLineToTextSize(self.circleNameTextField)
        self.openLock()
    }
    
    func createNewCircle(completion: ((CircleAnnotationSet?)->())?) {
        
        guard let recentlyCreatedSet = selectedAnnotationView?.circleDetails else {return}
        if (!createCircleName.isEmpty) && !(createCircleName == "[tap to name it]") {
            CircleAnnotationManagement.sharedInstance.saveCircle(set: recentlyCreatedSet) { (circleAnnotationSet, err) in
                if let err = err {
                    print(err)
                    return
                }
                
                completion?(circleAnnotationSet)
                //print("saved circle success")
            }
        } else {
            circleNameTextField.blink(stopAfter:5.0)

            completion?(nil)
        }
    }
    
    @objc func handleLongPressGesture(gestureRecognizer:UILongPressGestureRecognizer) {

        isNewCircle = true
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchpoint = gestureRecognizer.location(in: mapBoxView)
            let newCoordinates = mapBoxView.convert(touchpoint, toCoordinateFrom: mapBoxView)
            
            let dateformat = DateFormatter()
            dateformat.dateFormat = "MM-dd hh:mm a"
            let dateNow = dateformat.string(from: Date())

            
            //SETUP COORDINATES
            latitude = newCoordinates.latitude
            longitude = newCoordinates.longitude
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
            let users:[String] = [uid] // initiates with the creator
            
            let set = CircleAnnotationSet(location: location, circlePlotName: createCircleName, isPrivate: circleIsInviteOnly, circleId: nil, admin: uid, users: users, dateCreated: dateNow)
            let point = KindPointAnnotation(circleAnnotationSet: set)
            self.mapBoxView.addAnnotation(point)
            
            self.mapBoxView.selectAnnotation(point, animated: true)
            
        }
    }
    
    // + users not working on NEW circles.
    @objc func handleTapOnLocker(gestureRecognizer: UITapGestureRecognizer) {
        if lockTopImage.transform == .identity {
            closeLock()
        } else {
            openLock()
        }
    }
    
    
    func openLock() {
        circleIsInviteOnly = false
        hidePhotoStrip()
        viewSkatingX(lockTopImage, left: true, reverse: true)
    }
    
    func closeLock() {
        circleIsInviteOnly = true
        loadUserPhotoStrip()
        viewSkatingX(lockTopImage, left: false, -20, reverse: false)
    }
    
    func loadUserPhotoStrip() {
        guard let set = selectedAnnotationView?.circleDetails else {return}
        //
        guard let admin = set.admin else {return}
        let isAdmin = self.checkIfIsAdmin(admin)
        if !isNewCircle {
            CircleAnnotationManagement.sharedInstance.loadCircleUsersProfile(set: set) { (kindUsers) in
                if let users = kindUsers {
                    self.usersInCircle = users
                    self.photoStripCollectionView.reloadData()
                }
                self.showPhotoStrip(isAdmin) // always true
            }
        } else {
            self.usersInCircle = []
            self.photoStripCollectionView.reloadData()
            self.showPhotoStrip(isAdmin)
        }

    }
    
    func hidePhotoStrip() {
        UIView.animate(withDuration: 0.4, animations: {
            self.photoStripView.alpha = 0
            self.addUserBtn.alpha = 0
        }) { (completed) in
            self.usersInCircle = []
            self.photoStripCollectionView.reloadData()
        }
    }

    //also opens space for the + button when admin
    fileprivate func showPhotoStrip(_ isAdmin: Bool) {
        if isAdmin{
            photoStripLeadingConstraint.constant = 50
            UIView.animate(withDuration: 0.4) {
                self.photoStripView.alpha = 1
                self.addUserBtn.alpha = 1
                self.photoStripView.layoutIfNeeded()
            }
        } else {
            photoStripLeadingConstraint.constant = 0
            self.photoStripView.layoutIfNeeded()
            UIView.animate(withDuration: 0.4) {
                self.addUserBtn.alpha = 0
                self.photoStripView.alpha = 1
            }
        }
    }
    
    
    func createOverlay(frame: CGRect,
                       xOffset: CGFloat,
                       yOffset: CGFloat,
                       radius: CGFloat) -> UIView {
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        // Step 2
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset),
                    radius: radius,
                    startAngle: 0.0,
                    endAngle: 2.0 * .pi,
                    clockwise: false)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        // Step 3
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        // For Swift 4.2
        maskLayer.fillRule = .evenOdd
        // Step 4
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
    
}

extension MapActionTriggerView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return usersInCircle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoStripCollectionViewCell", for: indexPath) as! PhotoStripCollectionViewCell
        if let imageUrl = usersInCircle[indexPath.row].photoURL {
            cell.userPhotoImageView.loadImageUsingCacheWithUrlString(urlString:imageUrl)
        }
        return cell
    }
    
}

