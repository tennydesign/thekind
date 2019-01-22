//
//  JungChatLogger.swift
//  TheKind
//
//  Created by Tenny on 27/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class JungChatLogger: UIView {

    
    @IBOutlet var jungChatLoggerCollectionView: UICollectionView!
    @IBOutlet var jungChatLogger: UIView!
    @IBOutlet var leftAnswerLabel: KindJungOptionLabel!
    @IBOutlet var rightAnswerLabel: KindJungOptionLabel!
    @IBOutlet var jungLoadingAnimator: NVActivityIndicatorView!

    @IBOutlet var mainView: UIView!
    @IBOutlet var HoldToAnswerViewWidthAnchor: NSLayoutConstraint!

    
    @IBOutlet var holdToAnswerBar: UIView!
    var mainViewController: MainViewController?
    
    var messagesPipe: [Int: String] = [:]

    var messagesCollection: [String] = [] {
        didSet {
            refreshAndScrollCollectionView()
        }
    }
    
    var mostRecentChatMessageIndex: Int {
        return jungChatLoggerCollectionView.numberOfItems(inSection: 0)  - 1
    }
   
    let targetStretcherValue: CGFloat = 40.0
    
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
    

    
    func commonInit() {
        Bundle.main.loadNibNamed("JungChatLogger", owner: self, options: nil)
        addSubview(jungChatLogger)

        jungChatLogger.frame = self.bounds
        jungChatLogger.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        setupGestures()
        
        //COLLECTION VIEW
        jungChatLoggerCollectionView.delegate = self
        jungChatLoggerCollectionView.dataSource = self
        jungChatLoggerCollectionView?.register(UINib(nibName: "JungChatBubbleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "JungChatBubbleCollectionViewCell")

        refreshAndScrollCollectionView()
        
        //PROGRESS VIEW
        HoldToAnswerViewWidthAnchor.constant = 0
        layoutIfNeeded()
        
        if self.messagesCollection.isEmpty {initializeJungChat()}
  
        hideOptionLabels(true, completion: nil)
    
    }
    
    fileprivate func initializeJungChat() {
        self.messagesCollection = ["","","","","",""]
    }
    
    var animationCount: Int = 0
    var tempoInBetweenPosts: Double = 0.5
    var delayJungPostInSecs: Double = 0
    
    
    fileprivate func hideOptionLabels(_ isHidden: Bool, completion: (()->())?) {
        if isHidden == false {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.leftAnswerLabel.alpha = 1
                self.rightAnswerLabel.alpha = 1
                
            }) { (completed) in
                guard let completion = completion else {return}
                completion()
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.leftAnswerLabel.alpha = 0
                self.rightAnswerLabel.alpha = 0
                
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
                // 2 - update labels.
                labelsUpdated = self.updateOptionLabels(jungRoutine.userResponseOptions, rightLabel: self.rightAnswerLabel, leftLabel: self.leftAnswerLabel)
                
                // 2 - After label work is complete. Start and tempo the animator if Jung is chatting. This is to avoid Label concurrency (two routines coming fast with label pairs, it happened during tests).
                // It is unlikely it will happen in production as Jung's speech speed is much lower. But... this is 100% safe even for speeded up tests.
                
                if jungRoutine.sender == .Jung {
                    self.startLoadingAnimator(for: jungRoutine.snippets.count)
                    // gives animation a sec start appearance before posting starts.
                    delay(bySeconds: 0.5, closure: {
                        self.performPostsWithTimeInterval(jungRoutine) { (success) in
                            self.stopLoadingAnimator()
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
        var jungSnippets: [Snippet] = jungRoutine.snippets
        var messageIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: timeInterval ?? self.tempoInBetweenPosts, repeats: true){ t in
            
            self.postMessageToJungChat(message: jungSnippets[messageIndex].message)
            self.talkbox.executeSnippetAction(jungSnippets[messageIndex])
            self.animationCount -= 1
            // 3 - Stops timer
            if messageIndex == jungSnippets.count-1 {
                if let completion = completion {
                    completion(true)
                }
                t.invalidate()
            }
            
            messageIndex = min(messageIndex+1, jungSnippets.count-1)
            
        }
    }
    
    func stopLoadingAnimator() {
        if self.animationCount == 0 {
            delay(bySeconds: 0.3) {
                self.jungLoadingAnimator.stopAnimating()
            }
        }
    }
    
    func startLoadingAnimator(for count: Int) {
        self.animationCount += count
        if !jungLoadingAnimator.isAnimating {
            jungLoadingAnimator.startAnimating()
        }
    }
    

  
    
    // Time Between the user posted answer displayed and Jung's routine response.
    var timeSpanFromUserAnswer: Double = 2
    
    fileprivate func postWithFailSafeBarControl(_ userResponseOption: Snippet?) {
        
        HoldToAnswerViewWidthAnchor.constant = targetStretcherValue
       // starts to expand
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
            // post message only if indicator is full.
            if self.HoldToAnswerViewWidthAnchor.constant == self.targetStretcherValue {
               
                guard let snippet = userResponseOption else {return}
                // retrieve and display routine for Option chosen
                self.talkbox.displayRoutine(for: snippet)
            }
        }
        
    }
    
    
    
    // This updates the collectionview
    fileprivate func postMessageToJungChat(message: String) {
        if !message.isEmpty {
            self.messagesCollection.append(message)
            self.refreshAndScrollCollectionView()
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
            self.HoldToAnswerViewWidthAnchor.constant = 0
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
        
        var rowSize: CGSize = CGSize(width: collectionView.frame.width - 10, height: 38)
        let boundaries:CGRect = estimateFrameFromText(messagesCollection[indexPath.row], bounding: rowSize, fontSize: 12, fontName: "Acrylic Hand Sans")
        rowSize = CGSize(width: collectionView.frame.width - 10 , height: boundaries.size.height + 10)

        return rowSize
    }
    
    
    func scrollCollectionViewToRecentMessage() {
        let indexPath = IndexPath(row: mostRecentChatMessageIndex, section: 0)
        jungChatLoggerCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
    func refreshAndScrollCollectionView() {
        
        self.jungChatLoggerCollectionView.reloadData()
        self.scrollCollectionViewToRecentMessage()
        
    }
    
    

    func formatJungChatBubbleText(text: String) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.2 
        paragraphStyle.hyphenationFactor = 1
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
        return attr
    }

    
    func alphaMessageRatio(indexPath: IndexPath) -> CGFloat {
    
        if (indexPath.row == mostRecentChatMessageIndex)
        {
            return 1
        } else if (indexPath.row == mostRecentChatMessageIndex - 1) {
            return 0.5
        } else if (indexPath.row == mostRecentChatMessageIndex - 2){
            return 0.1
        } else {
            return 0
        }
    }
    

    
    

    
}
