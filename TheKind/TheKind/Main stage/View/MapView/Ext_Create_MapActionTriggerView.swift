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
        let frameForText = estimateFrameFromText(text, bounding: textBoundingSize, fontSize: 18, fontName: textField.font!.fontName)// UIFont.systemFont(ofSize: 16).fontName)//SECONDARYFONT)
        
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
    
    func createNewCircle(completion: ((CircleAnnotationSet?)->())?) {
        if (!createCircleName.isEmpty) && !(createCircleName == "[tap to name it]") {
            CircleAnnotationManagement.sharedInstance.saveCircle(name: createCircleName, isPrivate: createIsPrivateKey, users: [""], latitude: latitude, longitude: longitude) { (circleAnnotationSet, err) in
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

        creationMode = true
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchpoint = gestureRecognizer.location(in: mapBoxView)
            let newCoordinates = mapBoxView.convert(touchpoint, toCoordinateFrom: mapBoxView)
            
            //SETUP COORDINATES
            latitude = newCoordinates.latitude
            longitude = newCoordinates.longitude
 
            let point = KindPointAnnotation(circleAnnotationSet: CircleAnnotationSet(location: newCoordinates, circlePlotName: "placeholder", isPrivate: false, circleId: "", admin: "", users: [""]))
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
        TheKind.fadeOutView(view: photoStripView)
        viewSkatingX(lockTopImage, left: true, reverse: true)
    }
    
    func closeLock() {
        TheKind.fadeInView(view: photoStripView)
        viewSkatingX(lockTopImage, left: false, -20, reverse: false)
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoStripCollectionViewCell", for: indexPath) as! PhotoStripCollectionViewCell
        return cell
    }
    
    
}

//Explainers
extension MapActionTriggerView {
    
    func explainerCircleCreation() {
        let txt = "You are creating a circle.-Click the locker to toggle between public and private.-If private only invited people can join.-Name the circle and hit save when you are done."
        
        let actions: [KindActionType] = [.none, .none,.none, .none]
        let actionViews: [ActionViewName] = [.none,.none,.none, .none]
        let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    
    func explainerCircleExploration() {
        let dominantKind = "founder"
        let chanceScore = "high"
        let privateKey = "will"
        let txt = "This place is dominated by the \(dominantKind) kind.-You have \(chanceScore) chances of making friends here.-You \(privateKey) need a key to join this circle."
        
        let actions: [KindActionType] = [.none, .none,.none]
        let actionViews: [ActionViewName] = [.none,.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Back to map.", opt2: "Enter circle.", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    
    func explainerNameCircleBeforeSavingIt() {
        let txt = "Name the circle before saving it.-Tap above to do so."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
        
    }
    
    func explainerCircleSavedSuccessfully() {
        let txt = "Done."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, action: actions, actionView: actionViews))
    }
}
