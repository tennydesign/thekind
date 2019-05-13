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
    
    
    @objc func textFieldDidChange(textField: UITextField){
        guard let circleName = textField.text, !(circleName.trimmingCharacters(in: .whitespaces).isEmpty) else {return}
        circlePlotName = circleName
        adaptLineToTextSize(textField, lineWidthConstraint: newCirclelineWidthConstraint, view: self, animated: true, completion: nil)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        adaptLineToTextSize(textField, lineWidthConstraint: newCirclelineWidthConstraint, view: self, animated: true, completion: nil)
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.circlePlotName = self.circlePlotName
        CircleAnnotationManagement.sharedInstance.updateCircleSettings { (set, err) in
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails = set
        }
        
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
            
            // UI prepare.
            circleNameTextField.attributedText = formatLabelTextWithLineSpacing(text: "Enter name")
            self.userIsAdmin = true
            self.circleIsInEditMode = true

            let location = CLLocationCoordinate2D(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
            
            guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
            
            circleIsPrivate = false
            
            let users:[String] = [uid] // initiates with the creator
            
            let set = CircleAnnotationSet(location: location, circlePlotName: "", isPrivate: circleIsPrivate, circleId: nil, admin: uid, users: users, dateCreated: dateNow)
            let point = KindPointAnnotation(circleAnnotationSet: set)
            point.title = uid
            
            
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
    
    func toggleEditMode(on: Bool) {
        if on {
            lockerView.isUserInteractionEnabled = true
            circleNameTextFieldView.isUserInteractionEnabled = true
            lineUnderTexboxView.alpha = 1
            adaptLineToTextSize(circleNameTextField, lineWidthConstraint: newCirclelineWidthConstraint, view: self, animated: true) {
            }
        } else {
            lockerView.isUserInteractionEnabled = false
            circleNameTextFieldView.isUserInteractionEnabled = false
            lineUnderTexboxView.alpha = 0
        }
    }
 
    func openLock() {
        circleIsPrivate = false
        togglePrivateOrPublic()
    }
    
    func closeLock() {
        circleIsPrivate = true
        togglePrivateOrPublic()
    }
    
    func togglePrivateOrPublic() {
        CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.isPrivate = self.circleIsPrivate
        CircleAnnotationManagement.sharedInstance.updateCircleSettings { (set, err) in
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails = set
            
            if self.circleIsPrivate {
                viewSkatingX(self.lockTopImage, left: false, -20, reverse: false)
                self.fadeInPhotoStrip()
            } else {
                viewSkatingX(self.lockTopImage, left: true, reverse: true)
                self.fadeOutPhotoStrip()
            }
        }
    }
    
    func fadeOutPhotoStrip() {
        UIView.animate(withDuration: 0.4, animations: {
            self.photoStripView.alpha = 0
        }) { (completed) in
            self.photoStripView.isHidden = true
        }
    }

    //also opens space for the + button when admin
    fileprivate func fadeInPhotoStrip() {
        toggleAddUserButton(on: userIsAdmin)
        photoStripView.isHidden = false
          UIView.animate(withDuration: 0.4, animations: {
                self.photoStripView.alpha = 1
          }) { (completed) in
           
        }
    }
    
    
    func toggleAddUserButton(on: Bool) {
        if on {
            photoStripLeadingConstraint.constant = 50
            UIView.animate(withDuration: 0.4) {
                self.addUserBtn.alpha = 1
                self.photoStripView.layoutIfNeeded()
            }
        } else {
            photoStripLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.4) {
                self.addUserBtn.alpha = 0
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

// PHOTOSTRIP COLLECTIONVIEW
extension MapActionTriggerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UserInCirclePhotoStripCellProtocol {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersInCircle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoStripCollectionViewCell", for: indexPath) as! PhotoStripCollectionViewCell
        
        
        if let imageUrl = usersInCircle[indexPath.row].photoURL {
            cell.userPhotoImageView.loadImageUsingCacheWithUrlString(urlString:imageUrl)
        }
        cell.user = usersInCircle[indexPath.row]
        cell.userNameLabel.text = usersInCircle[indexPath.row].name
        cell.photoArc.tintColor = UIColor.white
        cell.delegate = self
        
        if let adminId = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.admin {
            if usersInCircle[indexPath.row].uid == adminId {
                cell.photoArc.tintColor = UIColor(r: 255, g: 45, b: 85).withAlphaComponent(0.7)
            }
            
            // Selected cell.
            if let selectedRow = selectedPhotoStripCellIndexPath {
                if indexPath.row == selectedRow {
                    cell.adminControls.alpha = checkIfIsAdmin(adminId) ? 1 : 0
                    selectedKindUser = usersInCircle[indexPath.row]
                }
            }
                
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 59, height: 130)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        self.selectedPhotoStripCellIndexPath = indexPath.row
        collectionView.reloadData()
        
    }
    
    
    //Btns in UserInCirclePhotoStripCellProtocol
    func deleteUserFromCircleBtn(userId:String) {
        mainViewController?.confirmationView.delegate = self
        mainViewController?.confirmationView.actionEnum = .removeUserFromCircle
        guard let user = selectedKindUser, let name = user.name else {return}
        mainViewController?.confirmationView.confirmAction.setTitle("Remove \(name)", for: .normal)
        mainViewController?.confirmationView.activate()

    }
    

    
    func makeUserAdminForCircleBtn(userId:String) {
        mainViewController?.confirmationView.delegate = self
        mainViewController?.confirmationView.actionEnum = .transferCircleToUser
        guard let user = selectedKindUser, let name = user.name else {return}
        mainViewController?.confirmationView.confirmAction.setTitle("Transfer circle to \(name) ", for: .normal)
        mainViewController?.confirmationView.activate()
    }
    
}

extension MapActionTriggerView: ConfirmationViewProtocol {
    
    func userConfirmed() {
        guard let action = mainViewController?.confirmationView.actionEnum else {return}
        switch action {
            case .removeUserFromCircle:
                guard let user = selectedKindUser, let id = user.uid else {return}
                CircleAnnotationManagement.sharedInstance.removeUserFromCircle(userId: id) {
                    print("user removed from array in Firebase")
                    self.mainViewController?.confirmationView.deactivate()
                }
            case .transferCircleToUser:
                print("hello makeUserAdminForCircleBtn")
                 guard let user = selectedKindUser, let id = user.uid else {return}
                CircleAnnotationManagement.sharedInstance.changeCircleAdminTo(userId: id) {
                    self.mainViewController?.confirmationView.deactivate()
                }
            
        }
        

    }
    
    func userCancelled() {
        mainViewController?.confirmationView.deactivate()
    }
    
    
}
