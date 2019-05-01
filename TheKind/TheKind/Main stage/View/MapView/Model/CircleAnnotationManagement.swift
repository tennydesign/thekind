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
                let circleAnnotationSet = CircleAnnotationSet(document: document)
                self.circles.append(circleAnnotationSet)
            })

            self.circleAnnotationObserver?(self.circles)
            
            completion()
        }
        
    }
    
    
    func saveCircle(set: CircleAnnotationSet, completion: @escaping (CircleAnnotationSet?, Error?)->()) {
        let db = Firestore.firestore()
    
        var documentRef: DocumentReference? = nil
        //this is returning nil HERE!!!
        guard let circleDict = set.asDictionary() else {return}
        documentRef = db.collection("kindcircles").addDocument(data: circleDict) { err in
            if let err = err {
                print(err)
                return
            }
            if let circleid = documentRef?.documentID {
                documentRef?.setData(["circleid":circleid], merge: true)
            }
            
            documentRef?.getDocument(completion: { (document,error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let document = document, document.exists {
                    let circleAnnotationSet = CircleAnnotationSet(document: document)
                    completion(circleAnnotationSet,nil)
                } else {
                    print("document doesn't exist: func saveCircle" )
                }
            })
            

        }
        
        
    }
    
    
    func retrieveCircleById(circleId: String, completion: ((CircleAnnotationSet?)->())?) {
        let db = Firestore.firestore()
        db.collection("kindcircles").document(circleId).getDocument {  (document,err) in
            if let err = err {
                print(err)
                completion?(nil)
                return
            }
            if document?.data() == nil
            {
                print("no data")
                completion?(nil)
                return
            }
            
            let set:CircleAnnotationSet = CircleAnnotationSet(document: document!)
            completion?(set)
        }
    }
    
    func addUserToCircle(set: CircleAnnotationSet, newElement: String) {
            let db = Firestore.firestore()
            guard let circleId = set.circleId else {return}
            let circlesRef = db.collection("kindcircles").document(circleId)
            //updates array by keeping it unique
            circlesRef.updateData(["users" : FieldValue.arrayUnion([newElement])])
    }
    
    
    func removeFromUserCircleArray(set: CircleAnnotationSet, removingElement: String) {
        let db = Firestore.firestore()
        guard let circleId = set.circleId else {return}
        let circlesRef = db.collection("kindcircles").document(circleId)
        circlesRef.updateData(["users" : FieldValue.arrayRemove([removingElement])
            ])
    }
    
    func loadUserIDsInCircle(set: CircleAnnotationSet, completion: (([String]?)->())?) {
        let db = Firestore.firestore()
        guard let circleId = set.circleId else {fatalError("no circleID: func loadUserIDsInCircle")}
        db.collection("kindcircles").document(circleId).getDocument {  (document,err) in
            if let err = err {
                print(err)
                return
            }
            guard let data = document?.data() else
            {
                print("no data")
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


    // DispatchGroup is forcing completion to wait till the loop is completed. 
    func loadCircleUsersProfile(set: CircleAnnotationSet, completion: (([KindUser]?)->())?) {
        var userProfiles:[KindUser] = []
        let group = DispatchGroup()
        self.loadUserIDsInCircle(set: set) { (userIds) in
            guard let userIds = userIds else {return}
            userIds.forEach({ (id) in
                group.enter()
                KindUserSettingsManager.sharedInstance.retrieveAnyUserSettings(userId: id, completion: { (kindUser) in
                    if let kindUser = kindUser {
                        userProfiles.append(kindUser)
                    }
                    group.leave()
                })
            })
            group.notify(queue: .main) {
                completion?(userProfiles)
            }
        }
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
