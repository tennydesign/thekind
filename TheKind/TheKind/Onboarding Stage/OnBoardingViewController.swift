//
//  OnboardingViewController.swift
//  TheKind
//
//  Created by Tenny on 12/16/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit


class OnBoardingViewController: UIViewController {

    @IBOutlet var carouselView: CarouselView! {
        didSet {
            carouselView.alpha = 0
            //carouselView.onBoardingViewController = self
        }
    }
    
    @IBOutlet var chooseKindCardView: ChooseKindCardView! {
        didSet{
            chooseKindCardView.alpha = 0
            chooseKindCardView.onBoardingViewController = self
        }
    }
    @IBOutlet var chooseDriverView: ChooseDriverView! {
        didSet{
            chooseDriverView.alpha = 1
            chooseDriverView.onBoardingViewController = self
        }
    }
    @IBOutlet var pickYourKindWindow: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseKindCardView.isHidden = true
    
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func goToMainStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(vc, animated: true, completion: nil)
    }

}

// == ANIMATIONS

enum OnboardingVCViews {
    case chooseDriver, chooseKindCard
}

extension OnBoardingViewController {
    
    func switchViewsInsideController(toViewName: OnboardingVCViews, originView: UIView, removeOriginFromSuperView: Bool) {

        var destinationView: UIView
        
        // Do all the prep to transition here.
        switch toViewName {
        case .chooseDriver:
            pickYourKindWindow.isUserInteractionEnabled = true
            destinationView = chooseDriverView
            viewTransitionUsingAlpha(originView, destinationView, removeOriginFromSuperView)
        case .chooseKindCard:
            destinationView = chooseKindCardView
            viewTransitionUsingAlpha(originView, destinationView, removeOriginFromSuperView)
        }
    }
    
}
