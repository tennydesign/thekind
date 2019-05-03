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
    
    func isTemporaryCircleAnnotation(annotation: CircleAnnotationView?) -> Bool {
        return CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView != nil &&  CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.circleId == nil
    }
    
    func adaptLineToTextSize(_ textField: UITextField, lineWidth: NSLayoutConstraint) {
        let textBoundingSize = textField.frame.size
        guard let text = textField.text else {return}
        let frameForText = estimateFrameFromText(text, bounding: textBoundingSize, fontSize: textField.font!.pointSize, fontName: textField.font!.fontName)// UIFont.systemFont(ofSize: 16).fontName)//SECONDARYFONT)
        
        lineWidth.constant = frameForText.width
        UIView.animate(withDuration: 1) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        guard let circleName = textField.text, !(circleName.trimmingCharacters(in: .whitespaces).isEmpty) else {return}
        circlePlotName = circleName
        adaptLineToTextSize(textField, lineWidth: newCirclelineWidthConstraint)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
         textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func handleLongPressGesture(gestureRecognizer:UILongPressGestureRecognizer) {

        isCircleEditMode = true
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
            
            let set = CircleAnnotationSet(location: location, circlePlotName: circlePlotName, isPrivate: circleIsPrivate, circleId: nil, admin: uid, users: users, dateCreated: dateNow)
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
        circleIsPrivate = false
        hidePhotoStrip()
        viewSkatingX(lockTopImage, left: true, reverse: true)
    }
    
    func closeLock() {
        circleIsPrivate = true
        loadUserPhotoStrip()
        viewSkatingX(lockTopImage, left: false, -20, reverse: false)
    }
    
    func loadUserPhotoStrip() {
        if !isCircleEditMode {
            CircleAnnotationManagement.sharedInstance.loadCircleUsersProfile() { (kindUsers) in
                if let users = kindUsers {
                    self.usersInCircle = users
                    self.photoStripCollectionView.reloadData()
                }
                self.showPhotoStrip(self.userIsAdmin) // always true
            }
        } else {
            self.usersInCircle = []
            self.photoStripCollectionView.reloadData()
            self.showPhotoStrip(userIsAdmin)
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

