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
            self.enterCircleButton.setImage(keyImage, for: .normal)
            //This will show the photStrip with or without the + btn depending if user is admin.
            self.showPhotoStrip(isAdmin: self.checkIfIsAdmin(set.admin))
        } else {
            let enterImage = UIImage(named: "Jung")?.withRenderingMode(.alwaysOriginal)
            self.enterCircleButton.setImage(enterImage, for: .normal)
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
    
    
    //MAP IS DRAGGED.
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        
        // If there is an active annotation and this annotation is REALLY open.
        if let annotationView = selectedAnnotationView, !annotationView.transform.isIdentity {
            
            deActivateOnDeselection(annotationView) {
                annotationView.setSelected(false, animated: false)
            }
            
            //Remove circle if added on long press.
            if isNewCircle {
                if let annotation = annotationView.annotation {
                    self.mapBoxView.removeAnnotation(annotation)
                }
                self.isNewCircle = false
            }
            
            self.toogleTopBottomInnerViewsAndUserInteraction(isOnMap: true)
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
            
        }
    }
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    
    func activateOnSelection(_ annotationView: CircleAnnotationView, completion: ((_ circleAnnotationSet: CircleAnnotationSet)->())?) {
        self.clearJungChatLog()
        
        
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
    
    
    func prepareViewsForDetailingCircle(annotationView: CircleAnnotationView, completion: (()->())?) {
        self.newExpandedCircleView.alpha = 0
        self.existentExpandedCircleView.alpha = 0
        
        if !annotationView.transform.isIdentity {
            if annotationView.transform.a == self.MAXSCIRCLESCALE {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.toogleTopBottomInnerViewsAndUserInteraction(isOnMap: false)
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
    
    func toogleTopBottomInnerViewsAndUserInteraction(isOnMap: Bool) {
        if isOnMap {
            self.expandedCircleViews.alpha = 0
            self.mainViewController?.hudView.hudGradient.alpha = 1
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 1
            self.mainViewController?.hudView.isUserInteractionEnabled = true
            self.mainViewController?.hudView.hudControls.isUserInteractionEnabled = true
            self.mainViewController?.hudWindow.isUserInteractionEnabled = true
            self.mainViewController?.topCurtainView.isUserInteractionEnabled = true
            self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = false
            self.expandedCircleViews.isUserInteractionEnabled = false
        } else {
            //This alpha will be handled at prepareViewsForDetailingCircle for animation purposes.
            self.expandedCircleViews.alpha = 1
            self.mainViewController?.hudView.hudGradient.alpha = 0
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 0
            self.mainViewController?.hudView.isUserInteractionEnabled = false
            self.mainViewController?.hudWindow.isUserInteractionEnabled = false
            self.mainViewController?.topCurtainView.isUserInteractionEnabled = false
            self.mainViewController?.hudView.hudControls.isUserInteractionEnabled = false
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
    
    func deActivateOnDeselection(_ annotationView: CircleAnnotationView, completion: (()->())?) {
        hidePhotoStrip()
        self.clearJungChatLog()
        UIView.animate(withDuration: 1, animations: {
            self.toogleTopBottomInnerViewsAndUserInteraction(isOnMap: true)
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
    
}
