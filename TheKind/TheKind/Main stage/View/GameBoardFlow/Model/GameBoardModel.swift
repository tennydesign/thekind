//
//  GameBoardModel.swift
//  TheKind
//
//  Created by Tenny on 2/12/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol ControlGameBoardProtocol {
    func searchBoardAndFindKindToIntroduce()
}

class GameBoardSceneControlView: UIView, KindActionTriggerViewProtocol {
    func deactivate() {
        
    }
    
    var talkbox: JungTalkBox?
    var delegate: ControlGameBoardProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        tag = 201
    }
    
    func talk() {
        
    }
    
    func activate() {
        self.isHidden = false
        self.alpha = 1
    }
    
    func rightOptionClicked() {
        delegate?.searchBoardAndFindKindToIntroduce()
    }
    
    func leftOptionClicked() {
        
    }
    
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
    
    
}


class KindTile {
    var leader: SKTileGroup!
    var idealist: SKTileGroup!
    var visionary: SKTileGroup!
    var mentor: SKTileGroup!
    var teamPlayer: SKTileGroup!
    var founder: SKTileGroup!
    var angel: SKTileGroup!
    var boardTile: SKTileGroup!
    var entertainer: SKTileGroup!
    var rebel: SKTileGroup!
    var trailblazer: SKTileGroup!
    var explorer: SKTileGroup!
    var grinder: SKTileGroup!
    var tileSet: SKTileSet!
    var kinds: [SKTileGroup]!
    
    init() {
        guard let set = SKTileSet(named: "thedeckSet") else {fatalError("Object Tiles Tile Set not found")}
        tileSet = set
        
        guard let leader = set.tileGroups.first(where: {$0.name == "leader"}) else {fatalError("No leader tile definition found")}
        self.leader = leader
        
        guard let idealist = set.tileGroups.first(where: {$0.name == "idealist"}) else {fatalError("No idealist tile definition found")}
        self.idealist = idealist
        
        guard let visionary = set.tileGroups.first(where: {$0.name == "visionary"}) else {fatalError("No visionary tile definition found")}
        
        self.visionary = visionary
        
        guard let mentor = set.tileGroups.first(where: {$0.name == "mentor"}) else {fatalError("No mentor tile definition found")}
        
        self.mentor = mentor
        
        guard let teamPlayer = set.tileGroups.first(where: {$0.name == "team_player"}) else {fatalError("No teamPlayer tile definition found")}
        
        self.teamPlayer = teamPlayer
        
        guard let angel = set.tileGroups.first(where: {$0.name == "angel"}) else {fatalError("No angel tile definition found")}
        
        self.angel = angel
        
        guard let founder = set.tileGroups.first(where: {$0.name == "founder"}) else {fatalError("No founder tile definition found")}
        
        self.founder = founder
        
        guard let entertainer = set.tileGroups.first(where: {$0.name == "entertainer"}) else {fatalError("No entertainer tile definition found")}
        
        self.entertainer = entertainer
        
        guard let rebel = set.tileGroups.first(where: {$0.name == "rebel"}) else {fatalError("No rebel tile definition found")}
        
        self.rebel = rebel
        
        guard let trailblazer = set.tileGroups.first(where: {$0.name == "trailblazer"}) else {fatalError("No trailblazer tile definition found")}
        
        self.trailblazer = trailblazer
        
        guard let explorer = set.tileGroups.first(where: {$0.name == "explorer"}) else {fatalError("No explorer tile definition found")}
        
        self.explorer = explorer
        
        guard let grinder = set.tileGroups.first(where: {$0.name == "grinder"}) else {fatalError("No grinder tile definition found")}
        
        self.grinder = grinder
        
        guard let boardTile = set.tileGroups.first(where: {$0.name == "boardtile"}) else {fatalError("No boardTile tile definition found")}
        
        self.boardTile = boardTile
        self.kinds = [leader,grinder,explorer,trailblazer,rebel,entertainer,founder,angel,teamPlayer,mentor,visionary,idealist]
        
    }
}
