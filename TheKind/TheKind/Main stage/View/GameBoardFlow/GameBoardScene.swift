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
    var panGestureRecognizer = UIPanGestureRecognizer()
    var pinchGestureRecognizer = UIPinchGestureRecognizer()
    var tapGestureRecognizer = UITapGestureRecognizer()
    var isPanning:Bool = false
    var sceneCamera: SKCameraNode!
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox? {
        didSet {
            gameControllerView.talkbox = self.talkbox
            kindMatchControlView.talkbox = self.talkbox
        }
    }
    
    //View to control board KindActtionTriggerProtocol
    let gameControllerView = GameBoardSceneControlView()
    let kindMatchControlView = KindMatchControl()
    //Initializes all zoom variables.
    var initCamScale: CGFloat? {
        didSet {
            maxZoomOutLimit = initCamScale! * 3
            maxZoomInLimit = initCamScale! / 2.5
            lastCamScale = initCamScale!
        }
    }
        
    override func didMove(to view: SKView) {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(withSender:)))
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchFrom(withSender:)))
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(withSender:)))
        
        self.view?.addGestureRecognizer(panGestureRecognizer)
        self.view?.addGestureRecognizer(pinchGestureRecognizer)
        self.view?.addGestureRecognizer(tapGestureRecognizer)
        
        
        gameControllerView.delegate = self
        kindMatchControlView.delegate = self
        self.view?.addSubview(gameControllerView)
        self.view?.addSubview(kindMatchControlView)
        // read the scene and load maps
        initializeTileMaps()
        
        // read the tile kit file and load tiles
        kindTiles = KindTile()
        
        // config kindTileMap
        setupTileMap(tileMap: kindTilemap, rows: 24, columns: 24, tileSize: CGSize(width: 56, height: 56))
        
        // config background map.
        setupTileMap(tileMap: backgroundTileMap, rows: 24, columns: 24, tileSize: CGSize(width: 56, height: 56))
        
        // setup size of the scene based on size of tilemap.
        scene!.size = kindTilemap.mapSize
        
        // setup camera on KindTile Map
        setupCamera(tileMap: kindTilemap)
        
        // install tiles
        layBackgroundBoardTiles()
        spawnKindsRandomly()
        

        
    }
    
    //fires when routine has finished posted
    func routingPostingObserver() {
        mainViewController?.jungChatLogger.routineHasPosted = { [unowned self] in
            self.tapGestureRecognizer.isEnabled = true
        }
    }
    
    
    func initializeTileMaps() {
        guard let tileMap = self.childNode(withName: "GameBoardTileMap") as? SKTileMapNode else {fatalError("TileMap Set not found")}
        guard let backGroundMap = self.childNode(withName: "BackgroundTileMap") as? SKTileMapNode else {fatalError("TileMap Set not found")}
        kindTilemap = tileMap
        backgroundTileMap = backGroundMap
    }
    
    func setupTileMap(tileMap: SKTileMapNode, rows: Int, columns: Int, tileSize: CGSize) {
        tileMap.tileSet = kindTiles.tileSet
        tileMap.numberOfColumns = columns
        tileMap.numberOfRows = rows
        tileMap.tileSize = tileSize
        
    }
    
    func setupCamera(tileMap: SKTileMapNode) {
        if let camera = scene?.childNode(withName: "camera") as? SKCameraNode {
            // Zoom is relative to the size of the map.
            let numberOfColumns: CGFloat = CGFloat(tileMap.numberOfColumns)
            initCamScale = 6/numberOfColumns
            camera.setScale(maxZoomOutLimit!*2)
            self.camera = camera
            changeCameraZoom(camera: camera, scale: initCamScale!)
            sceneCamera = camera
        }
    }
    
    func layBackgroundBoardTiles() {
        let columns = backgroundTileMap.numberOfColumns
        let rows = backgroundTileMap.numberOfRows
        for colum in 0..<columns {
            for row in 0..<rows {
                backgroundTileMap.setTileGroup(kindTiles.boardTile, forColumn: colum, row: row)
            }
        }
    }
    
    func spawnKindsRandomly() {
        let columns = kindTilemap.numberOfColumns
        let rows = kindTilemap.numberOfRows
        let kindtileArray: [SKTileGroup] = kindTiles.kinds
        
        
        for colum in 0..<columns {
            for row in 0..<rows {
                kindTilemap.setTileGroup(kindtileArray[Int.random(in: 0...11)], forColumn: colum, row: row)
            }
        }
    }
    
}
