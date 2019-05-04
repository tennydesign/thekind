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
    
    func isSelectedTemporaryCircleAnnotation() -> Bool {
        guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return false}
        return CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView != nil &&  CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.annotation?.title == uid
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
        CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.circlePlotName = self.circlePlotName
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        adaptLineToTextSize(textField, lineWidth: newCirclelineWidthConstraint)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func handleLongPressGesture(gestureRecognizer:UILongPressGestureRecognizer) {

        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchpoint = gestureRecognizer.location(in: mapBoxView)
            let newCoordinates = mapBoxView.convert(touchpoint, toCoordinateFrom: mapBoxView)
            
            let dateformat = DateFormatter()
            dateformat.dateFormat = "MM-dd hh:mm a"
            let dateNow = dateformat.string(from: Date())
            adaptLineToTextSize(circleNameTextField, lineWidth: newCirclelineWidthConstraint)
            
            // UI prepare. 
            showEditInnerCircleViews()
            circleNameTextField.text = "Type a name."
            self.userIsAdmin = true
            self.usersInCircle = []
            //HERE- SOMETIMES CIRCLE SHOWS NO INFO RIGHT AFTER CREATION - INTERMITENT.
            
            let location = CLLocationCoordinate2D(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
            
            guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
            let users:[String] = [uid] // initiates with the creator
            
            let set = CircleAnnotationSet(location: location, circlePlotName: "", isPrivate: false, circleId: nil, admin: uid, users: users, dateCreated: dateNow)
            let point = KindPointAnnotation(circleAnnotationSet: set)
            point.title = uid
            openLock()
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
        circleIsPrivate = false // didset triggers self.togglePrivateOrPublic()
        viewSkatingX(lockTopImage, left: true, reverse: true)
    }
    
    func closeLock() {
        circleIsPrivate = true // didset triggers self.togglePrivateOrPublic()
        viewSkatingX(lockTopImage, left: false, -20, reverse: false)
    }
    
    func togglePrivateOrPublic() {
        CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.isPrivate = circleIsPrivate
        if circleIsPrivate {
            let keyImage = UIImage(named: "privatekey")?.withRenderingMode(.alwaysOriginal)
            self.enterCircleButton.setBackgroundImage(keyImage, for: .normal)
            fadeInPhotoStrip()
        } else {
            fadeOutPhotoStrip()
            let enterImage = UIImage(named: "newEye")
            self.enterCircleButton.setBackgroundImage(enterImage, for: .normal)
        }
    }
    
    func fadeOutPhotoStrip() {
        UIView.animate(withDuration: 0.4, animations: {
            self.photoStripView.alpha = 0
            self.addUserBtn.alpha = 0
        }) { (completed) in
            self.photoStripView.isHidden = true
        }
    }

    //also opens space for the + button when admin
    fileprivate func fadeInPhotoStrip() {
        photoStripView.isHidden = false
        if self.userIsAdmin{
            photoStripLeadingConstraint.constant = 50
            UIView.animate(withDuration: 0.4) {
                self.photoStripView.alpha = 1
                self.addUserBtn.alpha = 1
                self.photoStripView.layoutIfNeeded()
            }
        } else {
            photoStripLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.4) {
                self.addUserBtn.alpha = 0
                self.photoStripView.alpha = 1
                self.photoStripView.layoutIfNeeded()
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

