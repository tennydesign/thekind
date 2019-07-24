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

enum DeckTypeEnum {
    case userKindDeck, deadPileDeck
}
//enum DeckCardAutomationEnum {
//    case newlyCreated,
//}

class KindDeckManagement {
    
    //Singleton
    static let sharedInstance = KindDeckManagement()
    var userKindDeck: DeckToEmmit = DeckToEmmit(deck: [])
    var deadPileDeck: DeckToEmmit = DeckToEmmit(deck: [])
    var deckPublisher: PublishSubject<[Int]> = PublishSubject()
    var disposeBag = DisposeBag()
    var deckObserver: Observable<[Int]> {
        return deckPublisher.asObservable()
    }
    
    var mainKindPublisher: PublishSubject<Int?> = PublishSubject()
    
    var mainKindObserver: Observable<Int?> {
        return mainKindPublisher.asObservable()
    }
    
    var userMainKind: Int?
 
    var isBrowsingAnotherUserKindDeck = false // This is used to change the behaviour of the browsing kinds screen. Todo: Find a better automatic flagger condition to this.
    

    var kindsdict: [String: Any] {
        get {
            return ["userKindDeck": userKindDeck.deck]
        }
    }
    
    var deadPileDict: [String: Any] {
        get {
            return ["deadPileDeck": deadPileDeck.deck]
        }
    }

    
    
    private init() {
        mainKindObserverActivation()
    }
    
    // OBSERVERS
    func mainKindObserverActivation() {
        self.mainKindObserver.share()
            .subscribe(onNext: { [weak self] (kindId) in
                    self?.userMainKind = kindId
                    self?.updateMainKind { err in
                        if let err = err {
                            print(err)
                            return
                        }
                        print("update mainkind on deck completed")
                    }
            })
            .disposed(by: disposeBag)
        
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
            }
            
            if let deadPileDeck = data["deadPileDeck"] as? [Int] {
                self.deadPileDeck.deck = deadPileDeck
                //this is not bing used.
                self.deckPublisher.onNext(self.deadPileDeck.deck)
            }
            
            if let mainkind = data["userMainKind"] as? Int {
                if self.userMainKind != mainkind {
                    self.userMainKind = mainkind
                }
            }
            
            
        }
    }
    
    //KINDDECKS
 
    func resetDeadPileDeck() {
        deadPileDeck.deck = []
        updateKindDeck(type: .deadPileDeck) { (err) in
            if let err = err {
                print(err)
                return
            }
        }
    }
    
    func updateKindDeck(type: DeckTypeEnum, completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        switch type {
        case .userKindDeck:
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
        case .deadPileDeck:
            db.collection(KindDeckDocument.alldecks.rawValue).document(uid).updateData(deadPileDict) { (err) in
                if let err = err {
                    if err.localizedDescription.contains("No document to update") {
                        //Create deck from scratch
                        self.createDeadPileDeck(completion: { (err) in
                            if let err = err {
                                print(err)
                                completion?(err)
                            }
                            //print("New dead Deck Document created successfully")
                            completion?(nil)
                             self.deckPublisher.onNext([-1])
                            return
                            
                        })
                        
                    }
                } else {
                    //print(" Kind dead Deck Document updated successfully")
                    completion?(nil)
                }
                
            }

        }
    }
    
    
    
    //Private functions
    
    fileprivate func cleanPreviousMainKindsFromDeck() {
        let twelveMainKinds = GameKinds.twelveKindsOriginalArray.map {$0.kindId.rawValue}
        userKindDeck.deck = userKindDeck.deck.filter { !twelveMainKinds.contains($0) }
    }
    
    
    fileprivate func createUserKindDeck(completion: ((Error?)->())?) {
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
    
    fileprivate func createDeadPileDeck(completion: ((Error?)->())?) {
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
    
    fileprivate func updateMainKind(completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        guard let mainkind = userMainKind else {return}
        
        let mainKindDict = ["userMainKind":mainkind]
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection(KindDeckDocument.alldecks.rawValue).document(uid).updateData(mainKindDict) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //create if inexistent
                    db.collection(KindDeckDocument.alldecks.rawValue).document(uid).setData(mainKindDict, completion: { (err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        completion?(nil)
                    })
                }
            }
            // Now add it to the deck.
            self.safeAddMainKindToDeck(kindID: mainkind, completion: { (success) in
                completion?(nil) // <- this completes saveMainKind
            })
            
        }
        
    }
    
    fileprivate func safeAddMainKindToDeck(kindID: Int, completion:@escaping (Bool)->()) {
        let twelveMainKinds = GameKinds.twelveKindsOriginalArray.map {$0.kindId.rawValue}
        // This will delete the previous mainKind in the deck.
        if twelveMainKinds.contains(kindID) {
            cleanPreviousMainKindsFromDeck()
        }
        //This will add the new mainKind to the deck.
        if !userKindDeck.deck.contains(kindID) {
            userKindDeck.deck.append(kindID)
            self.updateKindDeck(type: .userKindDeck) { (err) in
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

}

