//
//  ListCircleView.swift
//  TheKind
//
//  Created by Tenny on 5/17/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

protocol ListCircleViewProtocol {
    func goToCircleAndActivateIt(circleId: String)
}

class ListCircleView: KindActionTriggerView, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var circleListTableView: UITableView!
    var circleSets: [CircleAnnotationSet] = []
    
    var filteredCircleSets: [CircleAnnotationSet] = [] {
        didSet {
            circleListTableView.reloadData()
        }
    }
    
    @IBOutlet var mainView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    var delegate: ListCircleViewProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ListCircleView", owner: self, options: nil)
        addSubview(mainView)
        circleListTableView.delegate = self
        circleListTableView.dataSource = self
        searchBar.delegate = self
        
        circleListTableView.rowHeight = 113
        
        circleListTableView.register(UINib(nibName: "CircleListTableViewCell", bundle: nil), forCellReuseIdentifier: "CircleListTableViewCell")
        
        CircleAnnotationManagement.sharedInstance.updateCircleListOnMapPlotUnplot = { [unowned self] in
            self.reloadCircleList()
        }
        
    }
    
    func reloadCircleList() {
        filteredCircleSets = CircleAnnotationManagement.sharedInstance.visibleCircles
        circleListTableView.reloadData()
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
    override func activate() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        })
        
        filteredCircleSets = CircleAnnotationManagement.sharedInstance.visibleCircles
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCircleSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CircleListTableViewCell", for: indexPath) as! CircleListTableViewCell
        cell.set = self.filteredCircleSets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked table")
        delegate?.goToCircleAndActivateIt(circleId: self.circleSets[indexPath.row].circleId)
        searchBar.resignFirstResponder()
        self.deactivate()
    }
    
    override func deactivate() {
       self.alpha = 0
    }
    
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        self.deactivate()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchText == "" {
           self.filteredCircleSets = circleSets
            return
        }
        
        filteredCircleSets = circleSets.filter({( set : CircleAnnotationSet) -> Bool in
            return set.circlePlotName.lowercased().contains(searchText.lowercased())
        })
    }
    
}

//
//if let imageUrl = usersInCircle[indexPath.row].photoURL {
//    cell.userPhotoImageView.loadImageUsingCacheWithUrlString(urlString:imageUrl)
//}


