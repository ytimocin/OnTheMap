//
//  CollectionViewController.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 13/09/15.
//  Copyright (c) 2015 basetech. All rights reserved.
//

import UIKit

let reuseIdentifier = "CollectionViewCell"

class CollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCollection", name: "userDataUpdated", object: nil)
        
        /* Create and set the logout button */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        
        /* Create and set the add pin and reload button */
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "reload-data"), style: UIBarButtonItemStyle.Plain, target: self, action: "loadData"),
            UIBarButtonItem(image: UIImage(named: "pin-data"), style: UIBarButtonItemStyle.Plain, target: self, action: "informationPostingButtonTouchUp")
        ]
        
        if (UserPins.sharedInstance().users.count == 0) {
            
            loadData()
            
        } else {
            
            updateCollection()
            
        }
    }
    
    func updateCollection() {
        self.collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserPins.sharedInstance().users.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UserLocationCollectionViewCell
        let userInformation = UserPins.sharedInstance().users[indexPath.row]
        
        cell.label.text = prefix(userInformation.firstName!, 1) + prefix(userInformation.lastName!, 1)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let userInformation = UserPins.sharedInstance().users[indexPath.row]
        let link = NSURL(string: userInformation.mediaURL!)!
        UIApplication.sharedApplication().openURL(link)
    }
    
    // MARK: - Navigation Bar Buttons
    
    func logoutButtonTouchUp() {
        
        UdacityClient.sharedInstance().logout() { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
    }
    
    func loadData() {
        
        UserPins.sharedInstance().users.removeAll(keepCapacity: true)
        
        var serialQueue = dispatch_queue_create("com.udacity.onthemap.api", DISPATCH_QUEUE_SERIAL)
        
        var skips = [0, 100]
        for skip in skips {
            dispatch_sync( serialQueue ) {
                
                ParseClient.sharedInstance().getUsers(skip: skip) { users, error in
                    if let users = users {
                        UserPins.sharedInstance().users.extend(users)
                        
                        if users.count > 0 {
                            dispatch_async(dispatch_get_main_queue()) {
                                NSNotificationCenter.defaultCenter().postNotificationName("userDataUpdated", object: nil)
                            }
                        }
                        
                    } else {
                        
                        let title: String =  ErrorTypes.localizedDescription(ErrorTypes(rawValue: error!.code)!)
                        let alertController = UIAlertController(title: title, message: error!.localizedDescription,
                            preferredStyle: .Alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        alertController.addAction(okAction)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
    }
    
    func informationPostingButtonTouchUp() {
        
        if UdacityClient.sharedInstance().currentUser?.hasPosted == true {
            let message = "You have already posted a location. Would you like to overwrite your current location?"
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default) { (action) in
                
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
                    as! UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(overwriteAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
                as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    
}
