# fmdb-project

Goal
In this exercise, we will learn how to setup FMDB and use it in a Swift application.

Exercise
This exercise requires completion of the Using SQLite exercise from yesterday, and will leverage the same database.

This time, we will be setting up the famous people database inside an iOS app.

The documentation for FMDB can be found here. Feel free to reference it throughout the day.

Setup
Create a new single page ios app.
Add the FMDB framework to your app using Cocoapods.
Create a new DataManager class and import the framework FMDB into it.
We will use the DataManager to handle all of the SQL queries.

Before we can make any queries to the database, we have to have open a database file. We are going to open the database when our DataManager is initialized, and close the database when the DataManager is deinitialized.

If there are any errors opening or closing the database, then our class should throw an error.

Add the following code to your DataManager

// 1
enum DatabaseError: Error {
  case open
}

class Database {

  // 2
  let db: FMDatabase

  init() throws {
    // 3
    let dbName = "database.db"
    let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbName)

    // 4
    db = FMDatabase(url: fileURL)
    if !db.open() {
      throw DatabaseError.open
    }
  }

  deinit {
    // 5
    db.close()
  }
}
Setup a DatabaseError enum so that we can throw errors when bad things happen.
Create a db property that will point to the FMDatabase
Set the path to the database file. In this case, its going to be a file named database.db inside the app's documents directory
Open the database and throw an error if there was a problem.
Close the database when the DataManager de initializes.
Notice that our initializer throws, so we will always have to try initializing this class.

let dataManager = try DataManager()
Create Table
In the DataManager, create a method that will setup the famous_people table, and add some initial data.

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
Create the SQL query.
Execute the query, and throw an error if it fails.
🎗️ Remember to add the executeStatement case to the DatabaseError enum.

Now we just need to call this method, the first time the app is opened.

In your app delegate, add the following method.

func applicationDidFinishLaunching(_ application: UIApplication) {
  // 1
  let isPreloaded = UserDefaults.standard.bool(forKey: "initial_data_added_to_database")
  if !isPreloaded {
    do {
      // 2
      let dataManager = try DataManager() 
      try dataManager.setupTables() 
      UserDefaults.standard.set(true, forKey: "initial_data_added_to_database")
    } catch let error {
      print("Error \(error)")
    }
  }
}
Use UserDefaults to make sure that the initial data hasn't already been added.
Initialize the data manager and setup the data.
Before we continue with the iOS app, let's make sure that our table and data was actually added to the database.

Using SimSim or a similar application, open up the app's Documents directory in terminal.

Inside the Documents directory, you will find the database.db file.

Open this file in the sqlite3 command line app.

sqlite3 database.db
Check to see that the table was created.

sqlite> .schema
Check to see that the data was added.

sqlite> select * from famous_people;
Remember to use the sqlite3 command line app to debug your database files.

Query Data
Now it's time to query the data from the database. We will create a method that will have to return a set of people from the database.

Create a new Person class with firstName: String?, lastName: String?, and birthdate: String? properties.

We'll use this class to when querying the database.

In the DataManager, create a method that will get all of the famous people from the database.

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
Setup the SELECT query.
Prepare an empty array to hold all of the people that we get from the database.
try to execute the query on the database which will return a FMResultSet when successful.
Loop through each result in the result set.
Create a new person object to hold the data.
Set its properties to be the returned data from the query.
Add that person to the array.
Return that array.
We have to iterate through all of the results in the FMResultSet using a while loop and calling next() each time to go to the next result. We must always call next() before attempting to access the values returned in a query, even if we're only expecting one value.

In the ViewController's viewDidLoad method, call the getAllFamousPeople method.

do {
  let db = try Database()
  let people = try db.getAllFamousPeople()
  for person in people {
    print(person.firstName)
  }
} catch let error {
  print("Error \(error)")
}
Run the app, and you should see all of the people printed to the console.

Conclusion
This app is now connected to an SQLite database using FMDB. You should now feel comfortable with the basics of using FMDB.

Currently the app only prints out the famous people when the view loads. Feel free to add more functionality to this app like presenting the people in a table view, or adding the a ability to add new famous people.
