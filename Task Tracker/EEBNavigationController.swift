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
    
    func back(_ sender : AnyObject);
}

class EEBNavigationController : NSViewController {
    @IBOutlet weak var containerView : NSView!
    
    var viewConstraints : [String : [[NSLayoutConstraint]]] = [ String : [[NSLayoutConstraint]]]()
    var viewControllers : [NavigableViewController] = []
    let storeManager = EEBPersistentStoreManager()
    
    override func viewDidLoad() {
        viewControllers = [NavigableViewController]()
        view.wantsLayer = true;
        view.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.onSetNeedsDisplay
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        let vc = self.storyboard?.instantiateController(withIdentifier: "clientViewController") as? EEBBaseTableViewController
        assert(vc != nil)
        vc!.sm = storeManager
        vc!.navigationController = self;
        
        addChildViewController(vc!)
        view.addSubview(vc!.view)
        viewControllers.append(vc!)
        
        //Set view properties & constraints
        vc!.view.translatesAutoresizingMaskIntoConstraints = false
        vc!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        vc!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        vc!.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        vc!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true        
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
    
    func pushViewController(_ viewController : NavigableViewController, _ animated : Bool) {
        let destinationVC = viewController as? NSViewController
        let originVC = viewControllers.last as? NSViewController
        guard destinationVC != originVC else {
            print("Tried to transition to current view controller")
            return
        }
        
        //we can only transition *to* a ViewController is we have a source *and* a destination VC
        if(originVC != nil){
            let options = (animated ? NSViewControllerTransitionOptions.slideLeft : NSViewControllerTransitionOptions())
            
            //Note that we only add the destination VC as a child VC - the origin VC was added last time
            self.addChildViewController(destinationVC!)            

            //Add the subview to the right of the current view
            destinationVC!.view.frame = self.view.frame
            destinationVC!.view.frame.origin.x = self.view.frame.width

            //animate the transition
            self.view.addSubview(destinationVC!.view)
            self.transition(from: originVC!, to: destinationVC!, options: options, completionHandler:nil)
        }
        
        //push onto array used as a stack
        viewControllers.append(viewController)
    }
    
    func popViewControllerAnimated(_ animated : Bool){
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
        
        
        self.transition(from: originVC!, to: destinationVC!, options:NSViewControllerTransitionOptions.slideRight,completionHandler:
            { () -> Void in
                originVC?.view.removeFromSuperview()
            })

        viewControllers.removeLast()
    }
    
    
    override func transition(from fromViewController: NSViewController, to toViewController: NSViewController, options: NSViewControllerTransitionOptions, completionHandler completion: (() -> Void)?) {
        
        //make sure that the views are both part of the hierarchy
        guard fromViewController.view.superview == self.view else {
            return
        }

        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            switch(options){
                case NSViewControllerTransitionOptions.slideRight:
                    fromViewController.view.animator().frame.origin.x += fromViewController.view.bounds.size.width
                    toViewController.view.animator().frame.origin.x = 0
                    break;
                case NSViewControllerTransitionOptions.slideLeft:
                    fromViewController.view.animator().frame.origin.x -= fromViewController.view.bounds.size.width
                    toViewController.view.animator().frame.origin.x = 0
                    break;
                default:
                    context.duration = 0
                    
                }
            }, completionHandler: { () -> Void in
                completion?()
                
                toViewController.view.translatesAutoresizingMaskIntoConstraints = false
                toViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                toViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                toViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                toViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        })
        
    }
    
    @IBAction func add(_ sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.add(self)
        }
    }
    
    @IBAction func remove(_ sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.remove(self)
        }
    }
    @IBAction func run(_ sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.run(sender)
        }
        
    }
    
    @IBAction func undo(_ sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.undo(sender)
        }
    }
    
    @IBAction func redo(_ sender : AnyObject){
        if let currentVC = viewControllers.last as? EEBBaseTableViewController {
            currentVC.redo(sender)
        }
    }
    
    override func keyUp(with theEvent: NSEvent) {
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
