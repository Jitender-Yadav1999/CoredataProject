//
//  NotesTableViewCell.swift
//  CoredataProject
//
//  Created by Jitendra Kumar 1 on 23/07/24.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var myHeadingLabel: UILabel!
   // @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!
    var model: NotesModel?

    
    static let identifier = "myNotesTableViewCellIdentifier"
    
    
    
    static func nib() -> UINib{
        return UINib(nibName: "NotesTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.setupCardView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    
    
    @IBAction func checkBoxButtonTapped(_ sender: UIButton) {
        guard let model = model else { return }
        model.isCompleted.toggle() // Toggle completion status
        configure(with: model) // Update the cell UI
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext() // Save changes to Core Data
    }
    
    
    
    public func configure(with model : NotesModel){
        self.model = model
            self.myLabel.text = model.text
            self.myHeadingLabel.text = model.heading
            self.dayLabel.text = model.DateAndYear()
            let checkboxImage = model.isCompleted ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
            self.checkboxButton.setImage(checkboxImage, for: .normal)
    }
    
    
}
