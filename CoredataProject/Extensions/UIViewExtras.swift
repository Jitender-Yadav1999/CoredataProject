//
//  UIViewExtras.swift
//  CoredataProject

import Foundation
import UIKit

extension UIViewController {
    
    func showToast(message: String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 6.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    
    func showDeleteConfirmationAlert(deleteAction: @escaping () -> Void) {
        let alert = UIAlertController(title: "Delete this Note?", message: "This note will be permanently deleted from this device.", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            deleteAction()
        }
        alert.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func setupPlaceholder(headingTextViewPlaceholder: String, myHeadingTextview: UITextView, headingPlaceholderLabel: inout UILabel?) {
        headingPlaceholderLabel = UILabel()
        headingPlaceholderLabel?.text = headingTextViewPlaceholder
        headingPlaceholderLabel?.font = UIFont.italicSystemFont(ofSize: (myHeadingTextview.font?.pointSize)!)
        headingPlaceholderLabel?.sizeToFit()
        myHeadingTextview.addSubview(headingPlaceholderLabel!)
        headingPlaceholderLabel?.frame.origin = CGPoint(x: 5, y: (myHeadingTextview.font?.pointSize)! / 2)
        headingPlaceholderLabel?.textColor = UIColor.lightGray
        headingPlaceholderLabel?.isHidden = !myHeadingTextview.text.isEmpty
    }
    
    func updatePlaceholderVisibility(headingTextview: UITextView, headingPlaceholderLabel: UILabel?) {
        headingPlaceholderLabel?.isHidden = !headingTextview.text.isEmpty
    }
    
    func setupFilterMenu(for button: UIButton, filterHandler: @escaping (TaskFilter) -> Void) {
        let allTasks = UIAction(title: "All Tasks") { _ in
            filterHandler(.all)
        }
        let activeTasks = UIAction(title: "Active Tasks", image: UIImage(systemName: "square")) { _ in
            filterHandler(.active)
        }
        let completedTasks = UIAction(title: "Completed Tasks", image: UIImage(systemName: "checkmark.square")) { _ in
            filterHandler(.completed)
        }
        let menu = UIMenu(title: "Filter", children: [allTasks, activeTasks, completedTasks])
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
    
    enum TaskFilter {
        case all
        case active
        case completed
    }
    
    //to set nonotelabel
    private struct AssociatedKeys {
        static var noNotesLabel = "noNotesLabel"
    }
    
    var noNotesLabel: UILabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.noNotesLabel) as? UILabel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.noNotesLabel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setupNoNotesLabel(with text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor.blue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        self.noNotesLabel = label
        self.noNotesLabel?.isHidden = true // Initially hide the label
    }
    
    func updateNoNotesLabelVisibility(isHidden: Bool) {
        noNotesLabel?.isHidden = isHidden
    }
    
    //date picker
    func presentDatePicker(title: String, completion: @escaping (Date) -> Void) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .automatic
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let selectedDate = datePicker.date
            completion(selectedDate)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // Add constraints to the date picker
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        present(alert, animated: true, completion: nil)
    }
    
    func scheduleNotification(for date: Date, title: String, body: String) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled for \(date)")
                }
            }
        }
    
    func showNotificationSettingsAlert() {
        let alertController = UIAlertController(
            title: "Notifications Disabled",
            message: "To set reminders, please enable notifications in Settings.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            // Open the app's settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

//this card setup will work for both uiviewcontroller and uiviewcell
extension UIView {
    func setupCardView() {
        self.layer.cornerRadius = 10 // Adjust the corner radius as needed
        self.layer.shadowColor = UIColor.blue.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
}

// Date Extension
extension Date {
    static func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    static func parseDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
}
