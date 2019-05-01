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
        
        self.selectedAnnotationView = annotationView
        CircleAnnotationManagement.sharedInstance.currentlySelectedCircleSet = annotationView.circleDetails
        //Extract annotation details here.
        guard let circleDetails = annotationView.circleDetails else {
            print("annotation carries no details to be plotted: mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView)")
            return
        }
        guard let name = circleDetails.circlePlotName else {
            print("annotation carries no name to be plotted: mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView)")
            return
        }
        labelCircleName.attributedText = formatLabelTextWithLineSpacing(text: name)
        self.mapBoxView.setCenter(coordinates, zoomLevel: MAXZOOMLEVEL,animated: true)
        //This takes care of all the animations.
        activateOnSelection(annotationView) { (set) in
            self.initializeNewCircleDescription(set: set)
        }
        
    }
    
    
    func activateOnSelection(_ annotationView: CircleAnnotationView, completion: ((_ circleAnnotationSet: CircleAnnotationSet)->())?) {
        self.clearJungChatLog()
        longPressGesture.isEnabled = false //to avoid circle creation.
        
        
        UIView.animate(withDuration: 1, animations: {
            //scaling circle
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 0
            annotationView.transform = CGAffineTransform(scaleX: self.MAXSCIRCLESCALE, y: self.MAXSCIRCLESCALE)
            annotationView.alpha = 0.32
        }) { (Completed) in
            self.prepareViewsForDetailingCircle(annotationView: annotationView) {
                if let set = annotationView.circleDetails {
                    completion?(set)
                }
            }
        }
    }
    
    func prepareViewsForDetailingCircle(annotationView: CircleAnnotationView, completion: (()->())?) {
        if !annotationView.transform.isIdentity { // if circle is not in its natural "dot" state
            if annotationView.transform.a == self.MAXSCIRCLESCALE { // and only if its maximized.
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.toogleCircleAndMapViews(isOnMap: false) // exit map
                }, completion: { (completed) in
                     UIView.animate(withDuration: 0.4, animations: {
                        self.toggleInnerCircleView(isNewCircle: self.isNewCircle)
                        self.setupInnerPrivateOrPublicViews(annotationView.circleDetails!)
                    }, completion: { (completed) in
                        completion?()
                    })
                    
                })
            }
        }
    }
    
    private func toggleInnerCircleView(isNewCircle: Bool) {
        if self.isNewCircle {
            self.existentExpandedCircleView.isUserInteractionEnabled = false
            self.newExpandedCircleView.isUserInteractionEnabled = true
            self.newExpandedCircleView.alpha = 1
        } else {
            self.existentExpandedCircleView.isUserInteractionEnabled = true
            self.newExpandedCircleView.isUserInteractionEnabled = false
            self.existentExpandedCircleView.alpha = 1
        }
    }
    
    fileprivate func setupInnerPrivateOrPublicViews(_ set: CircleAnnotationSet) {
        if let isPrivate = set.isPrivate, isPrivate {
            let keyImage = UIImage(named: "privatekey")?.withRenderingMode(.alwaysOriginal)
            self.enterCircleButton.setBackgroundImage(keyImage, for: .normal)
            self.loadUserPhotoStrip()
        } else {
            let enterImage = UIImage(named: "newEye")
            self.enterCircleButton.setBackgroundImage(enterImage, for: .normal)
        }
    }
    
    private func deactivateInnerCircleViews(){
        self.existentExpandedCircleView.isUserInteractionEnabled = false
        self.newExpandedCircleView.isUserInteractionEnabled = false
        self.existentExpandedCircleView.alpha = 0
        self.newExpandedCircleView.alpha = 0
    }
    
    func toogleCircleAndMapViews(isOnMap: Bool) {
        if isOnMap {
            mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
            UIView.animate(withDuration: 0.5, animations: {
                self.hidePhotoStrip()
                self.deactivateInnerCircleViews()
                self.toggleMapOrAnnotationView(isMap: true) // switches to map view (taking all circle views to zero alpha etc.)
            }) { (completed) in
                if let annotation = self.selectedAnnotationView {
                    self.deActivateOnDeselection(annotation) {
                        self.mapBoxView.deselectAnnotation(annotation.annotation, animated: false)
                    }
                }
            }
        } else {
            self.toggleMapOrAnnotationView(isMap: false)
        }
        
    }
    
    fileprivate func toggleMapOrAnnotationView(isMap: Bool) {
        mainViewController?.jungChatLogger.resetJungChat()
        expandedCircleViews.alpha = isMap ? 0 : 1
        mapBoxView.isUserInteractionEnabled = isMap ? true : false
        mainViewController?.hudView.hudGradient.alpha = isMap ? 1 : 0
        mainViewController?.hudView.hudCenterDisplay.alpha = isMap ? 1 : 0
        mainViewController?.hudView.isUserInteractionEnabled = isMap ? true : false
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = isMap ? false : true
        borderProtectionLeft.isUserInteractionEnabled = isMap ? true : false
        borderProtectionRight.isUserInteractionEnabled = isMap ? true : false
        expandedCircleViews.isUserInteractionEnabled = isMap ? false : true
        longPressGesture.isEnabled = isMap ? true : false
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
            if let annotationView = selectedAnnotationView, !annotationView.transform.isIdentity {
                deActivateOnDeselection(annotationView) {
                    annotationView.setSelected(false, animated: false)
                }
                //Remove circle if added on long press.
                if isNewCircle {
                    removeCancelledAnnotation(annotationView)
                    self.isNewCircle = false
                }
                self.clearJungChatLog()
                self.toogleCircleAndMapViews(isOnMap: true)
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
        
            self.selectedAnnotationView = nil
            CircleAnnotationManagement.sharedInstance.currentlySelectedCircleSet = nil
            if let completion = completion {
                completion()
            }
    }
    
    func removeAnnotationAndBackToMap() {
        guard let annotationView = selectedAnnotationView else {fatalError("// USER CANCELLED CREATION")}
        UIView.animate(withDuration: 0.4, animations: {
            self.expandedCircleViews.alpha = 0
        }) { (completed) in
            self.removeCancelledAnnotation(annotationView)
            self.isNewCircle = false
            self.toogleCircleAndMapViews(isOnMap: true)
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        }
    }
    
    
}
