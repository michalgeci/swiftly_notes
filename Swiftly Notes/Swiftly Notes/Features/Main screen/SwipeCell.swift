//
//  SwipeCell.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 13/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import UIKit

class SwipeCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var deleteView: UIView!
    
    var deleteCallBack: (_ index: Int) -> Void = {_ in}
    var note: NoteModel?
    
    /** Init code */
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
    }
    
    /** Set cell to contain specific Note */
    func setNote(note: NoteModel) {
        self.note = note
        title.text = note.title
    }
    
    /** Action to delete cell via swipe and confirm */
    @IBAction func deletePressed(_ sender: Any) {
        if let id = self.note?.id {
            self.deleteCallBack(id)
        }
    }
    
    // MARK: - Scroll view delegate methods
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            self.stoppedScrolling()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stoppedScrolling()
    }
    
    /** Replaces paging of scrollview */
    func stoppedScrolling() {
        let width = deleteView.bounds.width
        if scrollView.contentOffset.x >= width {
            let newOffset = CGPoint(x: deleteView.bounds.width, y: 0)
            scrollView.setContentOffset(newOffset, animated: true)
        } else {
            let newOffset = CGPoint(x: 0, y: 0)
            scrollView.setContentOffset(newOffset, animated: true)
        }
    }
    
    /** Swipes cell to default position, when delete button is hidden */
    func hideDelete(animated: Bool) {
        let newOffset = CGPoint(x: 0, y: 0)
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(newOffset, animated: animated)
        }
    }

}
