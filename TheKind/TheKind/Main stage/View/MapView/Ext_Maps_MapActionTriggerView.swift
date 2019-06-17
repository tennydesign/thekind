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

extension MapActionTriggerView: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {

    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        mapBoxView.showsUserLocation = true
        // mapBoxView.userTrackingMode = .followWithCourse
        mapBoxView.setUserTrackingMode(.follow, animated: true)
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
        
        guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
        guard let annotationView = annotationView as? CircleAnnotationView else {return}
        guard let coordinates = annotationView.circleDetails?.location else {return}
        
        
        CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView = annotationView

        guard let set = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails else { return}
        
        // ACL control
        if (set.isPrivate && !set.users.contains(uid)) {
            showAccessDeniedLabel(message: "Access denied!")
            return
        }
        
        // Deletion control
        if set.deleted {
            self.showAccessDeniedLabel(message: "Deactivated by admin.")
            if let annotation = annotationView.annotation {
                self.mapBoxView.removeAnnotation(annotation)
            }
            return
        }
        
        self.mapBoxView.setCenter(coordinates, zoomLevel: MAXZOOMLEVEL,animated: true)
        self.mapBoxView.isUserInteractionEnabled = false
        
        // Load users to photoStrip array
        CircleAnnotationManagement.sharedInstance.loadCircleUsersProfile() { (kindUsers) in
            self.usersInCircle = kindUsers ?? []
        }
        

    
        // #2 - activation with animations.
        activateOnSelection(annotationView) {
            
            self.setupUIWithSetInfo()
            
            delay(bySeconds: 0.2, closure: {
                self.togglePresentInnerCircleViews(on: true)
            })
            
            self.initializeCircleExplainer()
            
        }
        
    }
    
    func initializeCircleExplainer() {
        
        if circleIsInEditMode {
            explainerCircleCreation()
            
        } else {
            explainerCircleExploration()
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
        UIView.animate(withDuration: 0.5, animations: {
            self.mainViewController?.hudView.hudCenterDisplay.alpha = 0
            self.mainViewController?.hudView.listViewStack.alpha = 1
        })
        
    }

    func togglePresentInnerCircleViews(on: Bool) {
        if on {
            UIView.animate(withDuration: 0.4) {
                self.presentExpandedCircleView.alpha = 1
            }
            presentExpandedCircleView.isHidden = false
        } else {
            UIView.animate(withDuration: 0.4) {
                self.presentExpandedCircleView.alpha = 0
            }
            presentExpandedCircleView.isHidden = true
        }
    }
    
    
    // ============================================================
    // Presenting Map.
    // Triggered by: DRAG, Jung's RIGHT (save) or LEFT (cancel) options.
    
    // #1 Animate deactivation
    func deActivateOnDeselection(completion: (()->())?) {
        guard let annotationView = CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView else {return}
        guard let set = annotationView.circleDetails else {return}
        
        self.mapBoxView.isUserInteractionEnabled = true
        mainViewController?.setHudDisplayGradientBg(on: true) {
            self.prepareMapViewsForPresentation { viewsAreReady in
                UIView.animate(withDuration: 1, animations: {
                    self.mainViewController?.hudView.alpha = 1
                    annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    annotationView.alpha = CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation ? 0 : 0.9
                    annotationView.button.alpha = 0
                }) { (completed) in
                    
                    //DELETION
                    //If user was creating circle and cancelled OR if circle was deleted
                    if CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation || set.deleted {
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
                    
                    self.presentPhotoStrip(on: false)
                    self.togglePresentInnerCircleViews(on: false)
                    //self.circleNameTextFieldView.alpha = 0
                    self.circleIsInEditMode = false
                    
                    completion?()
                    
                }
            }
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

extension MapActionTriggerView: ListCircleViewProtocol {
    
    func goToCircleAndActivateIt(circleId: String) {
        print(circleId)
        if let annotation = self.mapBoxView.annotations?.filter({$0.title == circleId}).first {
            self.mapBoxView.selectAnnotation(annotation, animated: true)
        }
    }
    
}

extension MapActionTriggerView: CLLocationManagerDelegate {
    
    //TODO: IN the simulator if location is granted after first load circles will not show.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updated")
        if let location = manager.location {
            CircleAnnotationManagement.sharedInstance.geoFireQuery?.center = location
            //TODO: probably needs an && for the case where user is not using the map
            // Maybe refactor non-used views to "isHidden=tue" in addition to alpha (better!)
            if self.mapBoxView.alpha == 0 {
                UIView.animate(withDuration: 0.4, animations: {
                    self.mapBoxView.alpha = 1
                }, completion: { (completed) in
                   // self.talk()
                })
            }
        }
        
    }
    
    
    func locationServicesSetup() {

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
 
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
     
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access to location services")
                
                case .authorizedAlways, .authorizedWhenInUse:
                    self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
                    
                    if let coordinate = locationManager.location?.coordinate {
                        self.mapBoxView.setCenter(coordinate,
                                                  zoomLevel: 14, animated: false)
                        print("location manager got location")
                    } else {
                        self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
                                                                         longitude: -122.389246),
                                                  zoomLevel: 14, animated: false)
                    }
            @unknown default:
                print("Location services test resulted something unknown")
            }
            
        } else {
            print("Location services are not enabled")
            self.mapBoxView.setZoomLevel(self.FLYOVERZOOMLEVEL, animated: true)
            self.mapBoxView.setCenter(CLLocationCoordinate2D(latitude: 37.778491,
                                                             longitude: -122.389246),
                                      zoomLevel: 14, animated: false)
        }
    }
}
