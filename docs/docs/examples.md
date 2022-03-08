---
title: Examples
tags:
  - examples
---

Some common examples are given below. For in-depth examples see the test cases in the `project/tests/unit/` folder

!!! info "Dictionary Syntax"

    A Dictionary in Godot can be specified using different equivalent syntax as follows:
    ```
    {
        "key1": "value1",
        "key2": [1, 2, 3],
        "key3": another_dictionary,
        "key4": "value4"
    }
    ```
    ```
    {
        key1 = value1,
        key2 = [1, 2, 3],
        key3 = another_dictionary,
        key4 = value4
    }
    ```

## Working with a database
``` title="base code"
var driver: MongoDriver = MongoDriver.new()
var connection: MongoConnection = driver.connect_to_server("mongodb://localhost:27017")

var database: MongoDatabase = connection.get_database("test")
# Now you can use the database
```

- ### Running commands
  See more on commands [here](https://docs.mongodb.com/manual/reference/command/)
    - #### hello Command
        ```
        var res = database.run_command({
            hello = 1
        })
        print(res)
        ```
    - #### createUser Command
        ```
        print(database.run_command({
            createUser = "test_user1",
            pwd = "pass1234",
            roles = []
        })
        ```
- ### Create specific collections
    - #### Capped Collection
    ```
    print(database.create_collection("test", {
        capped = true,
        size = 1000,
    }))
    ```
    - #### Validated Collection
    ```
    # Ensure that the _id field is less than 100 in value
    print(database.create_collection("test", {
        validator = {
            _id = Mongo.Lt(100)
        }
    }))
    ```
## Aggregation
See more about aggregation [here](https://docs.mongodb.com/manual/core/aggregation-pipeline/)

- ### Example 1
  This example shows aggregation pipeline on a collection that contains orders for products
  ```
  var database: MongoDatabase = connection.get_database("test")
  var collection: MongoCollection = database.get_collection("test_col")
  # Drop the collection if it exists
  collection.drop()
  # Insert test data
  collection.insert_many([
      { _id = 0, productName = "Steel beam",
          status = "new", quantity = 10 },
      { _id = 1, productName = "Steel beam",
          status = "urgent", quantity = 20 },
      { _id = 2, productName = "Steel beam",
          status = "urgent", quantity = 30 },
      { _id = 3, productName = "Iron rod",
          status = "new", quantity = 15 },
      { _id = 4, productName = "Iron rod",
          status = "urgent", quantity = 50 },
      { _id = 5, productName = "Iron rod",
          status = "urgent", quantity = 10 }
  ])
  # Run the aggregation
  var result = database.run_command({
      aggregate = "test_col",
      pipeline = [
          # Stage 1: Filter documents on the status
          Mongo.Match({
              status = "urgent"
          }),
          # Stage 2: Group remaining documents by
          # productName and calculate total quantity
          Mongo.Group({
              _id = "$productName",
              sumQuantity = Mongo.Sum("$quantity")
          })
      ],
      cursor = {}
  })["cursor"]["firstBatch"]
  print(result)
  ```
  Output
  ```
  [
      { _id = "Iron rod", sumQuantity = 60 },
      { _id = "Steel beam", sumQuantity = 50 }
  ]
  ```
- ### Example 2
  This example shows aggregation pipeline on collection that contains pizza orders  
  ```
  var database: MongoDatabase = connection.get_database("test")
  var collection: MongoCollection = database.get_collection("test_col")
  collection.drop()
  collection.insert_many([
      { _id = 0, name = "Pepperoni", size = "small", price = 19,
          quantity = 10, date = Mongo.Date("2021-03-13T08:14:30Z") },
      { _id = 1, name = "Pepperoni", size = "medium", price = 20,
          quantity = 20, date = Mongo.Date("2021-03-13T09:13:24Z") },
      { _id = 2, name = "Pepperoni", size = "large", price = 21,
          quantity = 30, date = Mongo.Date("2021-03-17T09:22:12Z") },
      { _id = 3, name = "Cheese", size = "small", price = 12,
          quantity = 15, date = Mongo.Date("2021-03-13T11:21:39.736Z") },
      { _id = 4, name = "Cheese", size = "medium", price = 13,
          quantity = 50, date = Mongo.Date("2022-01-12T21:23:13.331Z") },
      { _id = 5, name = "Cheese", size = "large", price = 14,
          quantity = 10, date = Mongo.Date("2022-01-12T05:08:13Z") },
      { _id = 6, name = "Vegan", size = "small", price = 17,
          quantity = 10, date = Mongo.Date("2021-01-13T05:08:13Z") },
      { _id = 7, name = "Vegan", size = "medium", price = 18,
          quantity = 10, date = Mongo.Date("2021-01-13T05:10:13Z") }
  ])
  # Run the aggregation to Calculate Total Order
  # Value and Average Order Quantity
  var result = database.run_command({
      aggregate = "test_col",
      pipeline = [
          # Stage 1: Group documents by date and calculate results
          Mongo.Group({
              _id = Mongo.DateToString({
                  format = "%Y-%m-%d",
                  date = "$date"
              }),
              totalOrderValue = 
                  Mongo.Sum(Mongo.Multiply(["$price", "$quantity"])),
              averageOrderQuantity = Mongo.Avg("$quantity")
          }),
          # Stage 2: Sort documents by totalOrderValue in descending order
          Mongo.Sort({ totalOrderValue = -1 })
      ],
      cursor = {}
  })["cursor"]["firstBatch"]
	print(result)
  ```
  Output
  ```
  [
      {
          "_id": "2022-01-12",
          "totalOrderValue": 790,
          "averageOrderQuantity": 30
      },
      {
          "_id": "2021-03-13",
          "totalOrderValue": 770,
          "averageOrderQuantity": 15
      },
      {
          "_id": "2021-03-17",
          "totalOrderValue": 630,
          "averageOrderQuantity": 30
      },
      {
          "_id": "2021-01-13",
          "totalOrderValue": 350,
          "averageOrderQuantity": 10
      }
  ]
  ```