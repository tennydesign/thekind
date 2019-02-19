//
//  CardSwipeView.swift
//  TheKind
//
//  Created by Tenny on 2/14/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import Koloda

//HERE: IMPLEMENT OVERLAYS

class CardSwipeView: UIView {
    var kindsToSwipe: [UIImage] = [#imageLiteral(resourceName: "team_player"),#imageLiteral(resourceName: "explorer"),#imageLiteral(resourceName: "idealist"),#imageLiteral(resourceName: "rebel")]
    var currentlyShowingCard = UIImage()
    var kindsChosen : [UIImage] = [#imageLiteral(resourceName: "fire"),#imageLiteral(resourceName: "fire"), #imageLiteral(resourceName: "map"), #imageLiteral(resourceName: "chair"),#imageLiteral(resourceName: "map"),#imageLiteral(resourceName: "chair"),#imageLiteral(resourceName: "fire"),#imageLiteral(resourceName: "chair"),#imageLiteral(resourceName: "fire"),#imageLiteral(resourceName: "fire"),#imageLiteral(resourceName: "map"),#imageLiteral(resourceName: "fire")]
    // The selected (clocked on) kind of the chosenKindsCollectionView
    var kindsChosenSelectedIndex = -1
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    
    @IBOutlet var kolodaView: KolodaView!
    @IBOutlet var chosenKindsCollectionView: UICollectionView!
    
    @IBOutlet var mainView: UIView!
    
    var imageToShowIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("CardSwipeView", owner: self, options: nil)
        addSubview(mainView)
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        chosenKindsCollectionView.dataSource = self
        chosenKindsCollectionView.delegate = self
        kolodaView.appearanceAnimationDuration = 0.3
        kolodaView.reverseAnimationDuration = 0.1
        kolodaView.countOfVisibleCards = 1
        kolodaView.alphaValueSemiTransparent = 0
        chosenKindsCollectionView?.register(UINib(nibName: "ChosenKindCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChosenKindCollectionViewCell")

    
    
    }


}

extension CardSwipeView: KolodaViewDelegate {

    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        imageToShowIndex += 1
        imageToShowIndex = min(imageToShowIndex, kindsToSwipe.count)
        if imageToShowIndex == kindsToSwipe.count {
            imageToShowIndex = 0
        }
        koloda.resetCurrentCardIndex()

    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == SwipeResultDirection.left {
            kindsChosen.insert(currentlyShowingCard, at: 0)

            let indexPath = IndexPath(item: 0, section: 0)
            chosenKindsCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            chosenKindsCollectionView.insertItems(at: [indexPath])
            //Attempts to change the image on the cell if cell is visible. It fails if user has scrolled the collectionview past (0,0) indexpath
            if let cell = chosenKindsCollectionView.cellForItem(at: indexPath) as? ChosenKindCollectionViewCell {
                cell.kindImageView.image = currentlyShowingCard.withRenderingMode(.alwaysTemplate)
                cell.kindImageView.tintColor = UIColor(r: 171, g: 171, b: 171)
            }

            // By reloading we are making sure the collectionview is updated with the chosenKind regardless if the let above has failed.
            chosenKindsCollectionView.reloadData()
        }
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.9
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
}

extension CardSwipeView: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 1
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        introduceKind()
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        // ============= load card from xib
        let customView = Bundle.main.loadNibNamed("KindSwipeView", owner: nil, options: nil)?.first as? KindSwipeView
        
        
        currentlyShowingCard = kindsToSwipe[imageToShowIndex]
//
//        // ============== change info inside card here
        customView?.imageView.image = currentlyShowingCard.withRenderingMode(.alwaysTemplate)
        customView?.imageView.tintColor = UIColor(r: 210, g: 183, b: 102)

        self.mainViewController?.jungChatLogger.resetJungChat()
        introduceKind()
        
        return customView!
    }
    

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func introduceKind() {
        let txt = "The Poet kind says:-There should be no filter between reality and emotions.-Life is a beautiful emotional rollercoaster.-Enjoy it while you can."
        let actions: [KindActionType] = [.none,.none,.none,.none]
        let actionViews: [ActionViewName] = [.none,.none,.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Keep it.", opt2: "Don't keep it.", actionView: self)
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))
    }

}

extension CardSwipeView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kindsChosen.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChosenKindCollectionViewCell", for: indexPath) as! ChosenKindCollectionViewCell
        cell.kindImageView.image = kindsChosen[indexPath.row].withRenderingMode(.alwaysTemplate)
        
        if kindsChosenSelectedIndex == indexPath.row {
            cell.kindImageView.tintColor = UIColor(r: 210, g: 183, b: 102)
        } else {
            cell.kindImageView.tintColor = UIColor(r: 171, g: 171, b: 171)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        kindsChosenSelectedIndex = indexPath.row
        collectionView.reloadData()

        //HERE: JUNG OFFERS TO REMOVE KIND.
        let txt = "The Poet kind says:-There should be no filter between reality and emotions."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Tell me more.", opt2: "Release kind.", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        guard let overlayView = Bundle.main.loadNibNamed("CustomSwipeOverlay", owner: self, options: nil)![0] as? CustomSwipeOverlay else {return nil}

        return overlayView
    }

    
}

extension CardSwipeView: KindActionTriggerViewProtocol {
    
    func talk() {
        
    }
    
    func activate() {
        
    }
    
    func deactivate() {
        
    }
    
    //HERE
    func rightOptionClicked() {
        let indexPath = IndexPath(item: kindsChosenSelectedIndex, section: 0)
        kindsChosen.remove(at: indexPath.row)
        chosenKindsCollectionView.deleteItems(at: [indexPath])
        chosenKindsCollectionView.reloadData()
        let txt = "Done."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: nil))
    }
    
    func leftOptionClicked() {
        let txt = "Life is like a rollercoaster.-The ups are high and the downs are low.-The rollercoaster of life is what makes it genuine, sensible, intense and worth living."
        let actions: [KindActionType] = [.none,.none,.none]
        let actionViews: [ActionViewName] = [.none,.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "Release kind.", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))
    }
    
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
    
    
}

