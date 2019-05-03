//
//  Ext_Maps_MapActionTrigger.swift
//  TheKind
//
//  Created by Tenny on 4/12/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import Mapbox
import MapKit
import Foundation
import Firebase
import FirebaseFirestore

extension MapActionTriggerView: MGLMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        guard let kindAnnotation = annotation as? KindPointAnnotation else {
            return nil
        }
        
        let reuseIdentifier = UUID.init().description + "_" +  String(annotation.coordinate.longitude)
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CircleAnnotationView
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CircleAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = annotationBounds
        }
        
        if let circleDetails = kindAnnotation.circleDetails {
            annotationView?.circleDetails = circleDetails
        }
        
        return annotationView
    }

    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        guard let annotationView = annotationView as? CircleAnnotationView else {fatalError()}
        guard let coordinates = annotationView.circleDetails?.location else {fatalError()}
        
        //self.selectedAnnotationView = annotationView
        CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView = annotationView

        //Extract annotation details here.
        guard let set = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails else {
            print("annotation carries no details to be plotted: mapView(_ apView: MGLMapView, didSelect annotationView: MGLAnnotationView)")
            return
        }
        
        //load UI variables from set.
        self.circlePlotName = set.circlePlotName
        self.labelCircleName.attributedText = formatLabelTextWithLineSpacing(text: self.circlePlotName)
        self.circleNameTextField.attributedText = formatLabelTextWithLineSpacing(text: self.circlePlotName)
        self.circleIsPrivate = set.isPrivate
        self.userIsAdmin = checkIfIsAdmin(set.admin)
        
        self.mapBoxView.setCenter(coordinates, zoomLevel: MAXZOOMLEVEL,animated: true)

        // #0 - activation with animations.
        activateOnSelection(annotationView) {
            //after all functions below, #1 and #2 are completed
            self.initializeNewCircleDescription()
        }
        
    }
    
    // #1 - Expand circle animation.
    func activateOnSelection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        self.clearJungChatLog()
        longPressGesture.isEnabled = false //to avoid circle creation.
        
        UIView.animate(withDuration: 1, animations: {
            //scaling circle
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 0
            annotationView.transform = CGAffineTransform(scaleX: self.MAXSCIRCLESCALE, y: self.MAXSCIRCLESCALE)
            annotationView.alpha = 0.32
        }) { (Completed) in
            self.prepareViewsForDetailingCircle(annotationView: annotationView) {
                completion?()
            }
        }
    }
    
    // #2 - Animate inner circle views (after expansion)
    func prepareViewsForDetailingCircle(annotationView: CircleAnnotationView, completion: (()->())?) {
        if !annotationView.transform.isIdentity { // if circle is not in its natural "dot" state
            if annotationView.transform.a == self.MAXSCIRCLESCALE { // and only if its maximized.
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    
                     self.toggleMapOrAnnotationView(isMap: false)
                    
                }, completion: { (completed) in
                     UIView.animate(withDuration: 0.4, animations: {
                        self.toggleEditOrPresentationMode()
                        self.togglePrivateOrPublic()
                    }, completion: { (completed) in
                        completion?()
                    })
                    
                })
            }
        }
    }
    
    //animated via the caller closures.
    fileprivate func toggleMapOrAnnotationView(isMap: Bool) {
        mainViewController?.jungChatLogger.resetJungChat()
        //this is the black background fade.
        overlayExpandedCircleViews.alpha = isMap ? 0 : 1
        mapBoxView.isUserInteractionEnabled = isMap ? true : false
        mainViewController?.hudView.hudGradient.alpha = isMap ? 1 : 0
        mainViewController?.hudView.hudCenterDisplay.alpha = isMap ? 1 : 0
        mainViewController?.hudView.isUserInteractionEnabled = isMap ? true : false
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = isMap ? false : true
        borderProtectionLeft.isUserInteractionEnabled = isMap ? true : false
        borderProtectionRight.isUserInteractionEnabled = isMap ? true : false
        overlayExpandedCircleViews.isUserInteractionEnabled = isMap ? false : true
        longPressGesture.isEnabled = isMap ? true : false
        presentExpandedCircleView.isUserInteractionEnabled = isMap ? false : true
        editExpandedCircleView.isUserInteractionEnabled = isMap ? false : true
        presentExpandedCircleView.isHidden = isMap ? true : false
        editExpandedCircleView.isHidden = isMap ? true : false
    }
    
    

    private func toggleEditOrPresentationMode() {
        if self.isCircleEditMode {
            self.presentExpandedCircleView.isUserInteractionEnabled = false
            self.editExpandedCircleView.isUserInteractionEnabled = true
            self.editExpandedCircleView.alpha = 1
            self.presentExpandedCircleView.alpha = 0
        } else {
            self.presentExpandedCircleView.isUserInteractionEnabled = true
            self.editExpandedCircleView.isUserInteractionEnabled = false
            self.presentExpandedCircleView.alpha = 1
            self.editExpandedCircleView.alpha = 0
        }
    }
    
    func presentMap() {
        mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.toggleMapOrAnnotationView(isMap: true)
            self.hidePhotoStrip()
        }) { (completed) in
            //reset interface
            self.isCircleEditMode = false
            self.circleNameTextField.text = ""
            self.labelCircleName.text = ""
            self.adaptLineToTextSize(self.circleNameTextField, lineWidth: self.newCirclelineWidthConstraint)
            self.openLock()
            if let annotation = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView {
                self.deActivateOnDeselection(annotation) {
                    self.mapBoxView.deselectAnnotation(annotation.annotation, animated: false)
                }
            }
        }
    }



    fileprivate func togglePrivateOrPublic() {
        if circleIsPrivate {
            let keyImage = UIImage(named: "privatekey")?.withRenderingMode(.alwaysOriginal)
            self.enterCircleButton.setBackgroundImage(keyImage, for: .normal)
            self.loadUserPhotoStrip()

        } else {
            let enterImage = UIImage(named: "newEye")
            self.enterCircleButton.setBackgroundImage(enterImage, for: .normal)
        }
    }
    


    
    func checkIfIsAdmin(_ circleAdminId: String) -> Bool {
        if circleAdminId ==  (Auth.auth().currentUser?.uid)! {
            return true
        } else {
            return false
        }
    }
    
    
    func mapView(_ mapView: MGLMapView, didDeselect annotationView: MGLAnnotationView) {
        print("deselected")
        
    }
    
    

    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        // using didDragMap instead.
        // this method fires too often and for everything.

    }
    
    //MAP IS DRAGGED.
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            if let annotationView = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView, !annotationView.transform.isIdentity {
                deActivateOnDeselection(annotationView) {
                    annotationView.setSelected(false, animated: false)
                }
                //Remove circle if added on long press.
                if isCircleEditMode {
                    removeCancelledAnnotation(annotationView)
                    self.isCircleEditMode = false
                }
                self.clearJungChatLog()
                self.presentMap()
                self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)

            }

        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    func deActivateOnDeselection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        UIView.animate(withDuration: 1, animations: {
                self.mainViewController?.hudView.alpha = 1
                annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                annotationView.alpha = 0.9
                annotationView.button.alpha = 0
            })
        
            CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView = nil
            if let completion = completion {
                completion()
            }
    }
    
    func removeAnnotationAndBackToMap() {
        guard let annotationView = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView else {fatalError("// USER CANCELLED CREATION")}
        UIView.animate(withDuration: 0.4, animations: {
            self.overlayExpandedCircleViews.alpha = 0
        }) { (completed) in
            self.removeCancelledAnnotation(annotationView)
            self.isCircleEditMode = false
            self.presentMap()
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        }
    }
    
    
}
