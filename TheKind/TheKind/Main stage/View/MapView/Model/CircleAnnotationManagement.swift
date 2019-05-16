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
    var userAddedToTemporaryCircleListObserver: ((KindUser)->())?
    var userRemovedFromTemporaryCircleListObserver: ((KindUser)->())?
    var circles: [CircleAnnotationSet] = []
    var circleSnapShotListener: ListenerRegistration?
    var setChangedOnCircleObserver: ((CircleAnnotationSet)->())?

    //Receive Currently Selected circle or nil. If nil, will kill the observer.
    
    var isSelectedTemporaryCircleAnnotation:Bool {
        get {
            guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return false}
            return currentlySelectedAnnotationView != nil &&  currentlySelectedAnnotationView?.annotation?.title == uid
        }
    }
    
    var currentlySelectedAnnotationView: CircleAnnotationView? {
        didSet {
            if let annotationView = currentlySelectedAnnotationView {
                if let circleId = annotationView.circleDetails?.circleId {
                    //fire up observer only once per circleID
                    if circleId != oldValue?.circleDetails?.circleId && !isSelectedTemporaryCircleAnnotation {
                        observeCircleSetFirebase(circleId: circleId)
                    }
                }
            } else {
                // kill obbserver
                circleSnapShotListener?.remove()
            }
        }
    }
    
    func retrieveCirclesCloseToPlayer(completion: @escaping (()->()))  {
        let db = Firestore.firestore()
        guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
        db.collection("kindcircles").getDocuments { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            snapshot?.documents.forEach({ (document) in
                let set = CircleAnnotationSet(document: document)
                
                //TODO: FILTER THIS IN THE QUERY NOT HERE MAYBE.
                // Show only not private or private with user in.
                if !set.isPrivate || set.users.contains(uid) {
                    if !set.deleted {
                        self.circles.append(set)
                    }
                }
            })

            self.circleAnnotationObserver?(self.circles)
            
            completion()
        }
        
    }
    

    func updateCircleSettings(completion: @escaping (CircleAnnotationSet?, Error?)->()) {
        let db = Firestore.firestore()
        guard let set = currentlySelectedAnnotationView?.circleDetails else { return}
        guard let circleDict = set.asDictionary() else {return}
        db.collection("kindcircles").document(set.circleId).updateData(circleDict) { (err) in
            if let err = err {
                //SAVE CAUSE NO CIRCLE EXIST
                if err.localizedDescription.contains("No document to update") {
                    //Create circle from scratch
                    self.saveNewCircleSet(completion: { (set,err)  in
                        if let err = err {
                            completion(nil,err)
                        }
                        completion(set,nil)
                        return
                        
                    })
                    
                }
            } else {
                //UPDATE CAUSE IT EXISTS
                completion(set,nil)
            }
            
        }
    }
 
    private func saveNewCircleSet(completion: @escaping (CircleAnnotationSet?, Error?)->()) {
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
    
    func checkIfUserBelongsToCircle(userId: String, completion: ((Bool?)->())?) {
        guard let set = currentlySelectedAnnotationView?.circleDetails else {return}
        loadUserIDsInCircle(set: set) { (users) in
            if let users = users {
                completion?(users.contains(userId))
            } else {
                completion?(nil)
            }
        }
    }
    
    func checkIfUserBelongsToTemporaryCircle(userId: String, completion: ((Bool?)->())?) {
        guard let set = currentlySelectedAnnotationView?.circleDetails else {return}
        completion?(set.users.contains(userId))
    }
    
    func addUserToCircle(userId: String, completion: (()->())?) {
        let db = Firestore.firestore()
        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}

        let circlesRef = db.collection("kindcircles").document(circleId)
        //ArrayUnion() adds elements to an array but only elements not already present.
        circlesRef.updateData(["users" : FieldValue.arrayUnion([userId])]) { (err) in
            if let err = err {
                print(err)
                return
            }
            completion?()
        }

    }
    
    func addUsersToCircle(userIds: [String], completion: (()->())?) {
        let db = Firestore.firestore()
        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
        let circlesRef = db.collection("kindcircles").document(circleId)
        //ArrayUnion() adds elements to an array but only elements not already present.
        circlesRef.updateData(["users" : FieldValue.arrayUnion([userIds])]) { (err) in
            if let err = err {
                print(err)
                return
            }
            completion?()
        }
        
    }
    
    
    func removeUserFromCircle(userId: String, completion: (()->())?) {
        let db = Firestore.firestore()
        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
        let circlesRef = db.collection("kindcircles").document(circleId)
        circlesRef.updateData(["users" : FieldValue.arrayRemove([userId])]) { (err) in
            if let err = err {
                print(err)
                return
            }
            completion?()
        }
    }
    
    func addUserToTemporaryCircle(userId: String, completion: ((KindUser?)->())?) {
      KindUserSettingsManager.sharedInstance.retrieveAnyUserSettings(userId: userId, completion: { (kindUser) in
            if let kindUser = kindUser {
                CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.users.append(userId)
                completion?(kindUser)
            }
        })
    }
    
    func removeUserFromTemporaryCircle(userId: String, completion: (((KindUser?))->())?) {
        KindUserSettingsManager.sharedInstance.retrieveAnyUserSettings(userId: userId, completion: { (kindUser) in
            if let kindUser = kindUser {
                CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.users.removeAll {$0 == userId}
                completion?(kindUser)
            }
        })
        
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
                print("no snapshot data on observeCircleSetFirebase")
                return
            }
            print("circle changed")
            let set:CircleAnnotationSet = CircleAnnotationSet(document: document!)
            // reload SET with new info.
            self.currentlySelectedAnnotationView?.circleDetails = set
            // let client now there is a new loaded set.
            self.setChangedOnCircleObserver?(set)
            
        }
    }
    
    
}


//========
// Old - before refactoring

//    func changeCircleAdminTo(userId: String, completion: (()->())?) {
//        let db = Firestore.firestore()
//        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
//
//        let circlesRef = db.collection("kindcircles").document(circleId)
//        //ArrayUnion() adds elements to an array but only elements not already present.
//        circlesRef.updateData(["admin" : userId]) { (err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            completion?()
//        }
//
//    }

//    func flagCircleAsDeleted(completion: (()->())?) {
//        let db = Firestore.firestore()
//        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
//
//        let circlesRef = db.collection("kindcircles").document(circleId)
//        //ArrayUnion() adds elements to an array but only elements not already present.
//        circlesRef.updateData(["deleted" : true]) { (err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            completion?()
//        }
//
//    }

//    func togglePublicOrPrivate(isPrivate: Bool, completion: (()->())?) {
//        let db = Firestore.firestore()
//        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
//
//        let circlesRef = db.collection("kindcircles").document(circleId)
//        //ArrayUnion() adds elements to an array but only elements not already present.
//        circlesRef.updateData(["isprivate" : isPrivate]) { (err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            completion?()
//        }
//
//    }

//    func removeCurrentlySelectedCircle(completion: @escaping ((Bool)->())) {
//        let db = Firestore.firestore()
//        if !isSelectedTemporaryCircleAnnotation {
//            guard let set = currentlySelectedAnnotationView?.circleDetails else { return}
//            db.collection("kindcircles").document(set.circleId).delete() { err in
//                if let err = err {
//                    print("Error removing document: \(err)")
//                    completion(false)
//                } else {
//                    print("Document successfully removed!")
//                    completion(true)
//                    self.currentlySelectedAnnotationView = nil
//                    //self.setDeletedCircleObserver?(set)
//                }
//            }
//        }
//
//    }
