# SQLite in Flutter

SQLite is a lightweight relational database engine that stores structured data locally inside the application.

In Flutter, SQLite is commonly used when an application needs to store multiple records, relationships, structured data, search data, or offline application data.

This project demonstrates SQLite using the `sqflite` package and integrates it with Clean Architecture.

---

# 1. Introduction

SQLite is a relational database management system that runs directly inside an application.

Unlike a traditional database such as MySQL or PostgreSQL:

- SQLite does not require a separate database server.
- The database is stored as a file.
- SQL is used to create and manipulate data.
- The database exists locally on the device.

A simplified architecture looks like this:

```text
Flutter Application
       |
       v
Repository
       |
       v
Local Data Source
       |
       v
sqflite
       |
       v
SQLite Database
       |
       v
users.db
```

SQLite stores structured data using:

```text
Database
   |
   +── Tables
          |
          +── Rows
                 |
                 +── Columns
```

Example:

```text
users

+----+----------+---------------------+-----+
| id | name     | email               | age |
+----+----------+---------------------+-----+
| 1  | Ahmad    | ahmad@example.com   | 25  |
| 2  | Ali      | ali@example.com     | 30  |
+----+----------+---------------------+-----+
```

---

# 2. Why SQLite Exists

SQLite exists because applications sometimes need a real database locally.

For example, SharedPreferences is good for:

```text
theme = dark
isLoggedIn = true
language = en
```

But it is not designed for:

```text
1000 users
500 products
orders
messages
relationships
searching
sorting
filtering
transactions
```

SQLite provides:

- Tables
- Rows
- Columns
- Primary keys
- Foreign keys
- Indexes
- SQL queries
- Transactions
- Constraints
- Relationships
- Aggregations
- Sorting
- Filtering

Therefore:

```text
SharedPreferences
        ↓
Simple key-value data

SQLite
        ↓
Structured relational data
```

---

# 3. When to Use SQLite

Use SQLite when your application needs structured local data.

Good examples:

### Offline applications

An application can continue working without an internet connection.

```text
API
 ↓
SQLite
 ↓
Flutter UI
```

### Messaging

Store:

- conversations
- messages
- users
- timestamps
- message status

### E-commerce

Store:

- products
- categories
- cart
- orders

### Notes application

Store:

```text
id
title
content
createdAt
updatedAt
```

### Caching API data

The application can store server responses locally.

```text
Server
   ↓
SQLite
   ↓
Application
```

---

# 4. When NOT to Use SQLite

SQLite is not always the correct solution.

Do not use SQLite for simple key-value preferences.

For example:

```text
theme = dark
language = en
firstLaunch = false
```

Use SharedPreferences instead.

Do not use SQLite when you need:

- Server-side shared data
- Multiple users accessing the same database remotely
- Large centralized datasets
- Complex server-side database operations

For these situations, consider:

- PostgreSQL
- MySQL
- MongoDB
- Other server databases

Also remember that SQLite is a local database.

A user's SQLite database is not automatically synchronized with another user's SQLite database.

---

# 5. Core Concepts

## 5.1 Database

The database is the container for tables.

Example:

```text
app.db
```

---

## 5.2 Table

A table stores a specific type of data.

Example:

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    age INTEGER NOT NULL
);
```

---

## 5.3 Row

A row represents one record.

Example:

```text
1 | Ahmad | ahmad@example.com | 25
```

---

## 5.4 Column

Columns describe the properties of a record.

```text
id
name
email
age
```

---

## 5.5 Primary Key

A primary key uniquely identifies a row.

Example:

```sql
id INTEGER PRIMARY KEY AUTOINCREMENT
```

This means SQLite automatically generates:

```text
1
2
3
4
...
```

---

## 5.6 Data Types

SQLite commonly uses:

```text
INTEGER
REAL
TEXT
BLOB
NULL
```

Example:

```sql
id INTEGER
name TEXT
price REAL
image BLOB
deletedAt NULL
```

SQLite has dynamic typing, so its type system is more flexible than databases such as PostgreSQL.

---

## 5.7 CRUD

CRUD means:

```text
C → Create
R → Read
U → Update
D → Delete
```

Example:

```text
INSERT
SELECT
UPDATE
DELETE
```

---

# 6. Flutter Implementation

Flutter does not directly provide the complete SQLite API.

A common solution is the `sqflite` package.

Install:

```bash
flutter pub add sqflite
flutter pub add path
```

The application uses:

```dart
import 'package:sqflite/sqflite.dart';
```

and:

```dart
import 'package:path/path.dart';
```

`sqflite` provides helpers for insert, query, update and delete operations, transactions, batches, and database version management. It also executes database operations away from the main UI thread on Android and iOS.

---

# 7. Database Creation

A database can be opened with:

```dart
final database = await openDatabase(
  path,
  version: 1,
);
```

When the database does not exist, `onCreate` is called.

Example:

```dart
onCreate: (db, version) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      age INTEGER NOT NULL
    )
  ''');
}
```

---

# 8. Insert Data

Using the sqflite helper:

```dart
await db.insert(
  'users',
  {
    'name': 'Ahmad',
    'email': 'ahmad@example.com',
    'age': 25,
  },
);
```

SQLite creates the ID automatically.

---

# 9. Read Data

Read all users:

```dart
final rows = await db.query('users');
```

The result is:

```dart
List<Map<String, dynamic>>
```

Example:

```dart
[
  {
    'id': 1,
    'name': 'Ahmad',
    'email': 'ahmad@example.com',
    'age': 25,
  }
]
```

---

# 10. Read One Record

```dart
final rows = await db.query(
  'users',
  where: 'id = ?',
  whereArgs: [1],
  limit: 1,
);
```

The `?` placeholder is important.

Prefer:

```dart
where: 'id = ?',
whereArgs: [id],
```

instead of dynamically constructing SQL.

---

# 11. Update Data

```dart
await db.update(
  'users',
  {
    'name': 'Updated Name',
    'age': 30,
  },
  where: 'id = ?',
  whereArgs: [id],
);
```

---

# 12. Delete Data

Delete one record:

```dart
await db.delete(
  'users',
  where: 'id = ?',
  whereArgs: [id],
);
```

Delete all:

```dart
await db.delete('users');
```

Be careful with:

```dart
db.delete('users');
```

because it removes every row.

---

# 13. Search

Example:

```dart
final rows = await db.query(
  'users',
  where: 'name LIKE ?',
  whereArgs: ['%ahmad%'],
);
```

---

# 14. Sorting

```dart
final rows = await db.query(
  'users',
  orderBy: 'name ASC',
);
```

---

# 15. Limiting Results

```dart
final rows = await db.query(
  'users',
  limit: 20,
);
```

---

# 16. Transactions

Transactions are important when multiple operations must succeed or fail together.

Example:

```dart
await db.transaction((txn) async {
  final userId = await txn.insert('users', user);

  await txn.insert('logs', {
    'userId': userId,
    'action': 'created',
  });
});
```

If an operation fails, the transaction can roll back.

Use transactions for operations such as:

```text
Create Order
    ↓
Create Order Items
    ↓
Update Inventory
```

These operations should usually be treated as one atomic operation.

---

# 17. Batch Operations

When multiple independent database operations need to be performed, a batch can be useful.

Example:

```dart
final batch = db.batch();

batch.insert('users', user1);
batch.insert('users', user2);
batch.update(
  'users',
  {'age': 30},
  where: 'id = ?',
  whereArgs: [1],
);

await batch.commit();
```

---

# 18. Database Versioning and Migration

Databases change as applications evolve.

Version 1:

```text
users
- id
- name
- email
```

Later version 2:

```text
users
- id
- name
- email
- age
```

Increase:

```dart
version: 2
```

Then:

```dart
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    await db.execute(
      'ALTER TABLE users ADD COLUMN age INTEGER NOT NULL DEFAULT 0',
    );
  }
}
```

Never casually delete the user's database to solve migration problems in production.

Use migrations.

---

# 19. Model ↔ SQLite Map

SQLite works with maps:

```dart
Map<String, dynamic>
```

Your application should preferably work with domain objects.

Example:

```dart
class User {
  final int? id;
  final String name;
  final String email;
  final int age;
}
```

Convert:

```text
SQLite Map
    ↓
User Model
```

and:

```text
User Model
    ↓
SQLite Map
```

This keeps database details away from the presentation layer.

---

# 20. Clean Architecture Integration

A clean architecture implementation can look like:

```text
Presentation
     ↓
Domain Repository
     ↓
Repository Implementation
     ↓
Local Data Source
     ↓
Database Helper
     ↓
SQLite
```

Responsibilities:

### Presentation

Displays UI.

Should not contain SQL.

### Domain

Defines business entities and repository contracts.

Should not know about `sqflite`.

### Data

Converts database data into domain objects.

### Local Data Source

Communicates with SQLite.

### Database Helper

Responsible for:

- Opening database
- Creating tables
- Migration
- Database configuration

---

# 21. Real-World Example

Imagine an offline-first shopping application.

The API returns:

```text
Product
```

The application stores it locally:

```text
API
 ↓
Repository
 ↓
SQLite
 ↓
UI
```

When the user opens the application without internet:

```text
SQLite
 ↓
Products
 ↓
UI
```

When internet becomes available:

```text
API
 ↓
Synchronization
 ↓
SQLite
 ↓
UI
```

SQLite becomes the local source of structured data.

---

# 22. Common Mistakes

## Mistake 1: SQL inside widgets

Avoid:

```dart
onPressed: () async {
  final db = await openDatabase(...);
  await db.insert(...);
}
```

inside a widget.

Database logic belongs in the data layer.

---

## Mistake 2: No primary key

Tables should normally have a reliable identifier.

---

## Mistake 3: Building SQL using string interpolation

Avoid:

```dart
'SELECT * FROM users WHERE name = "$name"'
```

Prefer parameter binding:

```dart
'SELECT * FROM users WHERE name = ?'
```

with:

```dart
[name]
```

---

## Mistake 4: No migration strategy

Changing:

```text
version 1 → version 2 → version 3
```

requires migration planning.

---

## Mistake 5: Loading thousands of rows

Avoid blindly doing:

```dart
SELECT * FROM users
```

when the table contains a huge amount of data.

Use:

- pagination
- LIMIT
- indexes
- appropriate queries

---

## Mistake 6: No indexes

Frequently searched columns may need indexes.

Example:

```sql
CREATE INDEX idx_users_email
ON users(email);
```

---

## Mistake 7: Treating SQLite like SharedPreferences

SQLite is a relational database.

Do not store everything as one giant JSON string unless there is a specific reason.

---

# 23. Senior-Level Considerations

A senior developer should think beyond CRUD.

Important topics include:

### Database schema design

Think about:

```text
Primary keys
Foreign keys
Constraints
Normalization
Relationships
Indexes
```

### Query performance

Understand:

```text
Indexes
WHERE
ORDER BY
JOIN
LIMIT
OFFSET
```

### Transactions

Use transactions when multiple operations must be atomic.

### Migrations

Plan database changes carefully.

### Concurrency

Understand that multiple parts of an application may access the database.

Avoid uncontrolled database initialization.

### Connection lifecycle

Usually keep a controlled database instance rather than opening a new database connection for every operation.

### Error handling

Handle:

```text
DatabaseException
Constraint failures
Migration failures
Invalid queries
```

### Offline-first architecture

SQLite can become the local source of truth.

```text
Remote API
    ↓
Repository
    ↓
Local Database
    ↓
Application
```

### Security

SQLite itself should not be treated as an encryption mechanism.

If sensitive data needs database-level encryption, consider an appropriate encrypted SQLite solution.

### Testing

Test:

- database creation
- migrations
- insert
- query
- update
- delete
- transactions
- repository behavior

---

# 24. Demo Implementation

This project demonstrates a complete user CRUD workflow.

The UI supports:

```text
Create User
     ↓
Read Users
     ↓
Search Users
     ↓
Update User
     ↓
Delete User
```

The architecture is:

```text
SQLiteDemoPage
       ↓
UserRepository
       ↓
UserRepositoryImpl
       ↓
UserLocalDataSource
       ↓
DatabaseHelper
       ↓
SQLite
```

---

# 25. Demo Database Schema

The project uses:

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  age INTEGER NOT NULL
)
```

Example data:

```text
1 | Ahmad | ahmad@example.com | 25
2 | Ali   | ali@example.com   | 30
3 | Omar  | omar@example.com  | 28
```

---

# 26. CRUD Summary

### Create

```dart
insert()
```

### Read

```dart
query()
```

### Update

```dart
update()
```

### Delete

```dart
delete()
```

### Search

```dart
query(
  where: 'name LIKE ?',
)
```

### Count

```sql
SELECT COUNT(*) FROM users
```

---

# 27. SQLite vs SharedPreferences

| Feature | SharedPreferences | SQLite |
|---|---|---|
| Key-value data | Excellent | Possible but unnecessary |
| Structured records | Poor | Excellent |
| Tables | No | Yes |
| SQL | No | Yes |
| Relationships | No | Yes |
| Search | Limited | Excellent |
| Sorting | Limited | Excellent |
| Transactions | No | Yes |
| Large datasets | Not ideal | Better |
| Offline database | No | Yes |
| Simple settings | Excellent | Overkill |

---

# 28. SQLite vs Remote Database

SQLite:

```text
Device
  ↓
Local database
```

Remote database:

```text
Flutter
   ↓
API
   ↓
Server
   ↓
Database
```

They solve different problems.

A real application can use both:

```text
Flutter
   ↓
Repository
   ↓
 ┌──────────────┐
 │              │
SQLite         API
 │              │
 └──────┬───────┘
        ↓
   Synchronization
```

---

# 29. What You Should Understand After This Demo

After completing this project, you should understand:

- What SQLite is
- Why SQLite exists
- Tables
- Rows
- Columns
- Primary keys
- CRUD
- SQL queries
- Search
- Sorting
- Transactions
- Batch operations
- Migrations
- Database versioning
- Models
- Repository pattern
- Local data sources
- Clean Architecture
- SQLite performance considerations
- Offline-first foundations

---

# 30. Short Summary

SQLite is a local relational database.

Use it when your Flutter application needs structured local data.

The basic flow is:

```text
Flutter UI
    ↓
Repository
    ↓
Local Data Source
    ↓
SQLite
```

The most important operations are:

```text
INSERT
SELECT
UPDATE
DELETE
```

At senior level, don't stop at CRUD.

Understand:

```text
Schema
Indexes
Transactions
Migrations
Relationships
Performance
Error Handling
Offline-first
Synchronization
Testing
```

The goal is not simply to know how to execute SQL.

The goal is to know **where database logic belongs, how to design the database, and how to use it reliably in a scalable Flutter application.**