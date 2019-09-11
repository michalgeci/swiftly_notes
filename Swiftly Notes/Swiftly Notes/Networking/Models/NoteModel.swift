//
//  NoteModel.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 11/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import Foundation

struct NoteModel {
    let id: Int
    let title: String
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}
