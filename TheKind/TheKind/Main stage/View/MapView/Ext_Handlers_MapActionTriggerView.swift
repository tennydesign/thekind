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
        if (!createCircleName.isEmpty) && !(createCircleName == "[tap to name it]") {
            CircleAnnotationManagement.sharedInstance.saveCircle(name: createCircleName, isPrivate: circleIsInviteOnly, users: [], latitude: latitude, longitude: longitude) { (circleAnnotationSet, err) in
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
            
            //SETUP COORDINATES
            latitude = newCoordinates.latitude
            longitude = newCoordinates.longitude
 
            let point = KindPointAnnotation(circleAnnotationSet: CircleAnnotationSet(location: newCoordinates, circlePlotName: "", isPrivate: false, circleId: "", admin: "", users: [""]))
            self.mapBoxView.addAnnotation(point)
            
            self.mapBoxView.selectAnnotation(point, animated: true)
            
        }
    }
    
    @objc func handleTapOnLocker(gestureRecognizer: UITapGestureRecognizer) {
        togglePrivateIndicator()
    }
    
    func togglePrivateIndicator() {
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
        loadPhotoStrip(isAdmin: true)
        viewSkatingX(lockTopImage, left: false, -20, reverse: false)
    }
    
    func loadPhotoStrip(isAdmin: Bool) {
        guard let set = selectedAnnotationView?.circleDetails else {fatalError("no set")}
        CircleAnnotationManagement.sharedInstance.loadCircleUsersProfile(set: set) { (kindUsers) in
            if let users = kindUsers {
                self.usersInCircle = users
                self.photoStripCollectionView.reloadData()
            }
            self.presentPhotoStripControl(isAdmin)
        }

    }
    
    func hidePhotoStrip() {
        UIView.animate(withDuration: 0.4) {
            self.photoStripView.alpha = 0
            self.addUserBtn.alpha = 0
        }
    }
    
    fileprivate func presentPhotoStripControl(_ isAdmin: Bool) {
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
    
//    func updateUsersInCircle(set: CircleAnnotationSet) {
//        CircleAnnotationManagement.sharedInstance.loadCircleUsersPhotoUrls(set: set) { (urls) in
//            urls?.forEach({ (url) in
//                let imageView: UIImageView = UIImageView()
//                imageView.loadImageUsingCacheWithUrlString(urlString: url.absoluteString)
//                self.usersInCircleImageViews.append(imageView)
//            })
//
//            self.photoStripCollectionView.reloadData()
//        }
//    }
    
}

