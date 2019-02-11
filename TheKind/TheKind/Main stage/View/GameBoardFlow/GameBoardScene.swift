//
//  GameBoardScene.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 11/5/18.
//  Copyright © 2018 tenny. All rights reserved.
//
// TOMORROW: Start with Directed Zoom feature.

import UIKit
import SpriteKit

class GameBoardScene: SKScene {

    var lastCamScale: CGFloat?
    var maxZoomOutLimit: CGFloat?
    var maxZoomInLimit: CGFloat?
    var maxPan: CGPoint!
    var tileMapSize: CGSize?
    var kindTilemap: SKTileMapNode!
    var backgroundTileMap: SKTileMapNode!
    var kindTiles:KindTile!
    
    //Initializes all zoom variables.
    var initCamScale: CGFloat? {
        didSet {
            maxZoomOutLimit = initCamScale! * 3
            maxZoomInLimit = initCamScale! / 2.5
            lastCamScale = initCamScale!
        }
    }
    
    
    override func sceneDidLoad() {

        
    }
    
    
    func initializeTileMaps() {
        guard let tileMap = self.childNode(withName: "GameBoardTileMap") as? SKTileMapNode else {fatalError("TileMap Set not found")}
        guard let backGroundMap = self.childNode(withName: "BackgroundTileMap") as? SKTileMapNode else {fatalError("TileMap Set not found")}
        kindTilemap = tileMap
        backgroundTileMap = backGroundMap
    }
    
    func setupCamera(tileMap: SKTileMapNode) {
        tileMapSize = tileMap.mapSize
        scene!.size = CGSize(width: tileMapSize!.width + 30, height: tileMapSize!.height + 30) // 30 is to add a "cushion" to give the cards breathing space.
        if let camera = scene?.childNode(withName: "camera") as? SKCameraNode {
            let numberOfColumns: CGFloat = CGFloat(tileMap.numberOfColumns)
            // Zoom is relative to the size of the map. Currently showing 4 cards (fator = 6).
            initCamScale = 6/numberOfColumns
            camera.setScale(maxZoomOutLimit!*2)
            self.camera = camera
            changeCameraZoom(camera: camera, scale: initCamScale!)
        }
    }
        
    override func didMove(to view: SKView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(withSender:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchFrom(withSender:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(withSender:)))
        
        self.view?.addGestureRecognizer(panGestureRecognizer)
        self.view?.addGestureRecognizer(pinchGestureRecognizer)
        self.view?.addGestureRecognizer(tapGestureRecognizer)
        
        initializeTileMaps()
        kindTiles = KindTile()
        setupTileMap(tileMap: kindTilemap)
        setupTileMap(tileMap: backgroundTileMap)
        setupCamera(tileMap: kindTilemap)
        spawnKinds()
        layoutBoard()
        placeKind(colum: 0,row: 0, kind: kindTiles.visionary!)
    }
    
    func setupTileMap(tileMap: SKTileMapNode) {
        let columns = 24
        let rows = 24
        let size = CGSize(width: 56, height: 56)
        
        tileMap.tileSet = kindTiles.tileSet
        tileMap.numberOfColumns = columns
        tileMap.numberOfRows = rows
        tileMap.tileSize = size
        
    }
    
    func layoutBoard() {
        let columns = backgroundTileMap.numberOfColumns
        let rows = backgroundTileMap.numberOfRows
        for colum in 0..<columns {
            for row in 0..<rows {
                backgroundTileMap.setTileGroup(kindTiles.boardTile, forColumn: colum, row: row)
            }
        }
    }
    
    func spawnKinds() {
        let columns = kindTilemap.numberOfColumns
        let rows = kindTilemap.numberOfRows
        let kindtileArray: [SKTileGroup] = [kindTiles.visionary!,kindTiles.idealist!,kindTiles.leader!, kindTiles.mentor!, kindTiles.teamPlayer!, kindTiles.angel!, kindTiles.founder!, kindTiles.entertainer!,
                                                  kindTiles.rebel!, kindTiles.trailblazer!, kindTiles.explorer!, kindTiles.grinder!]
        
        for colum in 0..<columns {
            for row in 0..<rows {
                kindTilemap.setTileGroup(kindtileArray[Int.random(in: 0...11)], forColumn: colum, row: row)
            }
        }
    }
    
    func placeKind(colum: Int, row: Int, kind: SKTileGroup) {
        kindTilemap.setTileGroup(kind, forColumn: colum, row: row)
    }
    
}



class KindTile {
    var leader: SKTileGroup?
    var idealist: SKTileGroup?
    var visionary: SKTileGroup?
    var mentor: SKTileGroup?
    var teamPlayer: SKTileGroup?
    var founder: SKTileGroup?
    var angel: SKTileGroup?
    var boardTile: SKTileGroup?
    var entertainer: SKTileGroup?
    var rebel: SKTileGroup?
    var trailblazer: SKTileGroup?
    var explorer: SKTileGroup?
    var grinder: SKTileGroup?
    var tileSet: SKTileSet!
    
    init() {
        guard let set = SKTileSet(named: "thedeckSet") else {fatalError("Object Tiles Tile Set not found")}
        tileSet = set
        
        guard let leader = set.tileGroups.first(where: {$0.name == "leader"}) else {fatalError("No Duck tile definition found")}
        self.leader = leader
        
        guard let idealist = set.tileGroups.first(where: {$0.name == "idealist"}) else {fatalError("No Duck tile definition found")}
        self.idealist = idealist
        
        guard let catalyst = set.tileGroups.first(where: {$0.name == "visionary"}) else {fatalError("No Duck tile definition found")}
        
        self.visionary = catalyst
        
        guard let mentor = set.tileGroups.first(where: {$0.name == "mentor"}) else {fatalError("No Duck tile definition found")}
        
        self.mentor = mentor
        
        guard let teamPlayer = set.tileGroups.first(where: {$0.name == "team_player"}) else {fatalError("No Duck tile definition found")}
        
        self.teamPlayer = teamPlayer
        
        guard let angel = set.tileGroups.first(where: {$0.name == "angel"}) else {fatalError("No Duck tile definition found")}
        
        self.angel = angel
        
        guard let founder = set.tileGroups.first(where: {$0.name == "founder"}) else {fatalError("No Duck tile definition found")}
        
        self.founder = founder
        
        guard let entertainer = set.tileGroups.first(where: {$0.name == "entertainer"}) else {fatalError("No Duck tile definition found")}
        
        self.entertainer = entertainer
        
        guard let rebel = set.tileGroups.first(where: {$0.name == "rebel"}) else {fatalError("No Duck tile definition found")}
        
        self.rebel = rebel
        
        guard let trailblazer = set.tileGroups.first(where: {$0.name == "trailblazer"}) else {fatalError("No Duck tile definition found")}
        
        self.trailblazer = trailblazer
        
        guard let explorer = set.tileGroups.first(where: {$0.name == "explorer"}) else {fatalError("No Duck tile definition found")}
        
        self.explorer = explorer
        
        guard let grinder = set.tileGroups.first(where: {$0.name == "grinder"}) else {fatalError("No Duck tile definition found")}
        
        self.grinder = grinder
        
        guard let boardTile = set.tileGroups.first(where: {$0.name == "boardtile"}) else {fatalError("No Duck tile definition found")}
        
        self.boardTile = boardTile

    }
}

//CHecking if tile is of type.
//var backgroundLayer: SKTileMapNode!
//
//override func didMove(to view: SKView) {
//    guard let backgroundLayer = childNode(withName: "background") as? SKTileMapNode else {
//        fatalError("Background node not loaded")
//    }
//
//    self.backgroundLayer = backgroundLayer
//
//    for row in 0..<self.backgroundLayer.numberOfRows {
//        for column in 0..<self.backgroundLayer.numberOfColumns {
//            let backgroundTile = self.backgroundLayer.tileDefinition(atColumn: column, row: row)
//            let isPoison = backgroundTile?.userData?.value(forKey: "isPoisonKey")
//
//            if let countNode = isPoison as? Bool {
//                // Code here
//                if countNode {
//                    print(countNode)
//                }
//            }
//        }
//    }
//}
