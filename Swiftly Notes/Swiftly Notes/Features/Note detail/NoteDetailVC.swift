//
//  NoteDetailVC.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 14/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import UIKit

class NoteDetailVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var noteID: Int?
    var refreshMainScreen: ()->() = {}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title
        if noteID == nil {
            self.title = "New note"
        } else {
            self.title = "Edit note"
        }
        
        // Set textField delegate
        textView.delegate = self
        
        // Handle keyboard actions
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Two sepate tap recognizers to hide keyboard when tapped on navbar and anywhere else on screen
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.numberOfTapsRequired = 1
        self.navigationController?.navigationBar.addGestureRecognizer(tapRecognizer)
        
        let tapRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer2.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer2)
        
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        heightConstraint.constant = textView.intrinsicContentSize.height
        
        // If editing existing note
        if let id = self.noteID {
            self.showLoader()
            RestAPI.getNoteById(id: id) { (note, error) in
                // Handle error
                if error != nil {
                    self.showAlert {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
                // Update text
                DispatchQueue.main.async {
                    self.textView.text = note?.title
                    self.heightConstraint.constant = self.textView.intrinsicContentSize.height
                    self.hideLoader()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Automatically show keyboard
        self.textView.becomeFirstResponder()
    }
    
    // Handles adding new note / editing existing note / delete existing note
    // on leaving viewController
    override func viewWillDisappear(_ animated: Bool) {
        // If editing note
        if let id = self.noteID {
            if textView.text == "" {
                // Remove existing note
                RestAPI.removeNoteById(id: id) { (error) in
                    if error == nil {
                        self.refreshMainScreen()
                    }
                }
            } else {
                // Updating existing note
                RestAPI.updateNoteWithId(id: id, text: textView.text) { (note, error) in
                    if error == nil {
                        self.refreshMainScreen()
                    }
                }
            }
        } else { // If new note
            // Creating new note
            if textView.text != "" {
                RestAPI.createNote(text: textView.text) { (note, error) in
                    if error == nil {
                        self.refreshMainScreen()
                    }
                }
            }
        }
    }
    
    // MARK: - Keyboard methods
    // (Sets correct intent size of scroll view)
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: height + 32, right: 0)
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset
    }
    
    // Hides keyboard (only when textView is not empty)
    @objc func hideKeyboard() {
        self.view.endEditing(true)
        if textView.text == "" {
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: - TextView delegate methods
    func textViewDidChange(_ textView: UITextView) {
        // set appropriate size of textview
        heightConstraint.constant = textView.intrinsicContentSize.height
    }

}
