//
//  JungChatLogger.swift
//  TheKind
//
//  Created by Tenny on 27/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class JungChatLogger: KindActionTriggerView {

    
    @IBOutlet var jungChatLoggerCollectionView: UICollectionView!
    @IBOutlet var jungChatLogger: UIView!
    @IBOutlet var leftAnswerLabel: KindJungOptionLabel!
    @IBOutlet var rightAnswerLabel: KindJungOptionLabel!
    @IBOutlet var jungLoadingAnimator: NVActivityIndicatorView!

    @IBOutlet var mainView: UIView!
    @IBOutlet var HoldToAnswerViewWidthAnchor: NSLayoutConstraint!

    @IBOutlet var jungSymbolImageView: UIImageView!
    
    @IBOutlet var heightCollectionViewConsraint: NSLayoutConstraint!
    @IBOutlet var holdToAnswerBar: UIView!
    var mainViewController: MainViewController?
    
    
    let serialPostsQueue = DispatchQueue(label: "com.thekind.jungPosts")
    var messagesPipe: [String] = []
    
    //var animator: UIViewPropertyAnimator()
    var messagesCollection: [String] = [] {
        didSet {
            refreshAndScrollCollectionView()
        }
    }

    
    var mostRecentChatMessageIndex: Int {
        return jungChatLoggerCollectionView.numberOfItems(inSection: 0)  - 1
    }
   
    let targetStretcherValue: CGFloat = 46.0
    
    // This is setup on init by the main view controller.
    var talkbox: JungTalkBox! {
        didSet {
            // Setup Jung Listener
            messagesAndRoutinesObservers()
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
    
    private var gradient: CAGradientLayer!
    func commonInit() {
        Bundle.main.loadNibNamed("JungChatLogger", owner: self, options: nil)
        addSubview(jungChatLogger)
        
        setupGestures()
        
        //COLLECTION VIEW
        jungChatLoggerCollectionView.delegate = self
        jungChatLoggerCollectionView.dataSource = self
        jungChatLoggerCollectionView?.register(UINib(nibName: "JungChatBubbleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "JungChatBubbleCollectionViewCell")

        refreshAndScrollCollectionView()
        
        //PROGRESS VIEW
        resetAnswerViewWidthAnchor() // 46.0
        
        
        if self.messagesCollection.isEmpty {resetJungChat()}
  
        hideOptionLabels(true, completion: nil)

    
    }
    
    func resetAnswerViewWidthAnchor() {
        HoldToAnswerViewWidthAnchor.constant = targetStretcherValue
        layoutIfNeeded()
    }

    func resetJungChat() {
        self.messagesCollection = ["","","","","",""]
    }
    
    var animationCount: Int = 0
    var tempoInBetweenPosts: Double = 1
    var delayJungPostInSecs: Double = 0
    
    
    func hideOptionLabels(_ isHidden: Bool, completion: (()->())?) {
        if isHidden == false {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.leftAnswerLabel.alpha = 1
                self.rightAnswerLabel.alpha = 1
                self.holdToAnswerBar.alpha = 1
            }) { (completed) in
                guard let completion = completion else {return}
                completion()
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.leftAnswerLabel.alpha = 0
                self.rightAnswerLabel.alpha = 0
                self.holdToAnswerBar.alpha = 0
                
            }) { (completed) in
                guard let completion = completion else {return}
                completion()
            }
        }
    }
    
    fileprivate func messagesAndRoutinesObservers() {
        talkbox.injectRoutineMessageObserver = { [unowned self](jungRoutine) in
            
            guard let jungRoutine = jungRoutine as? JungRoutine else {return}
            var labelsUpdated = false
            // 1 - Hide labels.
            self.hideOptionLabels(true, completion: {
                // 2 - update (or don't touch) labels.
                labelsUpdated = self.updateOptionLabels(jungRoutine.userResponseOptions, rightLabel: self.rightAnswerLabel, leftLabel: self.leftAnswerLabel)
                
                // 2 - After label work is complete. Start and tempo the animator if Jung is chatting.
                if jungRoutine.sender == .Jung {
                    self.startLoadingAnimator(for: jungRoutine.snippets.count)
                    // gives animation a sec start appearance before posting starts.
                    delay(bySeconds: 0.5, closure: {
                        self.performPostsWithTimeInterval(jungRoutine) { (success) in
                            self.stopLoadingAnimator()
                            // release jung lock.
                            self.talkbox.isProcessingSpeech = false
                            if labelsUpdated {
                                self.hideOptionLabels(false, completion: nil)
                            }
                        }
                        
                    })
                }
                else if jungRoutine.sender == .Player { // POSTS IMMEDIATELY
                    guard let message = jungRoutine.snippets.first?.message,
                        let snippet = jungRoutine.snippets.first else {return}
                    
                    self.postMessageToJungChat(message: message)
                    self.talkbox.executeSnippetAction(snippet)
                    // release jung lock.
                    self.talkbox.isProcessingSpeech = false
                    if labelsUpdated {
                        self.hideOptionLabels(false, completion: nil)
                    }
                    
                }
            })
 
        }
        
    }
    
    fileprivate func performPostsWithTimeInterval(_ jungRoutine: JungRoutine,
                                                  timeInterval: Double? = nil,
                                                  delayBeginning: Double? = nil,
                                                  completion: ((Bool)->())?) {
        
    
        jungRoutine.snippets.forEach { (snippet) in
            messagesPipe.append(snippet.message)
        }
        
        print(messagesPipe)
        
        var snippets: [Snippet] = jungRoutine.snippets
        var messageIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: timeInterval ?? self.tempoInBetweenPosts, repeats: true){ t in
            
            if !snippets[messageIndex].message.isEmpty {
                self.postMessageToJungChat(message: snippets[messageIndex].message)
            }
            
            self.talkbox.executeSnippetAction(snippets[messageIndex])
            self.animationCount -= 1
            // 3 - Stops timer
            if messageIndex == snippets.count-1 {
                if let completion = completion {
                    completion(true)
                }
                t.invalidate()
            }
            
            messageIndex = min(messageIndex+1, snippets.count-1)
            
        }
    }
    
    func stopLoadingAnimator() {
        
        if self.animationCount == 0 {
            if let transform = self.jungSymbolImageView.layer.presentation()?.transform {
                self.jungSymbolImageView.layer.removeAllAnimations()
                self.jungSymbolImageView.layer.transform = transform
            }
            self.jungLoadingAnimator.stopAnimating()
        }
    }
    
    func startLoadingAnimator(for count: Int) {
        self.animationCount += count
        if !jungLoadingAnimator.isAnimating {
            let rotate = CABasicAnimation(keyPath: "transform.rotation")
            rotate.byValue = 2 * CGFloat.pi
            rotate.duration = 4
            rotate.repeatCount = .greatestFiniteMagnitude
            self.jungSymbolImageView.layer.add(rotate, forKey: nil)
            jungLoadingAnimator.startAnimating()
        }
    }
    
    func updateJungRotationPosition() {
        if let presentation = self.jungSymbolImageView.layer.presentation() {
            let transform = presentation.transform
            self.jungSymbolImageView.layer.transform = transform
        }
    }

  

    fileprivate func postWithFailSafeBarControl(_ userResponseOption: Snippet?) {
        
        HoldToAnswerViewWidthAnchor.constant = 0//targetStretcherValue
       // starts to expand
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
            // post message only if indicator is full.
            if self.HoldToAnswerViewWidthAnchor.constant == 0{//self.targetStretcherValue {
                self.holdToAnswerBar.alpha = 0
                guard let snippet = userResponseOption else {return}
                // retrieve and display routine for Option chosen
                self.talkbox.displayRoutine(for: snippet)
            }
        }
        
    }
    
    
    
    // This updates the collectionview
    fileprivate func postMessageToJungChat(message: String) {
        // do not post empty strings
        if !message.isEmpty {
            //HERE:
            self.messagesCollection.append(message)
        }
    }
    
    // UI elements =====
    @objc func handleAnswerLongPress(longPress: UILongPressGestureRecognizer) {
        
        switch (longPress.state) {
        case .began:
            if let label = longPress.view as? KindJungOptionLabel {
                postWithFailSafeBarControl(label.userResponseOptionSnippet)
            }
        case .ended:
            // animate holder back to zero on lift.
            self.HoldToAnswerViewWidthAnchor.constant = targetStretcherValue//0
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        default:
            ()
        }
    }

    
    
    fileprivate func setupGestures() {
        //ANSWER LABELS
        leftAnswerLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleAnswerLongPress)))
        rightAnswerLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleAnswerLongPress)))
    }
    
    fileprivate func updateOptionLabels(_ userResponseOptions: (Snippet,Snippet)?, rightLabel: KindJungOptionLabel, leftLabel: KindJungOptionLabel) -> Bool {
        guard let userResponseOptions = userResponseOptions else {return false}
        
        leftLabel.userResponseOptionSnippet = userResponseOptions.0
        rightLabel.userResponseOptionSnippet = userResponseOptions.1
        rightLabel.attributedText = formatLabelTextWithLineSpacing(text: userResponseOptions.1.message)
        leftLabel.attributedText = formatLabelTextWithLineSpacing(text: userResponseOptions.0.message)
        rightLabel.userOptionId = userResponseOptions.1.id
        leftLabel.userOptionId = userResponseOptions.0.id
        rightLabel.actionView = userResponseOptions.1.actionView
        leftLabel.actionView = userResponseOptions.0.actionView
        rightLabel.action = userResponseOptions.1.action
        leftLabel.action = userResponseOptions.0.action
        
        return true
    }

}


//===============================
// UI CONTROLS AND COLLECTION VIEW
//===============================

extension JungChatLogger: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // HAS TO BE MIN OF 4 TO ACCOMODATE PLACEHOLDERS TO START COLLECTION VIEW FROM THE BOTTOM ON FIRST MESSAGE
        return messagesCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JungChatBubbleCollectionViewCell", for: indexPath) as! JungChatBubbleCollectionViewCell


        cell.chatLineLabel.attributedText = formatJungChatBubbleText(text: messagesCollection[indexPath.row])
        cell.alpha = alphaMessageRatio(indexPath: indexPath)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var rowSize: CGSize = CGSize(width: collectionView.frame.width, height: 55)
        let boundaries:CGRect = estimateFrameFromText(messagesCollection[indexPath.row], bounding: rowSize, fontSize: 11, fontName: PRIMARYFONT)
        rowSize = CGSize(width: collectionView.frame.width, height: boundaries.size.height + 10)

        return rowSize
    }
    
    
    func scrollCollectionViewToRecentMessage() {
        let indexPath = IndexPath(row: mostRecentChatMessageIndex, section: 0)
        jungChatLoggerCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func refreshAndScrollCollectionView() {
        //DispatchQueue.main.async {
            self.jungChatLoggerCollectionView.reloadData()
            self.scrollCollectionViewToRecentMessage()
        //}
    }

    

    func formatJungChatBubbleText(text: String) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.2 
        paragraphStyle.hyphenationFactor = 1
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
        
        // Color if its player's text.
        if text == leftAnswerLabel.attributedText?.string || text == rightAnswerLabel.attributedText?.string {
            attr.addAttribute(.foregroundColor, value: UIColor(r: 230, g: 37, b: 101), range: NSMakeRange(0, attr.length))
        }
        
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
        
        return attr
    }

    
    func alphaMessageRatio(indexPath: IndexPath) -> CGFloat {
    
        if (indexPath.row == mostRecentChatMessageIndex)
        {
            return 1
        } else if (indexPath.row == mostRecentChatMessageIndex - 1) {
            return 0.6
        } else if (indexPath.row == mostRecentChatMessageIndex - 2){
            return 0.4
        } else {
            return 0
        }
    }
    
}

