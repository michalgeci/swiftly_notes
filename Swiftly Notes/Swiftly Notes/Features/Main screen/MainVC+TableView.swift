//
//  MainVC+TableView.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 14/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import UIKit

extension MainVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Load cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "swipeCell") as! SwipeCell
        
        // Set delete action callback
        cell.deleteCallBack = { index in
            RestAPI.removeNoteById(id: index, completion: { (err) in
                if let err = err {
                    print(err)
                } else {
                    self.reloadAllNotes()
                    cell.hideDelete(animated: false)
                }
            })
        }
        
        // Set content of note
        cell.setNote(note: self.notes[indexPath.row])
        
        return cell
    }
    
}
