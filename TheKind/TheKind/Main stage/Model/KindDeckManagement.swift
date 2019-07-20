//
//  KindDeckManagement.swift
//  TheKind
//
//  Created by Tenny on 2/23/19.
//  Copyright © 2019 tenny. All rights reserved.
//
// TODO: HERE.

import Foundation
import Firebase
import FirebaseFirestore
import RxSwift
import RxRelay

//HERE BUILDING THIS
struct DeckToEmmit {
    var deck: [Int]
}

class KindDeckManagement {
    
    //Singleton
    static let sharedInstance = KindDeckManagement()
    var userKindDeck: DeckToEmmit = DeckToEmmit(deck: [])
    var deadPileDeck: DeckToEmmit = DeckToEmmit(deck: [])
    private var deckPublisher: PublishSubject<[Int]> = PublishSubject()
    
    var deckObserver: Observable<[Int]> {
        return deckPublisher.asObservable()
    }
    
    private var mainKindPublisher: PublishSubject<Int> = PublishSubject()
    
    var mainKindPObserver: Observable<Int> {
        return mainKindPublisher.asObservable()
    }
    
    var userMainKind: Int?
    var isMainKind: Bool {
        get {
            
            return true
        }
    }
    var isBrowsingAnotherUserKindDeck = false // This is used to change the behaviour of the browsing kinds screen. Todo: Find a better automatic flagger condition to this.
    

    var kindsdict: [String: Any] {
        get {
            return ["userKindDeck": userKindDeck.deck]
        }
    }

    

    var updateDeckOnClient: (()->())?
    var updateMainKindOnClient: (()->())?
    
    private init() {
        
    }
 

    
    func cleanPreviousMainKindsFromDeck() {
        let twelveMainKinds = GameKinds.twelveKindsOriginalArray.map {$0.kindId.rawValue}
        userKindDeck.deck = userKindDeck.deck.filter { !twelveMainKinds.contains($0) }
    }
    
    func updateKindDeck(completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection(KindDeckDocument.alldecks.rawValue).document(uid).updateData(kindsdict) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //Create deck from scratch
                    self.createUserKindDeck(completion: { (err) in
                        if let err = err {
                            print(err)
                            completion?(err)
                        }
                        //print("New Kind Deck Document created successfully")
                        completion?(nil)
                        return
                        
                    })
                    
                }
            } else {
                //print(" Kind Deck Document updated successfully")
                completion?(nil)
            }
            
        }
        
    }

    
    func safeAddMainKindToDeck(kindID: Int, completion:@escaping (Bool)->()) {
        let twelveMainKinds = GameKinds.twelveKindsOriginalArray.map {$0.kindId.rawValue}
        // This will delete the previous mainKind in the deck.
        if twelveMainKinds.contains(kindID) {
            cleanPreviousMainKindsFromDeck()
        }
        //This will add the new mainKind to the deck.
        if !userKindDeck.deck.contains(kindID) {
            userKindDeck.deck.append(kindID)
            self.updateKindDeck { (err) in
                if let err = err {
                    print(err)
                    completion(false)
                }
                
                completion(true)
                return
            }
        } else {
            print("safeAddKindToDeck: kind already exists")
            completion(false)
        }
        
    }
    
    
//    func addKindToDeck(kindId: Int, completion: (()->())?) {
//        let db = Firestore.firestore()
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let kindDeckRef = db.collection(KindDeckDocument.alldecks.rawValue).document(uid)
//        //ArrayUnion() adds elements to an array but only elements not already present.
//        kindDeckRef.updateData(["userKindDeck" : FieldValue.arrayUnion([kindId])]) { (err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            completion?()
//        }
//
//    }
    
//    func removeKindFromDeck(kindId: Int, completion: (()->())?) {
//        let db = Firestore.firestore()
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let circlesRef = db.collection("kindcircles").document(uid)
//        circlesRef.updateData(["userKindDeck" : FieldValue.arrayRemove([kindId])]) { (err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            completion?()
//        }
//    }
    
    
    private func createUserKindDeck(completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection(KindDeckDocument.alldecks.rawValue).document(uid).setData(kindsdict, merge: true, completion: { (err) in
            if let err = err {
                completion?(err)
                return
            }
            completion?(nil)
        })
    }
    
    private func createDeadPileDeck(completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection(KindDeckDocument.alldecks.rawValue).document(uid).setData(["deadPileDeck":""], merge: true, completion: { (err) in
            if let err = err {
                completion?(err)
                return
            }
            completion?(nil)
        })
    }
    
    
    //TODO: This function is only good for onboarding.
    //After this use safeAddMainKindToDeck() ... probably need refactoring.
    func saveMainKindOnboarding(completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        guard let mainkind = userMainKind else {return}
        
        let mainKindDict = ["userMainKind":mainkind]
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection(KindDeckDocument.alldecks.rawValue).document(uid).updateData(mainKindDict) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //create instead
                    self.createMainCardEntry(mainKindDict, completion: { (err) in
                        if let err = err {
                            completion?(err)
                        }
                    })
                }
            }
            // Now add it to the deck.
            self.safeAddMainKindToDeck(kindID: mainkind, completion: { (success) in
                self.updateMainKindOnClient?()
                completion?(nil) // <- this completes saveMainKind
            })
            
        }
        
    }
    
    
    
    private func createMainCardEntry(_ mainKindDict: [String:Int], completion: @escaping (Error?)->()) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection(KindDeckDocument.alldecks.rawValue).document(uid).setData(mainKindDict, completion: { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        })
    }
    

    func observeUserKindDeck() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        print("OBESERVER SET")
        db.collection(KindDeckDocument.alldecks.rawValue).document(uid).addSnapshotListener { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            guard let data = snapshot?.data() else {
                print("no snapshot data on observeUserKindDeck")
                return
            }
            
             print("OBESERVER FIRED")
            
            if let kindDeck = data["userKindDeck"] as? [Int] {
                self.userKindDeck.deck = kindDeck
                //this is not being used.
                self.deckPublisher.onNext(self.userKindDeck.deck)
            } else {
                //create
                self.createUserKindDeck { err in
                    self.userKindDeck.deck = []
                    if let err = err {
                        print(err)
                        return
                    }
                    self.deckPublisher.onNext([-2])
                    
                }
            }
            
            if let deadPileDeck = data["deadPileDeck"] as? [Int] {
                self.deadPileDeck.deck = deadPileDeck
                //this is not bing used.
                self.deckPublisher.onNext(self.deadPileDeck.deck)
            } else {
                //create
                self.createDeadPileDeck { err in
                    self.deadPileDeck.deck = []
                    if let err = err {
                        print(err)
                        return
                    }
                    self.deckPublisher.onNext([-1])
                    
                }
            }
            
            if let mainkind = data["userMainKind"] as? Int {
                self.userMainKind = mainkind
                self.updateMainKindOnClient?()
                self.mainKindPublisher.onNext(mainkind)
                
            }

        }
    }

}

