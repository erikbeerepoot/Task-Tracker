//
//  RootViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-28.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

protocol NavigableViewController  {
    var navigationController : EEBNavigationController? {get set};
    var view : NSView {get set}
}

class EEBNavigationController : NSViewController {
    @IBOutlet weak var containerView : NSView!
    
    var viewControllers : [NavigableViewController]? = nil
    let storeManager = PersistentStoreManager()
    
    override func viewDidLoad() {
        viewControllers = [NavigableViewController]()
        
        let vc = self.storyboard?.instantiateControllerWithIdentifier("clientViewController") as? EEBBaseTableViewController
        
        assert(vc != nil)
        vc!.sm = storeManager
        vc!.navigationController = self;
        pushViewController(vc!, false)
    }
    
    override func viewWillAppear() {
        
    }
    
    override func viewWillDisappear() {
        if let currentVC = viewControllers?.last as? EEBBaseTableViewController {
            if(currentVC.timer!.running){
                //TODO: Show confirmation
                currentVC.timer?.stopTimingSession()
            }
        }
        
        storeManager.save()
    }
    
    func pushViewController(viewController : NavigableViewController, _ animated : Bool) {
        let destinationVC = viewController as? NSViewController
        let originVC = viewControllers?.last as? NSViewController
        guard destinationVC != originVC else {
            print("Tried to transition to current view controller")
            return
        }
        
        //add the view hierarchy
        self.view.addSubview(viewController.view)
        
        //we can only transition *to* a ViewController is we have a source *and* a destination VC
        if(originVC != nil){
            let options = (animated ? NSViewControllerTransitionOptions.SlideLeft : NSViewControllerTransitionOptions.None)
            
            //Note that we only add the destination VC as a child VC - the origin VC was added last time
            self.addChildViewController(destinationVC!)            

            //animate the transition
            self.transitionFromViewController(viewControllers?.last as! NSViewController, toViewController: viewController as! NSViewController, options: options, completionHandler: nil)
        } else {
            //special case for the first VC pushed onto the stack
            self.addChildViewController(destinationVC!)
        }
        
        //push onto array used as a stack
        viewControllers?.append(viewController)
    }
    
    func popViewControllerAnimated(animated : Bool){
        guard viewControllers != nil && viewControllers?.count > 1 else {
            print("Tried to pop root viewcontroller")
            return;
        }
        
        let originVC = viewControllers?[viewControllers!.count - 1] as? NSViewController
        let destinationVC = viewControllers?[viewControllers!.count - 2] as? NSViewController
        guard(originVC != nil && destinationVC != nil) else {
            return;
        }
        self.transitionFromViewController(originVC!, toViewController: destinationVC!, options:NSViewControllerTransitionOptions.SlideRight, completionHandler: nil)
        viewControllers?.removeLast()
    }
    
    @IBAction func add(sender : AnyObject){
        if let currentVC = viewControllers?.last as? EEBBaseTableViewController {
            currentVC.add(self)
        }
    }
    
    @IBAction func remove(sender : AnyObject){
        if let currentVC = viewControllers?.last as? EEBBaseTableViewController {
            currentVC.remove(self)
        }
    }
    @IBAction func run(sender : AnyObject){
        if let currentVC = viewControllers?.last as? EEBBaseTableViewController {
            currentVC.run(sender)
        }
        
    }
}