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
        let frameForText = estimateFrameFromText(text, bounding: textBoundingSize, fontSize: 24, fontName: SECONDARYFONT)
        
        lineWidthConstraint.constant = frameForText.width
        UIView.animate(withDuration: 1) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        adaptLineToTextSize(textField)
        //guard let username = textField.text, !(username.trimmingCharacters(in: .whitespaces).isEmpty) else {return}
        //self.username = username
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func createNewCircle(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, completion: (()->())?) {
        CircleAnnotationManagement.sharedInstance.saveCircle(latitude: latitude, longitude: longitude) { (circleAnnotationSet, err) in
            if let err = err {
                print(err)
                return
            }
            
            completion?()
            print("saved circle success")
        }
    }
    
    @objc func handleLongPressGesture(gestureRecognizer:UILongPressGestureRecognizer) {
        print("hello longpress!")
        creationMode = true
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchpoint = gestureRecognizer.location(in: mapBoxView)
            let newCoordinates = mapBoxView.convert(touchpoint, toCoordinateFrom: mapBoxView)
            

            latitude = newCoordinates.latitude
            longitude = newCoordinates.longitude
            
            let point = KindPointAnnotation(circleAnnotationSet: CircleAnnotationSet(location: newCoordinates, circlePlotName: "", isPrivate: false, circleId: "", admin: "", users: [""]))
            self.mapBoxView.addAnnotation(point)
            
            self.mapBoxView.setCenter(newCoordinates, zoomLevel: self.MAXZOOMLEVEL, animated: true)
            
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                //self.expandedCircleViews.alpha = 1
            }, completion: { (completed) in
                //  Shouldn't this happen first?
                self.mapBoxView.selectAnnotation(point, animated: true)
            })
            
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            print("ended gesture")
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


