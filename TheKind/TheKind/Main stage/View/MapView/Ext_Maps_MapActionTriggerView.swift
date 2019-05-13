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
        
        
        guard let annotationView = annotationView as? CircleAnnotationView else {return}
        guard let coordinates = annotationView.circleDetails?.location else {return}
        
        
        CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView = annotationView

        
        self.mapBoxView.setCenter(coordinates, zoomLevel: MAXZOOMLEVEL,animated: true)
        self.mapBoxView.isUserInteractionEnabled = false
        
        // Load users to photoStrip array
        CircleAnnotationManagement.sharedInstance.loadCircleUsersProfile() { (kindUsers) in
            self.usersInCircle = kindUsers ?? []
        }
        
        guard let set =  CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails else {return}
        
        if !set.circlePlotName.isEmpty {
            self.circlePlotName = set.circlePlotName
            self.circleNameTextField.attributedText = formatLabelTextWithLineSpacing(text: set.circlePlotName)
        }
        
        self.userIsAdmin = checkIfIsAdmin(set.admin)
        self.circleIsPrivate = set.isPrivate
        
    
        // #2 - activation with animations.
        activateOnSelection(annotationView) {
            //after all functions below, #1 and #2 are completed
            if self.userIsAdmin || self.circleIsInEditMode {
                self.toggleEditMode(on: true)
            } else {
                self.toggleEditMode(on: false)
            }
            self.togglePrivateOrPublic()
            self.initializeCircleExplainer()
        }
        
    }
    
    //========================================================
    // #2 -Presenting annotation fullscreen.
    
    func activateOnSelection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        
        self.clearJungChatLog()
        longPressGesture.isEnabled = false //to avoid circle creation.
    
        UIView.animate(withDuration: 1, animations: {
            //scaling circle
            annotationView.transform = CGAffineTransform(scaleX: self.MAXSCIRCLESCALE, y: self.MAXSCIRCLESCALE)
            annotationView.alpha = 0.32
            
            // its weird but better if this goes first.
            // HERE
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 0
        }) { (Completed) in
            if annotationView.transform.a == self.MAXSCIRCLESCALE {
                //preparing to transition to annotationView fullscreen mode.
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                    
                    // black background covering map is here
                    self.presentAnnotationView()
                    
                    
                }, completion: { (completed) in
                    // HERE
                    self.mainViewController?.setHudDisplayGradientBg(on: false, completion: nil)
                    completion?()
                })
            }
        }

    }

    
    func presentAnnotationView() {
        mapBoxView.isUserInteractionEnabled = false
        overlayExpandedCircleViews.alpha = 1
        overlayExpandedCircleViews.isUserInteractionEnabled = true
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
        borderProtectionLeft.isUserInteractionEnabled = false
        borderProtectionRight.isUserInteractionEnabled = false
        
    }

    func togglePresentInnerCircleViews(on: Bool) {
        if on {
            presentExpandedCircleView.alpha = 1
            presentExpandedCircleView.isHidden = false
        } else {
            presentExpandedCircleView.alpha = 0
            presentExpandedCircleView.isHidden = true
        }
    }
    
    
    // ============================================================
    // Presenting Map.
    // Triggered by: DRAG, Jung's RIGHT (save) or LEFT (cancel) options.
    
    // #1 Animate deactivation
    func deActivateOnDeselection(completion: (()->())?) {
        guard let annotationView = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView else {return}
        self.mapBoxView.isUserInteractionEnabled = true
        mainViewController?.setHudDisplayGradientBg(on: true) {
            self.presentMapViews {
                UIView.animate(withDuration: 1, animations: {
                    self.mainViewController?.hudView.alpha = 1
                    annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    annotationView.alpha = CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation ? 0 : 0.9
                    annotationView.button.alpha = 0
                }) { (completed) in
                    
                    //If user was creating circle and cancelled.
                    if CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation {
                        self.circleNameTextField.resignFirstResponder()
                        if let annotation = annotationView.annotation {
                            self.mapBoxView.removeAnnotation(annotation)
                        }
                    } else {
                        annotationView.setSelected(false, animated: false)
                    }
                    self.usersInCircle = []
                    CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView = nil
                    self.longPressGesture.isEnabled = true
                
                    self.togglePresentInnerCircleViews(on: false)
                    //self.circleNameTextFieldView.alpha = 0
                    self.circleIsInEditMode = false
                    
                    completion?()
                }
            }
        }

    }
    
    
    func presentMapViews(completion: (()->())?) {
        mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        mapBoxView.isUserInteractionEnabled = true
        overlayExpandedCircleViews.isUserInteractionEnabled = false
        mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
        borderProtectionLeft.isUserInteractionEnabled = true
        borderProtectionRight.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayExpandedCircleViews.alpha = 0
        }) { (completed) in
            completion?()
        }
        
    }

    func mapView(_ mapView: MGLMapView, didDeselect annotationView: MGLAnnotationView) {
        // not in use
    }
    
    
    // =============================================================
    // Supporting functions
    //


    


    
    
    func checkIfIsAdmin(_ circleAdminId: String) -> Bool {
        if circleAdminId ==  (Auth.auth().currentUser?.uid)! {
            return true
        } else {
            return false
        }
    }


    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        // using didDragMap instead.
        // this method fires too often and for everything.

    }
    
    //MAP IS DRAGGED.
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            print("dragged")
            self.deActivateOnDeselection(completion: nil)
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
}
