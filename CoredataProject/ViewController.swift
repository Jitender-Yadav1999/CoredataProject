//
//  ViewController.swift
//  CoredataProject
//
//  Created by Jitendra Kumar 1 on 23/07/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
   
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    var arr = [NotesModel]()
    var filterDataArr = [NotesModel]()
    var isSearched = false
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.register(NotesTableViewCell.nib(), forCellReuseIdentifier: NotesTableViewCell.identifier)
        myTableView.delegate = self
        myTableView.dataSource = self
        mySearchBar.delegate = self
        
        filterDataArr = arr // Initially display all notes
        setupNoNotesLabel(with: "No notes available")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDataAndReload()
    }
 
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        setupFilterMenu(for: sender) { filter in
            self.filterTasks(by: filter)
        }
    }
    
    
    private func filterTasks(by filter: UIViewController.TaskFilter) {
        switch filter {
        case .all:
            filterDataArr = arr
        case .active:
            filterDataArr = arr.filter { !$0.isCompleted }
        case .completed:
            filterDataArr = arr.filter { $0.isCompleted }
        }
        myTableView.reloadData()
        updateNoNotesLabelVisibility(isHidden: !filterDataArr.isEmpty)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeNotesVC = segue.destination as? WriteNotesViewController{
            if let dataToBeSent = sender as? NotesModel{
                writeNotesVC.notesModel = dataToBeSent
            }
            
        }
    }
    
    
    // Handle task deletion
       func deleteTask(at indexPath: IndexPath) {
           let taskToDelete = filterDataArr[indexPath.row]
           if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
               context.delete(taskToDelete)
               do {
                   try context.save()
               } catch {
                   print("Failed to delete the task: \(error)")
               }
               fetchDataAndReload()
           }
       }

       // Handle marking a task as completed or uncompleted
       func markTaskAsCompleted(at indexPath: IndexPath) {
           let task = filterDataArr[indexPath.row]
           task.isCompleted.toggle() // Toggle the completion status
           
           if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
               do {
                   try context.save()
               } catch {
                   print("Failed to update the task: \(error)")
               }
               fetchDataAndReload()
           }
       }
       
       // Fetch data and reload table view
       func fetchDataAndReload() {
           if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
               let request: NSFetchRequest<NotesModel> = NotesModel.fetchRequest()
               request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
               if let notesFromCoreData = try? context.fetch(request) {
                   arr = notesFromCoreData
                   filterDataArr = arr
                   myTableView.reloadData()
                   updateNoNotesLabelVisibility(isHidden: !filterDataArr.isEmpty)
               }
           }
       }
}

//tableview
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.identifier, for: indexPath) as? NotesTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: filterDataArr[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notes = filterDataArr[indexPath.row]
        performSegue(withIdentifier: "segueToWriteNotes", sender: notes)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // Add swipe actions for each row
      func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
          // Delete action
          let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
                      self?.showDeleteConfirmationAlert {
                          self?.deleteTask(at: indexPath)
                      }
                      completionHandler(true)
                  }
                  deleteAction.image = UIImage(systemName: "trash")
          
          // Mark as Completed action
          let completedAction = UIContextualAction(style: .normal, title: "Complete") { [weak self] (action, view, completionHandler) in
              self?.markTaskAsCompleted(at: indexPath)
              completionHandler(true)
          }
          completedAction.backgroundColor = .systemBlue
          completedAction.image = UIImage(systemName: "checkmark")
          
          // If task is already completed, we offer an "Unmark" option instead
          if filterDataArr[indexPath.row].isCompleted {
              completedAction.title = "Unmark"
              completedAction.backgroundColor = .systemOrange
          }
          
          let configuration = UISwipeActionsConfiguration(actions: [deleteAction, completedAction])
          return configuration
      }
}

//search bar
extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterDataArr = arr
        } else {
            filterDataArr = arr.filter { item in
                return item.heading?.lowercased().contains(searchText.lowercased()) ?? false ||
                       item.text?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        myTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterDataArr = arr
        myTableView.reloadData()
    }
}


