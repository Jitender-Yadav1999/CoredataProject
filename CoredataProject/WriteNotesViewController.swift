//
//  WriteNotesViewController.swift
//  CoredataProject
//
//  Created by Jitendra Kumar 1 on 23/07/24.
//

import UIKit

class WriteNotesViewController: UIViewController,UITextViewDelegate {
    
    
    
    @IBOutlet weak var detailTextContainer: UIView!
    @IBOutlet weak var headingContainer: UIView!
    @IBOutlet weak var bottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myTextView: UITextView!
    
    @IBOutlet weak var dateContainer: UIView!
    let headingTextViewPlaceholder = "Enter heading here..."
    var headingPlaceholderLabel: UILabel!
    
    @IBOutlet weak var myHeadingTextview: UITextView!
    var notesModel: NotesModel?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //card view setup
        dateContainer.setupCardView()
        headingContainer.setupCardView()
        detailTextContainer.setupCardView()
        //When the keyboard is about to be shown, the keyboardWillShow method is triggered, allowing you to adjust your UI accordingly,here when keyboard appears we are adjusting the bottom constraints
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        setupPlaceholder(headingTextViewPlaceholder: headingTextViewPlaceholder, myHeadingTextview: myHeadingTextview, headingPlaceholderLabel: &headingPlaceholderLabel)
        
        if notesModel == nil{
            //create new note
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext{
                notesModel = NotesModel(context: context)
                notesModel?.date = Date()
                notesModel?.heading = ""
                notesModel?.text = ""
                
                //set keyboard stuff,cursor goes to
                myTextView.becomeFirstResponder()
                //myHeadingTextview.becomeFirstResponder()
            }
        }
        
        myTextView.text = notesModel?.text
        //        if let dateToBeShown = formatDate(date: Date())  {
        //                    myDateLabel.text = dateToBeShown
        //                }
        myDateLabel.text = Date.formatDate(Date())
        myHeadingTextview.text = notesModel?.heading
    
        myTextView.delegate = self
        myHeadingTextview.delegate = self
        
        updatePlaceholderVisibility(headingTextview: myHeadingTextview, headingPlaceholderLabel: headingPlaceholderLabel)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //when we hit back button means our view will disappear
        // do not Save if the text  and heading both are empty,If the text and heading are empty, the note is deleted from the context before saving.
        if let text = notesModel?.text, !text.isEmpty || (notesModel?.heading != nil && !notesModel!.heading!.isEmpty) {
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        } else {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext, let note = notesModel {
                context.delete(note)
                try? context.save()
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            bottomConstraints.constant = keyboardHeight
        }
    }
    
    
    
    @IBAction func deleteTapped(_ sender: Any) {
        showDeleteConfirmationAlert {
            //delete action
            self.deleteNote()
        }
    }

    private func deleteNote() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let note = notesModel {
                context.delete(note)
                try? context.save()
            }
        }
        navigationController?.popViewController(animated: true)
    }

    //when we change something in textview then also we want to save our note
    func textViewDidChange(_ textView: UITextView) {
        if let dateString = myDateLabel.text {
            notesModel?.date = Date.parseDate(dateString)
        }
       
        notesModel?.text = myTextView.text
        notesModel?.heading = myHeadingTextview.text
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
        updatePlaceholderVisibility(headingTextview: myHeadingTextview, headingPlaceholderLabel: headingPlaceholderLabel)
    }
    
    //to set character limit of heading
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           if textView == myHeadingTextview {
               let currentText = textView.text ?? ""
               guard let stringRange = Range(range, in: currentText) else { return false }
               let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
               
               if updatedText.count > 60 {
                   showToast(message: "Character limit reached", font: UIFont.systemFont(ofSize: 12.0))
                   return false
               }
           }
           return true
       }
    
    //when we change something in datepicker then also we want to save the changes
    //    @IBAction func datePickerChanged(_ sender: Any) {
    //        notesModel?.date = myDatePicker.date
    //        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    //    }
    
    
}
