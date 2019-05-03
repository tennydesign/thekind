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
    
    //Receive Currently Selected circle or nil. If nil, will kill the observer.
    
    var currentlySelectedAnnotationView: CircleAnnotationView? {
        didSet {
            if let annotationView = currentlySelectedAnnotationView {
                if let circleId = annotationView.circleDetails?.circleId {
                    //fire up observer only once per circleID
                    if circleId != oldValue?.circleDetails?.circleId {
                        observeCircleSetFirebase(circleId: circleId)
                    }
                }
            } else {
                // kill obbserver
                circleSnapShotListener?.remove()
            }
        }
    }
    
    var circleSnapShotListener: ListenerRegistration?
    var userListChangedOnCircleObserver: (()->())?
    
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
    
    
    func saveCircleSet(completion: @escaping (CircleAnnotationSet?, Error?)->()) {
        let db = Firestore.firestore()
        guard let set = currentlySelectedAnnotationView?.circleDetails else { return}
        var documentRef: DocumentReference? = nil
        guard let circleDict = set.asDictionary() else {return}
        documentRef = db.collection("kindcircles").addDocument(data: circleDict) { err in
            if let err = err {
                print(err)
                completion(nil, err)
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
                
                guard let document = document, document.exists else {return}
                let circleAnnotationSet = CircleAnnotationSet(document: document)
                completion(circleAnnotationSet,nil)
                
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
    
    func addUserToCircle(userId: String, completion: (()->())?) {
        let db = Firestore.firestore()
        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
        let circlesRef = db.collection("kindcircles").document(circleId)
        //updates array by keeping it unique
        circlesRef.updateData(["users" : FieldValue.arrayUnion([userId])]) { (err) in
            if let err = err {
                print(err)
                return
            }
            completion?()
        }

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

 
    func loadCircleUsersProfile(completion: (([KindUser]?)->())?) {
        guard let set = currentlySelectedAnnotationView?.circleDetails else {return}
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
    
    func observeCircleSetFirebase(circleId: String) {
        let db = Firestore.firestore()
        circleSnapShotListener = db.collection("kindcircles").document(circleId).addSnapshotListener { (document, err) in
            if let err = err {
                print(err)
                return
            }
            guard (document?.data()) != nil else {
                print("no snapshot data on observeUserKindDeck")
                return
            }
            print("userchanged")
            let set:CircleAnnotationSet = CircleAnnotationSet(document: document!)
            // reload SET with new info.
            self.currentlySelectedAnnotationView?.circleDetails = set
            // let client now there is a new loaded set.
            self.userListChangedOnCircleObserver?()
            
        }
    }
    
    
}
