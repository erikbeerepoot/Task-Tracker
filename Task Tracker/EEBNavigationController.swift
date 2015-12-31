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
    
    var viewConstraints : [String : [[NSLayoutConstraint]]] = [ String : [[NSLayoutConstraint]]]()
    var viewControllers : [NavigableViewController] = []
    let storeManager = EEBPersistentStoreManager()
    
    override func viewDidLoad() {
        viewControllers = [NavigableViewController]()
        view.wantsLayer = true;
        view.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.OnSetNeedsDisplay
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        let vc = self.storyboard?.instantiateControllerWithIdentifier("clientViewController") as? EEBBaseTableViewController
        assert(vc != nil)
        vc!.sm = storeManager
        vc!.navigationController = self;
        
        addChildViewController(vc!)
        view.addSubview(vc!.view)
        viewControllers.append(vc!)
        
        //Set view properties & constraints
        vc!.view.translatesAutoresizingMaskIntoConstraints = false
        vc!.view.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
        vc!.view.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
        vc!.view.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        vc!.view.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true        
    }
        
    override func viewWillAppear() {
        //We want all the action messages to go to us
        self.view.window?.toolbar?.items.forEach({ (item) -> () in
            item.target = self
        })
        
        if let statusview = self.view.window?.toolbar?.itemWithIdentifier("statusView")?.view as? EEBStatusView{
            if let currentVC = viewControllers.last as? EEBBaseTableViewController {
                if(currentVC.timer!.running){
                    statusview.progressIndicator?.startAnimation(self)
                }
            }
        }

    }
    
    override func viewWillDisappear() {

    }
    
    func applicationWillTerminate(){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            if(currentVC.timer!.running){
                //TODO: Show confirmation
                currentVC.timer?.stopTimingSession()
            }
        }
        storeManager.save()
    }
    
    var constraints : [NSLayoutConstraint]  = []
    func pushViewController(viewController : NavigableViewController, _ animated : Bool) {
        let destinationVC = viewController as? NSViewController
        let originVC = viewControllers.last as? NSViewController
        guard destinationVC != originVC else {
            print("Tried to transition to current view controller")
            return
        }
        
        //we can only transition *to* a ViewController is we have a source *and* a destination VC
        if(originVC != nil){
            let options = (animated ? NSViewControllerTransitionOptions.SlideLeft : NSViewControllerTransitionOptions.None)
            
            //Note that we only add the destination VC as a child VC - the origin VC was added last time
            self.addChildViewController(destinationVC!)            

            //Add the subview to the right of the current view
            destinationVC!.view.frame = self.view.frame
            destinationVC!.view.frame.origin.x = self.view.frame.width

            //animate the transition
            self.view.addSubview(destinationVC!.view)
            self.transitionFromViewController(originVC!, toViewController: destinationVC!, options: options, completionHandler:nil)
        }
        
        //push onto array used as a stack
        viewControllers.append(viewController)
    }
    
    func popViewControllerAnimated(animated : Bool){
        guard  viewControllers.count > 1 else {
            print("Tried to pop root viewcontroller")
            return;
        }
        
        let originVC = viewControllers[viewControllers.count - 1] as? NSViewController
        let destinationVC = viewControllers[viewControllers.count - 2] as? NSViewController
        guard(originVC != nil && destinationVC != nil) else {
            return;
        }

        //Add the subview to the right of the current view
        destinationVC!.view.frame = self.view.frame
        destinationVC!.view.frame.origin.x = -1*self.view.frame.width
        
        
        self.transitionFromViewController(originVC!, toViewController: destinationVC!, options:NSViewControllerTransitionOptions.SlideRight,completionHandler:
            { () -> Void in
                originVC?.view.removeFromSuperview()
            })

        viewControllers.removeLast()
    }
    
    
    override func transitionFromViewController(fromViewController: NSViewController, toViewController: NSViewController, options: NSViewControllerTransitionOptions, completionHandler completion: (() -> Void)?) {
        
        //make sure that the views are both part of the hierarchy
        guard fromViewController.view.superview == self.view else {
            return
        }

        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            switch(options){
                case NSViewControllerTransitionOptions.SlideRight:
                    fromViewController.view.animator().frame.origin.x += fromViewController.view.bounds.size.width
                    toViewController.view.animator().frame.origin.x = 0
                    break;
                case NSViewControllerTransitionOptions.SlideLeft:
                    fromViewController.view.animator().frame.origin.x -= fromViewController.view.bounds.size.width
                    toViewController.view.animator().frame.origin.x = 0
                    break;
                default:
                    context.duration = 0
                    
                }
            }, completionHandler: { () -> Void in
                completion?()
                
                toViewController.view.translatesAutoresizingMaskIntoConstraints = false
                toViewController.view.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
                toViewController.view.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
                toViewController.view.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
                toViewController.view.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        })
        
    }
    
    @IBAction func add(sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.add(self)
        }
    }
    
    @IBAction func remove(sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.remove(self)
        }
    }
    @IBAction func run(sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.run(sender)
        }
        
    }
    
    @IBAction func undo(sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.undo(sender)
        }
    }
    
    @IBAction func redo(sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.redo(sender)
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        let currentVC = viewControllers.last as? EEBBaseTableViewController
        guard( currentVC != nil) else {
            return
        }
        
        let chars = theEvent.charactersIgnoringModifiers
        if(chars == " "){
            if let runItem = self.view.window?.toolbar?.itemWithIdentifier(kToolbarItemIdentifierRun){
                currentVC!.run(runItem.view!)
            }
        } else if(chars! == "\r" && currentVC is EEBJobViewController){
          //  (currentVC as! EEBJobViewController).enterPressed()
        }

    }
}