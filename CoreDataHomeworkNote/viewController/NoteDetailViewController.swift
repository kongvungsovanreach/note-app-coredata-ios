//
//  NoteDetailViewController.swift
//  CoreDataHomeworkNote
//
//  Created by Kong Vungsovanreach on 12/8/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit
import CoreData

class NoteDetailViewController: UIViewController {
    // Variable declaration block
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    // Core data appDelegate and context
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    // Note object for value updating passing
    static var note : NSManagedObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.showsVerticalScrollIndicator = false
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(self.handlePopGesture))
        firstLaunchConfigure()
        keyboardAppearanceConfigure()
    }

    override func viewWillDisappear(_ animated: Bool) {
        save()
        NoteDetailViewController.note = nil
    }

    // Save button tap handler
    @IBAction func saveNote(_ sender: Any) {
        // Validate empty title textfield
        if (titleTextField.text?.isEmpty)! {
            let alertController = UIAlertController(title: "Invalid Note", message: "Note cannot be title-less", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        self.navigationController?.popToRootViewController(animated: true)
    }

    // Delete button tap handler
    @IBAction func deleteNote(_ sender: Any) {
        context.delete(NoteDetailViewController.note)
        do{
            try? context.save()
        }
        self.navigationController?.popToRootViewController(animated: true)
    }

    // Function for saving into core data
    func save() {
        // Validate empty title textfield
        if !(titleTextField.text?.isEmpty)! {
            let title = titleTextField.text
            let content = contentTextView.text
            let n = NoteDetailViewController.note
            if let note = n {
                note.setValue(title, forKey: "title")
                note.setValue(content, forKey: "content")
            }else {
                let newNote = Note(context: context)
                newNote.setValue(title, forKey: "title")
                newNote.setValue(content, forKey: "content")
            }
            appDelegate.saveContext()
        }
    }

    // Configure keyboard appearance, not overlap textView when keyboard showing
    func keyboardAppearanceConfigure()  {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // Configure title and content whether it is updating or inserting a new note
    func firstLaunchConfigure() {
        let n = NoteDetailViewController.note
        // If it is an updating request
        if let note = n {
            titleTextField.text = (note.value(forKey: "title") as! String)
            contentTextView.text = (note.value(forKey: "content") as! String)
        }else { // If it is an inserting request
            titleTextField.text = ""
            contentTextView.text = ""
            deleteButton.isEnabled = false
        }
    }

    // Function for handling swipe back guesture to save
    @objc func handlePopGesture(gesture: UIGestureRecognizer) -> Void {
        if gesture.state == UIGestureRecognizer.State.began {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    // Selector for keyboard configuration
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            contentTextView.contentInset = UIEdgeInsets.zero
        } else {
            contentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        contentTextView.scrollIndicatorInsets = contentTextView.contentInset
        let selectedRange = contentTextView.selectedRange
        contentTextView.scrollRangeToVisible(selectedRange)
    }
}

