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
        
        //Extract annotation details here.
        guard let circleDetails = annotationView.circleDetails else {fatalError("annotation carries no details to be plotted")}
        
        labelCircleName.attributedText = formatLabelTextWithLineSpacing(text: circleDetails.circlePlotName)
        self.mapBoxView.setCenter(coordinates, zoomLevel: MAXZOOMLEVEL,animated: true)
        //This takes care of all the animations.
        activateOnSelection(annotationView) { (set) in
            self.describeCircle(set: set)
        }
        
    }
    
    fileprivate func setupInnerPrivateOrPublicViews(_ set: CircleAnnotationSet) {
        if set.isPrivate {
            let keyImage = UIImage(named: "privatekey")?.withRenderingMode(.alwaysOriginal)
            self.enterCircleButton.setBackgroundImage(keyImage, for: .normal)
            //This will show the photStrip with or without the + btn depending if user is admin.
            self.showPhotoStrip(isAdmin: self.checkIfIsAdmin(set.admin))
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
    // This is not being called (hopefully) cause map is losing touch on Select
    // And regaining on Deselect.
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
                    longPressGesture.isEnabled = true
                    mapBoxView.isUserInteractionEnabled = true
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
    
    
    func activateOnSelection(_ annotationView: CircleAnnotationView, completion: ((_ circleAnnotationSet: CircleAnnotationSet)->())?) {
        self.clearJungChatLog()
        longPressGesture.isEnabled = false
        mapBoxView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 1, animations: {
            //scaling
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 0

            //**
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
    
    func deActivateOnDeselection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        hidePhotoStrip()
        longPressGesture.isEnabled = true
        self.clearJungChatLog()
        UIView.animate(withDuration: 1, animations: {
            self.toogleCircleAndMapViews(isOnMap: true)
        }) { (completed) in
            UIView.animate(withDuration: 1, animations: {
                self.mainViewController?.hudView.alpha = 1
                
                annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                annotationView.alpha = 0.9
                annotationView.button.alpha = 0
            })
            
            self.selectedAnnotationView = nil
            
            if let completion = completion {
                completion()
            }
        }
        
        
    }
    
    func prepareViewsForDetailingCircle(annotationView: CircleAnnotationView, completion: (()->())?) {
        self.newExpandedCircleView.alpha = 0
        self.existentExpandedCircleView.alpha = 0
        
        if !annotationView.transform.isIdentity {
            if annotationView.transform.a == self.MAXSCIRCLESCALE {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.toogleCircleAndMapViews(isOnMap: false)
                }, completion: { (completed) in
                    
                    self.toggleInnerCircleViewInteraction(isNewCircle: self.isNewCircle)
                    UIView.animate(withDuration: 0.4, animations: {
                        if self.isNewCircle {
                            self.newExpandedCircleView.alpha = 1
                        } else {
                            self.existentExpandedCircleView.alpha = 1
                        }
                        
                        //HERE: ----->
                        self.setupInnerPrivateOrPublicViews(annotationView.circleDetails!)
                    }, completion: { (completed) in
                        completion?()
                    })
                    
                })
                
            }
        } else {
            // If it did cut off, cancel interaction.
            //annotationView.setSelected(false, animated: false)
        }
    }
    
    func toogleCircleAndMapViews(isOnMap: Bool) {
        if isOnMap {
            self.expandedCircleViews.alpha = 0
            self.mainViewController?.hudView.hudGradient.alpha = 1
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 1
            self.mainViewController?.hudView.isUserInteractionEnabled = true
            self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
            self.expandedCircleViews.isUserInteractionEnabled = false
        } else {
            //This alpha will be handled at prepareViewsForDetailingCircle for animation purposes.
            self.expandedCircleViews.alpha = 1
            self.mainViewController?.hudView.hudGradient.alpha = 0
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 0
            self.mainViewController?.hudView.isUserInteractionEnabled = false
            self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
            self.expandedCircleViews.isUserInteractionEnabled = true
        }
        
    }
    
    private func toggleInnerCircleViewInteraction(isNewCircle: Bool) {
        if !isNewCircle {
            self.existentExpandedCircleView.isUserInteractionEnabled = true
            self.newExpandedCircleView.isUserInteractionEnabled = false
        } else {
            self.existentExpandedCircleView.isUserInteractionEnabled = false
            self.newExpandedCircleView.isUserInteractionEnabled = true
        }
        
    }
    
    func removeAnnotationAndBackToMap() {
        guard let annotationView = selectedAnnotationView else {fatalError("// USER CANCELLED CREATION")}
        UIView.animate(withDuration: 0.4, animations: {
            self.expandedCircleViews.alpha = 0
        }) { (completed) in
            self.removeCancelledAnnotation(annotationView)
            self.isNewCircle = false
            self.longPressGesture.isEnabled = true
            self.mapBoxView.isUserInteractionEnabled = true
            self.clearJungChatLog()
            self.toogleCircleAndMapViews(isOnMap: true)
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        }
    }
    
    func deselectAnnotationAndBackToMap() {
        guard let selectedAnnotationView = selectedAnnotationView else {fatalError("// USER HITS BACK TO THE MAP")}
        self.deActivateOnDeselection(selectedAnnotationView) {
            self.mapBoxView.isUserInteractionEnabled = true
            self.mapBoxView.deselectAnnotation(selectedAnnotationView.annotation, animated: false)
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
        }
    }
    
}
