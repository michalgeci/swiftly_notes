//
//  ViewController.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 10/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import UIKit
import Network

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var notes: [NoteModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableviews delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set tableviews Pull to refresh
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(reloadAllNotes), for: .valueChanged)
        
        // Add tap gesture for selecting rows
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCell(recognizer:)))
        tableView.addGestureRecognizer(tapGesture)
        
        self.reloadAllNotes()
    }

    
    /** Function to reload content of table view from data on server */
    @objc func reloadAllNotes() {
        RestAPI.getAllNotes { (notes, error) in
            // Handle error
            if let error = error {
                self.notes = []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.showAlert {
                    DispatchQueue.main.async {
                        self.tableView.refreshControl?.endRefreshing()
                    }
                }
                print(error)
                return
            }
            
            // Fill with data
            self.notes = notes ?? []
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    /** Detect tapped cell and handle click */
    @objc func tapCell(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? SwipeCell {
                    tappedCell.hideDelete(animated: true)
                    if let id = tappedCell.note?.id {
                        self.performSegue(withIdentifier: "showDetail" , sender: id)
                    }
                }
            }
        }
    }
    
    /** Handle + button click on navbar */
    @IBAction func addNewNote(_ sender: Any) {
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    // Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let noteDetailVC = segue.destination as? NoteDetailVC {
            if let id = sender as? Int {
                noteDetailVC.noteID = id
            }
            noteDetailVC.refreshMainScreen = {
                self.reloadAllNotes()
            }
        }
    }

}

