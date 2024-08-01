//
//  TodoItemTableViewCell.swift
//  SampleTodo
//
//  Created by prautela on 31/07/24.
//

import UIKit

class TodoItemTableViewCell: UITableViewCell {

    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var deleteActionButton: UIButton!
    @IBOutlet weak var todoUpdateActionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
