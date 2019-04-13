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
                //print(data)
                //print(document.documentID)
                guard let name = data["name"] as? String else {fatalError("no name")}
                guard let geoPoint = data["location"] as? GeoPoint else {fatalError("no geopoint")}
                guard let isPrivate = data["isprivate"] as? Bool else {fatalError("no private or not bool")}
                guard let admin = data["admin"] as? String else {fatalError("no admin on file")}
                let users = data["users"] as? [String] ?? []
                let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                let annotationSet = CircleAnnotationSet(location: location, circlePlotName: name, isPrivate: isPrivate, circleId: document.documentID, admin: admin, users: users)
                self.circles.append(annotationSet)
            })
            self.circleAnnotationObserver?(self.circles)
            completion()
        }
        
    }
    
    
    func saveCircle(name: String, isPrivate: Bool, users: [String],latitude: Double, longitude: Double, completion: @escaping (CircleAnnotationSet, Error?)->()) {
        let db = Firestore.firestore()
  
        let dateformat = DateFormatter()
        dateformat.dateFormat = "MM-dd hh:mm a"
        let dateNow = dateformat.string(from: Date())
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        var allUsers = users
        allUsers.append(uid)
        let circleDict: [String:Any] = ["admin": uid, "name" : name , "created": dateNow, "isprivate": isPrivate, "location": GeoPoint(latitude: latitude, longitude: longitude), "users": allUsers]
        
        var ref: DocumentReference? = nil
        
        ref = db.collection("kindcircles").addDocument(data: circleDict) { err in
            if let err = err {
                print(err)
                return
            }
            
            //print(ref!.documentID)
            KindUserSettingsManager.sharedInstance.updateUserCircleArray(newElement: ref!.documentID)
            
            //Create the set for the new circle
            let circleAnnotationSet = CircleAnnotationSet.init(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), circlePlotName: name, isPrivate: isPrivate, circleId: ref!.documentID, admin: uid, users: allUsers)
            
            completion(circleAnnotationSet,nil)
        }
        
        
    }
//
//    //HERE: IT WORKS
//    func updateCircleSettings(circleId: String,isprivate:Bool?, name:String?, completion: ((Error?)->())?) {
//        let db = Firestore.firestore()
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        //guard let annotation = (circles.filter{$0.circleId == circleId && $0.admin == uid}).first else {return}
//
//        var circleDict:[String:Any] = [:]
//        circleDict["admin"] = uid
//
//        if let isprivate = isprivate {
//            circleDict["isprivate"] = isprivate
//        }
//        if let name = name {
//            circleDict["name"] = name
//        }
//
//        db.collection("kindcircles").document(circleId).updateData(circleDict) { (err) in
//            if let err = err {
//                completion?(err)
//                return
//            } else {
//                completion?(nil)
//            }
//
//        }
//
//    }
    
    func addUserToCircle(set: CircleAnnotationSet, newElement: String) {
            let db = Firestore.firestore()
            let circleId = set.circleId
            let circlesRef = db.collection("kindcircles").document(circleId)
            //updates array by keeping it unique
            circlesRef.updateData(["users" : FieldValue.arrayUnion([newElement])])
    }
    
    
    func removeFromUserCircleArray(set: CircleAnnotationSet, removingElement: String) {
        let db = Firestore.firestore()
        let circleId = set.circleId
        let circlesRef = db.collection("kindcircles").document(circleId)
        circlesRef.updateData(["users" : FieldValue.arrayRemove([removingElement])
            ])
    }
    
    func loadUsersInCircle(set: CircleAnnotationSet, completion: (([String]?)->())?) {
        let db = Firestore.firestore()
        let circleId = set.circleId
        db.collection("usersettings").document(circleId).getDocument {  (document,err) in
            if let err = err {
                print(err)
//                completion?(false)
                return
            }
            guard let data = document?.data() else
            {
                print("no data")
//                completion?(false)
                return
            }
            let circleData:[String:Any] = data
            
            guard let users = circleData["users"] as? [String], !users.isEmpty else {
                completion?(nil)
                return
            }
            
            completion?(users)
        }
    }
    
    func loadCircleUsersPhotoUrls(set: CircleAnnotationSet, completion: @escaping (([URL]?)->())) {
        self.loadUsersInCircle(set: set) { (userIds) in
            guard let userIds = userIds else {return}
            var photoURLs: [URL]?
            userIds.forEach({ (id) in
                KindUserSettingsManager.sharedInstance.retrieveUserPhoto(userId: id, completion: { (photoUrl) in
                    guard let photoUrl = photoUrl else {
                        completion(nil)
                        return
                    }
                    
                    photoURLs!.append(photoUrl)
                    
                })
            })
            completion(photoURLs)
        }
    }
}
