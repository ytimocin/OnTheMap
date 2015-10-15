//
//  ViewController.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 01/09/15.
//  Copyright (c) 2015 basetech. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIImageView!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorViewTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var errorTypeImage: UIImageView!
    @IBOutlet weak var errorTypeLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* to support smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorViewTopConstraint.constant += errorView.frame.size.height
        
        let placeHolderTextColor: UIColor = UIColor.whiteColor()
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        emailTextField.delegate = self
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        passwordTextField.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    //#MARK:- Login
    
    // helper
    
    func performLogin(email: String, password: String) {
        
        if Reachability.isConnectedToNetwork() {
        
            startLoginAnimation()
        
            UdacityClient.sharedInstance().authenticateWithCompletionHandler(email, password: password) { (success, error) in
                
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stopLoginAnimation()
                    })
                
                    if success {
                        self.completeLogin()
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showErrorView(error)
                        })
                    }
            }
        } else {
            
            self.errorMessageLabel.text = "No Internet Connection!"
            
        }
    }
    
    func performLogin(token: String) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.startLoginAnimation()
        })
        
        UdacityClient.sharedInstance().authenticateWithCompletionHandler(token) { (success, error ) in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.stopLoginAnimation()
            })
            
            if success {
                self.completeLogin()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showErrorView(error)
                }
            }
        }
    }
    
    @IBAction func loginButtonAction(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if emailTextField.text!.isEmpty {
            
            let userInfo: NSDictionary = [
                NSLocalizedDescriptionKey: "Email Empty"]
            
            let errorObject = NSError(domain: "OTMErrorDomain", code: ErrorTypes.Client.rawValue,
                userInfo: userInfo as [NSObject : AnyObject])
            
            self.showErrorView(errorObject)
            
        } else if passwordTextField.text!.isEmpty {
            
            let userInfo: NSDictionary = [
                NSLocalizedDescriptionKey: "Password Empty"]
            
            let errorObject = NSError(domain: "OTMErrorDomain", code: ErrorTypes.Client.rawValue,
                userInfo: userInfo as [NSObject : AnyObject])
            
            self.showErrorView(errorObject)
            
        } else {
            
            performLogin(emailTextField.text!, password: passwordTextField.text!)
            
        }
    }
    
    //#MARK: Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if((FBSDKAccessToken.currentAccessToken()) != nil) {
            
            self.performLogin(FBSDKAccessToken.currentAccessToken().tokenString)
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserPostsTabBar")
                as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }
    
    func startLoginAnimation() {
        
        UIView.animateWithDuration(1.0, animations: {
            self.emailTextField.alpha = 0.5
            self.passwordTextField.alpha = 0.5
            self.logginButton.alpha = 0.5
        })
        
        self.logginButton.enabled = false
        self.facebookLoginButton.enabled = false
        activityIndicator.hidden = false
        
        // The full rotation animation was implemented after following
        // this http://mathewsanders.com/animations-in-swift-part-two/
        
        UIView.animateKeyframesWithDuration(5.0, delay: 0.0,
            options: UIViewKeyframeAnimationOptions.Repeat, animations: {
                
                let fullRotation = CGFloat(M_PI * 2)
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/3, animations: {
                    self.activityIndicator.transform = CGAffineTransformMakeRotation(1/3 * fullRotation)
                })
                UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                    self.activityIndicator.transform = CGAffineTransformMakeRotation(2/3 * fullRotation)
                })
                UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                    self.activityIndicator.transform = CGAffineTransformMakeRotation(3/3 * fullRotation)
                })
                
            }, completion: nil)
        
    }
    
    func stopLoginAnimation() {
        
        UIView.animateWithDuration(1.0, animations: {
            self.emailTextField.alpha = 1.0
            self.passwordTextField.alpha = 1.0
            self.logginButton.alpha = 1.0
        })
        
        self.activityIndicator.hidden = true
        self.logginButton.enabled = true
        self.facebookLoginButton.enabled = true
        
    }
    
    //#MARK:- Error View
    
    func showErrorView(error: NSError!) {
        
        let errorType = ErrorTypes(rawValue: error.code)
        
        var imageName: String?
        imageName = "client"
        
        switch (errorType!) {
        case .Client:
            imageName = "client"
        case .Server:
            imageName = "server"
        case .Network:
            imageName = "network"
            self.retryButton.hidden = false
        }
        
        // the images are taken from the noun project
        self.errorTypeImage.image = UIImage(named: imageName!)
        
        self.errorTypeLabel.text = ErrorTypes.localizedDescription(errorType!)
        self.errorMessageLabel.text = error.localizedDescription
        
        self.errorViewTopConstraint.constant = 8
        self.errorView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(1.0,
            delay: 0.0, usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                self.errorView.layoutIfNeeded()
            },
            completion: nil)
        
    }
    
    @IBAction func okButton(sender: AnyObject) {
        
        self.errorViewTopConstraint.constant += errorView.frame.size.height
        self.errorView.setNeedsUpdateConstraints()
        
        self.retryButton.hidden = true
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.errorView.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBAction func retryButton(sender: AnyObject) {
        
        self.errorViewTopConstraint.constant += errorView.frame.size.height
        self.errorView.setNeedsUpdateConstraints()
        
        self.retryButton.hidden = true
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.errorView.layoutIfNeeded()
            }, completion: { finished in
                
                if((FBSDKAccessToken.currentAccessToken()) != nil) {
                    
                    self.performLogin(FBSDKAccessToken.currentAccessToken().tokenString)
                    
                } else {
                    
                    self.performLogin(self.emailTextField.text!, password: self.passwordTextField.text!)
                    
                }
                
        })
        
    }
    
    //#MARK:- Sign Up
    
    @IBAction func signupButtonAction(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }
    
    //#MARK:- Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //#MARK:- Keyboard Fixes & Notifications
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap() {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y = -lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide() {
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y = 0
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

}

