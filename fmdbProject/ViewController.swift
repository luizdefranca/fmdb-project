//
//  ViewController.swift
//  fmdbProject
//
//  Created by Luiz on 6/4/19.
//  Copyright © 2019 Luiz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        startDataBase()
        printPeople()
    }

    func startDataBase() {
        let isPreloaded = UserDefaults.standard.bool(forKey: "initial_data_added_to_database")
        if !isPreloaded {
            do {
                // 2
                let dataManager = try DataManager()
                print("\(String(describing: dataManager.db.databasePath))")
                try dataManager.setupTables()
                UserDefaults.standard.set(true, forKey: "initial_data_added_to_database")
            } catch let error {
                print("Error \(error)")
            }
        }
    }

    func printPeople(){
        do {
            let db = try DataManager()
            let people = try db.getAllFamousPeople()
            for person in people {
                print("\(String(describing: person.firstName!))")
            }
        } catch let error {
            print("Error \(error)")
        }
    }
}

