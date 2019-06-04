//
//  DataManager.swift
//  fmdbProject
//
//  Created by Luiz on 6/4/19.
//  Copyright © 2019 Luiz. All rights reserved.
//

import Foundation
import FMDB

enum DatabaseError: Error {
    case open
    case executeStatement
}


public class DataManager {

//    static let shared: DataManager = DataManager()

    // 2
    let db: FMDatabase

    init() throws {
        // 3
        let dbName = "database.db"
        let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbName)
        print("dbPath: \(fileURL)")

        // 4
        db = FMDatabase(url: fileURL)
        if !db.open() {
             print("Failed to open database")
            throw DatabaseError.open
        }
    }

    deinit {
        // 5
        db.close()
    }

    func setupTables() throws {
        // 1
        let sql = """
    CREATE TABLE famous_people (
      id INTEGER PRIMARY KEY,
      first_name VARCHAR(50),
      last_name VARCHAR(50),
      birthdate VARCHAR(10)
    );

    INSERT INTO famous_people (first_name, last_name, birthdate)
      VALUES ('Abraham', 'Lincoln', '1809-02-12');
    INSERT INTO famous_people (first_name, last_name, birthdate)
      VALUES ('Mahatma', 'Gandhi', '1869-10-02');
    INSERT INTO famous_people (first_name, last_name, birthdate)
      VALUES ('Paul', 'Rudd', '1969-04-06');
  """

        // 2
        if !db.executeStatements(sql) {
            throw DatabaseError.executeStatement
        }
    }

    func getAllFamousPeople() throws -> [Person] {
        // 1
        let sql = """
    SELECT * FROM famous_people
    ORDER BY birthdate ASC;
  """

        // 2
        var people = [Person]()

        // 3
        let resultSet = try db.executeQuery(sql, values: nil)

        // 4
        while (resultSet.next()) {
            //retrieve values for each record
            // 5
            let person = Person()

            // 6
            person.firstName = resultSet.string(forColumn: "first_name")
            person.lastName = resultSet.string(forColumn: "last_name")
            person.birthdate = resultSet.string(forColumn: "birthdate")

            // 7
            people.append(person)
        }

        // 8
        return people;
    }

}
