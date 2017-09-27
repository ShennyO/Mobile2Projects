//
//  DetailsViewController.swift
//  ProductHunt
//
//  Created by Sunny Ouyang on 9/26/17.
//  Copyright © 2017 Sunny Ouyang. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    var comments = [Comment]()
        
    
    var id: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Networking.getComments(id: id!, completion: { (comments) in
            print(comments)
            self.comments = comments
            self.commentsTableView.reloadData()
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentsTableView.dequeueReusableCell(withIdentifier: "commentsCell")
        
        cell?.textLabel?.text = comments[indexPath.row].body
        
        return cell!
    }

}
