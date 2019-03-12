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

class KindDeckManagement {
    
    //Singleton
    static let sharedInstance = KindDeckManagement()
    var userKindDeck: [Int] = []
    var userMainKind: Int?
    
    //Computed properties.
    var kindsdict: [String: Any] {
        get {
            return ["userKindDeck": userKindDeck]
        }
    }

    
    //Reactive
    var updateDeckOnClient: (()->())?
    var updateMainKindOnClient: (()->())?
    
    private init() {}
 
    
    
    func initializeDeckObserver() {
        self.observeUserKindDeck()
    }
    
    
    //SAVE
    //KINDS
    func safeAddKindToDeck(kindID: Int, completion:@escaping (Bool)->()) {
        if !userKindDeck.contains(kindID) {
            userKindDeck.append(kindID)
            self.updateKindDeck { (err) in
                if let err = err {
                    print(err)
                    completion(false)
                }
                
                completion(true)
                return
            }
        } else {
            print("safeAddKindToDeck: kind already exist")
            completion(false)
        }
        
    }
    
    func updateKindDeck(completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).updateData(kindsdict) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //Create deck from scratch
                    self.createUserKindDeck(completion: { (err) in
                        if let err = err {
                            completion?(err)
                        }
                        print("New Kind Deck Document created successfully")
                        completion?(nil)
                        return
                        
                    })
                    
                }
            } else {
                print(" Kind Deck Document updated successfully")
                completion?(nil)
            }
            
        }
        
    }
    
    private func createUserKindDeck(completion: @escaping (Error?)->()) {
        let db = Firestore.firestore()
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).setData(kindsdict, merge: true, completion: { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        })
    }
    
    
    //SAVE
    //MAINKIND
    func saveMainKind(completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        guard let mainkind = userMainKind else {return}
        let mainKindDict = ["userMainKind":mainkind]
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).updateData(mainKindDict) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //create
                    self.createMainCardEntry(mainKindDict, completion: { (err) in
                        if let err = err {
                            completion?(err)
                        }
                        print("New main Kind Document created successfully")
                        self.safeAddKindToDeck(kindID: mainkind, completion: { (success) in
                            if success {
                                completion?(nil)
                                return
                            }
                        })
                    })
                }
                //If there is. Update.
                print("an existent main kind field was updated")
                self.safeAddKindToDeck(kindID: mainkind, completion: { (success) in
                    if success {
                        completion?(nil)
                        self.updateMainKindOnClient?()
                        return
                    }
                })
                
            }
        }
        
    }
    
    
    private func createMainCardEntry(_ mainKindDict: [String:Int], completion: @escaping (Error?)->()) {
        let db = Firestore.firestore()
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).setData(mainKindDict, completion: { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        })
    }
    
    
    
    //RETRIEVE
    func getCurrentUserDeck(completion:@escaping (Bool)->()) {
        let db = Firestore.firestore()
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).getDocument {  (document,err) in
            if let err = err {
                print(err)
                completion(false)
                return
            }
            guard let data = document?.data() else
            {
                print("no data")
                completion(false)
                return
            }
            
            guard let kindDeck = data["userKindDeck"] as? [Int] else {fatalError("couldn't return deck as [Int]")}
            self.userKindDeck = kindDeck
            completion(true)
            self.updateDeckOnClient?()


        }
        
    }
    

    //HERE: OBSERVE MAINKIND!
    func observeUserKindDeck() {
        let db = Firestore.firestore()
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).addSnapshotListener { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            guard let data = snapshot?.data() else {
                print("no snapshot data on observeUserKindDeck")
                return
            }
            
            //Only update client if (and where) there are differences.
            if let kindDeck = data["userKindDeck"] as? [Int] {
                if kindDeck != self.userKindDeck {
                    self.userKindDeck = kindDeck
                    self.updateDeckOnClient?()
                }
            }
            
            if let mainkind = data["userMainKind"] as? Int {
                if mainkind != self.userMainKind {
                    self.userMainKind = mainkind
                    self.updateMainKindOnClient?()
                }
            }

        }
    }
    
    
    
    //CREATE

}

