//
//  StudentLocationTableViewCell.swift
//  OnTheMap V1.0
//
//  Created by Ajay Singh on 1/12/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation
import UIKit

class StudentLocationTableViewCell : UITableViewCell
{
   
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var pinView: UIImageView!
    
    func configureTableCell (student:StudentInformation)
    {
        pinView.image = UIImage(named: "pin")
        fullName.text = student.fullname
    }
}

