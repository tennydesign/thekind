//
//  CircleAnnotationManagement.swift
//  TheKind
//
//  Created by Tenny on 3/29/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import MapKit
import Mapbox
import FirebaseFirestore
import Firebase

class CircleAnnotationManagement {
    static let sharedInstance = CircleAnnotationManagement()
    private init() {}
    var circleAnnotationObserver: (([CircleAnnotationSet])->())?
    var circles: [CircleAnnotationSet] = []
    
    func retrieveCirclesCloseToPlayer(completion: @escaping (()->()))  {
        let db = Firestore.firestore()
        
        db.collection("kindcircles").getDocuments { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            snapshot?.documents.forEach({ (document) in
                let data = document.data()
                print(data)
                print(document.documentID)
                guard let name = data["name"] as? String else {fatalError("no name")}
                guard let geoPoint = data["location"] as? GeoPoint else {fatalError("no geopoint")}
                guard let isPrivate = data["isprivate"] as? Bool else {fatalError("no private or not bool")}
                let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                let annotationSet = CircleAnnotationSet(coordinate: location, circlePlotName: name, isPrivate: isPrivate, circleId: document.documentID)
                self.circles.append(annotationSet)

            })
            self.circleAnnotationObserver?(self.circles)
            completion()
        }
        
    }
    
    
    func saveCircle(latitude: Double, longitude: Double, completion: @escaping (CircleAnnotationSet, Error?)->()) {
        let db = Firestore.firestore()
        

        
        let dateformat = DateFormatter()
        dateformat.dateFormat = "MM-dd hh:mm a"
        let dateNow = dateformat.string(from: Date())
        
        
        let circleDict: [String:Any] = ["admin": (Auth.auth().currentUser?.uid)!,"name" : "philz", "created": dateNow, "isprivate": true, "location": GeoPoint(latitude: latitude, longitude: longitude)]
        
        
        var ref: DocumentReference? = nil
        
        ref = db.collection("kindcircles").addDocument(data: circleDict) { err in
            if let err = err {
                print(err)
                return
            }
            
            print(ref!.documentID)
            KindUserSettingsManager.sharedInstance.updateUserCircleArray(newElement: ref!.documentID)
            
            //Create the set for the new circle
            let circleAnnotationSet = CircleAnnotationSet.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), circlePlotName: "philz", isPrivate: true, circleId: ref!.documentID)
            
            completion(circleAnnotationSet,nil)
        }
        
        
    }
    
    
    
}
