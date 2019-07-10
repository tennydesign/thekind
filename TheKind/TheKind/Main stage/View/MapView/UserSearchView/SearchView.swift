//
//  Search.swift
//  TheKind
//
//  Created by Tenny on 4/23/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit



class SearchView: KindActionTriggerView, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UserSearchViewCellDelegate, UITextFieldDelegate {

    //var mapActionTriggerView: MapActionTriggerView?
    var keyboardHeight:CGFloat!
    @IBOutlet var searchView: UIView!
    var addUserMode = false
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var isValidNewUserEmail: Bool = false

    var data:[KindUser] = []

    var filteredData: [KindUser] = [] {
        didSet {
            searchTableView.reloadData()
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SearchView", owner: self, options: nil)
        addSubview(searchView)

        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchBar.delegate = self
        setupKeyboardObservers()
        searchTableView.rowHeight = 89
        
        searchTableView.register(UINib(nibName: "UserSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "UserSearchTableViewCell")
        
        searchTableView.register(UINib(nibName: "AddNewUserTableViewCell", bundle: nil), forCellReuseIdentifier: "AddNewUserTableViewCell")
        
        
        let tapOutsideHandler = UITapGestureRecognizer(target: self, action: #selector(tapOutsideSearch))
        
        searchTableView.addGestureRecognizer(tapOutsideHandler)


    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
    
    @objc func handleKeyboardDidHide(notification: Notification) {

    }
    
    
    override func layoutSubviews() {
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UITextField.self) {
                    let textField: UITextField = subview as! UITextField
                    textField.backgroundColor = FULLWHITECOLOR
                    textField.autocapitalizationType = .none
                    //textField.borderStyle = .line
                    
                }
            }
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    
    @objc func tapOutsideSearch(sender: UITapGestureRecognizer) {
        searchBar.endEditing(true)

    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData.count == 0 {
            addUserMode = true
            return 1
        } else {
            addUserMode = false
        }
        return filteredData.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        //cell.textLabel?.text = "teste"
        
        if !addUserMode { // user found. Cell will show current user.
            
            let userFoundCell = tableView.dequeueReusableCell(withIdentifier: "UserSearchTableViewCell", for: indexPath) as! UserSearchTableViewCell
            
            userFoundCell.user = filteredData[indexPath.row]
            userFoundCell.delegate = self
            if let userId = filteredData[indexPath.row].uid {
                toggleBtnForShow(userId, userFoundCell)
            }

            cell = userFoundCell
            
        } else { // user not found. Cell will show btn to add user.
            let addUsercell = tableView.dequeueReusableCell(withIdentifier: "AddNewUserTableViewCell", for: indexPath) as! AddNewUserTableViewCell
            
            if !isValidNewUserEmail {
                addUsercell.inviteUserButton.disableButton()
            } else {
                addUsercell.inviteUserButton.enableButton()
            }
            
            cell = addUsercell
        }
        
        return cell!
    }
    
    fileprivate func toggleBtnForShow(_ userId: String, _ userFoundCell: UserSearchTableViewCell) {
        CircleAnnotationManagement.sharedInstance.checkIfUserBelongsToCircle(userId: userId) { (userBelongs) in
            if let userBelongs = userBelongs {
                if userBelongs == true {
                    userFoundCell.addRemoveButton.setImage(UIImage(named: "addedIcon"), for: .normal)
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filteredData = []
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            self.isValidNewUserEmail = false
            self.filteredData = []
        }
        
        let keywords = searchText.lowercased()
        
        //this garanteee that the call is only sent when field matches email
        if keywords.isEmail() {
            var retrievedUser:KindUser?
            
            //super nice pattern for cancelling previous async calls.
            // with dispatchgroup.
            // leave when you find, but don't leave if you don't.
            // Group notify will only be executed if enters = leaves.
            let group = DispatchGroup()
            group.enter()
            //TODO: Use a throtle related publisher here.
            KindUserSettingsManager.sharedInstance.retrieveUserByKeyword(keyword: keywords) { (kindUser) in
                if let user = kindUser {
                    self.isValidNewUserEmail = false
                    retrievedUser = user
                    // leave group of calls if user is found (cancels previous calls)
                    group.leave()
                } else {
                    //don't leave.
                    self.isValidNewUserEmail = true
                    self.filteredData = []
                }
                
                group.notify(queue: .main) {
                    guard let retrievedUser = retrievedUser else {return}
                    //Only add if user has minimum setup: choosen kind.
                    if retrievedUser.kind != nil {
                        self.filteredData = [retrievedUser]
                    }
                }
            }
        } else {
            //Add code to search by name. Throtle
            self.isValidNewUserEmail = false
            self.filteredData = []
        }


    }

    func retrieveuAllUsersFromFirestore() {

    }
    
    
    func addRemoveUserClicked(_ sender: UserSearchTableViewCell) {
        guard let tappedIndexPath = searchTableView.indexPath(for: sender) else {return}
        if let cell = searchTableView.cellForRow(at: tappedIndexPath) as? UserSearchTableViewCell {
            guard let userId = cell.user?.uid else {return}
            let image = cell.addRemoveButton.image(for: .normal)
            
            if !CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation {
                // This will update Firestore triggering the observer to update the UI.
                
                if image == UIImage(named: "adduser") {
                    CircleAnnotationManagement.sharedInstance.addUserToCircle(userId: userId) {
                        self.searchTableView.reloadData()
                    }
                } else {
                    CircleAnnotationManagement.sharedInstance.removeUserFromCircle(userId: userId) {
                        self.searchTableView.reloadData()
                    }
                }
                
            } else {
                // This will not update Firestore just yet, just the SET for the circle.
                // Firestore will be updated on "SAVE" see actiontriggerview action "right clicked"

                if image == UIImage(named: "adduser") {
   
                    CircleAnnotationManagement.sharedInstance.addUserToTemporaryCircle(userId: userId) { (kindUser) in
                        if let kindUser = kindUser {
                            CircleAnnotationManagement.sharedInstance.userAddedToTemporaryCircleListCallback?(kindUser)
                            self.searchTableView.reloadData()
                        }
                    }
                } else {
                    CircleAnnotationManagement.sharedInstance.removeUserFromTemporaryCircle(userId: userId) { (kindUser) in
                        if let kindUser = kindUser {
                            CircleAnnotationManagement.sharedInstance.userRemovedFromTemporaryCircleListCallback?(kindUser)
                            self.searchTableView.reloadData()
                        }
                    }
                }
            }
            
        }
        print("clicked at \(tappedIndexPath)")
    }
    
    override func activate() {
        self.fadeInView()
        self.isValidNewUserEmail = false
        searchBar.text = ""
        filteredData = []
        
    }
    
    override func deactivate() {
        self.fadeOutView()
    }
    
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        self.deactivate()
    }
}



//    fileprivate func prepareBtnForShow(_ userId: String, _ userFoundCell: UserSearchTableViewCell) {
//        if !CircleAnnotationManagement.sharedInstance.isSelectedTemporaryCircleAnnotation {
//            CircleAnnotationManagement.sharedInstance.checkIfUserBelongsToCircle(userId: userId) { (userBelongs) in
//                if let userBelongs = userBelongs {
//                    if userBelongs == true {
//                        userFoundCell.addRemoveButton.setImage(UIImage(named: "addedIcon"), for: .normal)
//                    }
//                }
//            }
//        } else { //circle is temporary
//            CircleAnnotationManagement.sharedInstance.checkIfUserBelongsToTemporaryCircle(userId: userId) { (userBelongs) in
//                if let userBelongs = userBelongs {
//                    if userBelongs == true {
//                        userFoundCell.addRemoveButton.setImage(UIImage(named: "addedIcon"), for: .normal)
//                    }
//                }
//            }
//        }
//    }
