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

    var keyboardHeight:CGFloat!
    @IBOutlet var searchView: UIView!
    var addUserFlag = false
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    let searchViewModel = SearchViewModel()
    
    var data:[UserUnitSearch]!
    
    var filteredData: [UserUnitSearch]!
    
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
        filteredData = data
        
        setupKeyboardObservers()
        searchTableView.rowHeight = 89
        searchTableView.register(UINib(nibName: "UserSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "UserSearchTableViewCell")
        
        searchTableView.register(UINib(nibName: "AddNewUserTableViewCell", bundle: nil), forCellReuseIdentifier: "AddNewUserTableViewCell")
        
        
        let tapOutsideHandler = UITapGestureRecognizer(target: self, action: #selector(tapOutsideSearch))
        
        searchTableView.addGestureRecognizer(tapOutsideHandler)
        searchViewModel.retrieveAllUserForSearch { (completed) in
            if completed {
                print("great")
                self.data = self.searchViewModel.users + self.searchViewModel.users + self.searchViewModel.users + self.searchViewModel.users

                self.filteredData = self.data
                self.searchTableView.reloadData()
            }
        }

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
                    textField.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                    
                }
            }
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    
    @objc func tapOutsideSearch(sender: UITapGestureRecognizer) {
        searchBar.endEditing(true)

    }
    
//    override var inputAccessoryView: UIView? {
//        get {
//            
//            return inviteNewUserView
//        }
//    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData.count == 0 {
            addUserFlag = true
            return 1
        } else {
            addUserFlag = false
        }
        return filteredData.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        //cell.textLabel?.text = "teste"
        
        if !addUserFlag {
            let userFoundCell = tableView.dequeueReusableCell(withIdentifier: "UserSearchTableViewCell", for: indexPath) as! UserSearchTableViewCell
            userFoundCell.nameLabel.text = filteredData[indexPath.row].name
            if let photoUrl = filteredData[indexPath.row].photoURL {
                userFoundCell.userPhotoImageView.loadImageUsingCacheWithUrlString(urlString: photoUrl)
            }
            if let kind = filteredData[indexPath.row].kind {
                if let kind = GameKinds.createKindCard(id: kind) {
                    userFoundCell.kindImageView.image = UIImage(named: kind.iconImageName.rawValue)
                    userFoundCell.kindTypeLabel.text = kind.kindName.rawValue
                }
            }
            userFoundCell.delegate = self
            cell = userFoundCell
        } else {
            let addUsercell = tableView.dequeueReusableCell(withIdentifier: "AddNewUserTableViewCell", for: indexPath) as! AddNewUserTableViewCell
            cell = addUsercell
        }
        print("Contador: \(filteredData.count)")
        return cell!
    }

    

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included

        if !addUserFlag {
        filteredData = searchText.isEmpty ? data : data.filter({(user) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return user.name?.range(of: searchText, options: .caseInsensitive) != nil
        })
        } else {
            let indexPath = IndexPath(item: 0, section: 0)
            let cell = searchTableView.cellForRow(at: indexPath) as! AddNewUserTableViewCell
            cell.addUserEmailLabel.text = searchText
        }
        
        
        searchTableView.reloadData()
    }

    func retrieveuAllUsersFromFirestore() {
        //Todo: This has to be optimized to something smarter when we scale.
        
    }
    
    func addRemoveClicked(_ sender: UserSearchTableViewCell) {
        guard let tappedIndexPath = searchTableView.indexPath(for: sender) else {return}
        print("clicked at \(tappedIndexPath)")
    }
}
