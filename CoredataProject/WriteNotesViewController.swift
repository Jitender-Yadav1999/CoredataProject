//
//  WriteNotesViewController.swift
//  CoredataProject


import UIKit
import UserNotifications

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
        myDateLabel.text = Date.formatDate(Date())
        myHeadingTextview.text = notesModel?.heading
    
        myTextView.delegate = self
        myHeadingTextview.delegate = self
        
        updatePlaceholderVisibility(headingTextview: myHeadingTextview, headingPlaceholderLabel: headingPlaceholderLabel)
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let trimmedText = notesModel?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHeading = notesModel?.heading?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext, let note = notesModel {
            // If both heading and text are empty, delete the note
            if let text = trimmedText, text.isEmpty, let heading = trimmedHeading, heading.isEmpty {
                context.delete(note)
                try? context.save()
            } else {
                // Save the context if there's meaningful content
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
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
    
    @IBAction func ReminderTapped(_ sender: UIBarButtonItem) {
        // Check if notification permissions are granted
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Authorization status: \(settings.authorizationStatus.rawValue)")
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    self.presentDatePicker(title: "Select Reminder Date for this Note") { [self] selectedDate in
                        
                        self.showToast(message: "Date Selected)", font: UIFont.systemFont(ofSize: 12.0))
                        
                        // Save the selected reminder date in the note
                        self.notesModel?.reminderDate = selectedDate
                        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                        
                        // Schedule the notification
                        let title = notesModel?.heading ?? "Reminder"
                        let body = notesModel?.text ?? "You have a reminder set for this note."
                        self.scheduleNotification(for: selectedDate, title: title, body: body)
                    }} else {
                        // Permissions are not granted, show an alert to guide the user
                        self.showNotificationSettingsAlert()
                    }
            }
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
        // Update the note's date, text, and heading
        if let dateString = myDateLabel.text {
            notesModel?.date = Date.parseDate(dateString)
        }
        
        let trimmedText = myTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHeading = myHeadingTextview.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext, let note = notesModel {
            // If both heading and text are empty, delete the note
            if trimmedText.isEmpty && trimmedHeading.isEmpty {
                context.delete(note)
            } else {
                // Otherwise, update the note's text and heading
                notesModel?.text = trimmedText
                notesModel?.heading = trimmedHeading
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            }
        }
        
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
