# Advanced SQLite with Flutter

A practical Flutter project demonstrating **advanced SQLite concepts** using `sqflite`, Clean Architecture, relational database design, transactions, JOINs, pagination, database migrations, indexes, and transaction rollback testing.

This project is part of a Flutter Local Storage learning series and focuses on moving from basic SQLite CRUD operations to **real-world relational database usage**.

---

## 📚 What This Project Demonstrates

This project covers:

* SQLite relationships
* One-to-many relationships
* Foreign keys
* `ON DELETE CASCADE`
* SQL JOINs
* JOIN pagination
* Database indexes
* Transactions
* Transaction rollback
* Transaction failure testing
* Database migrations
* Migration testing
* Data preservation during migrations
* Local sync status
* Clean Architecture
* Repository Pattern
* Data Source Pattern
* SQLite integration with Flutter

---

# 🎯 Project Goal

The goal of this project is to understand how SQLite is used in a real Flutter application when the database becomes more complex.

Instead of having only independent tables such as:

```text
users
posts
```

we create a real relationship:

```text
User
 │
 └── has many Posts
```

The project also demonstrates how multiple database operations can be treated as a single atomic operation using transactions.

---

# 🏗️ Architecture

The project follows a simplified **Clean Architecture** structure:

```text
lib/
│
├── core/
│   └── database/
│       ├── database_constants.dart
│       ├── database_helper.dart
│       ├── database_migration_test.dart
│       └── transaction_failure_test.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   ├── post.dart
│   │   └── post_with_user.dart
│   │
│   └── repositories/
│       ├── user_repository.dart
│       └── post_repository.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   └── post_with_user_model.dart
│   │
│   ├── datasources/
│   │   └── local/
│   │       ├── user_local_data_source.dart
│   │       └── post_local_data_source.dart
│   │
│   └── repositories/
│       ├── user_repository_impl.dart
│       └── post_repository_impl.dart
│
└── presentation/
    └── pages/
        ├── users_page.dart
        ├── posts_page.dart
        ├── user_posts_page.dart
        ├── migration_test_page.dart
        └── transaction_test_page.dart
```

---

# 🗄️ Database Structure

The application contains two main tables:

```text
users
  │
  │ 1
  │
  │
  │ N
posts
```

This is a **one-to-many relationship**.

One user can have many posts.

---

# 👤 Users Table

Current schema:

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  age INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'synced'
);
```

### Columns

| Column        | Type    | Description                 |
| ------------- | ------- | --------------------------- |
| `id`          | INTEGER | Primary key                 |
| `name`        | TEXT    | User name                   |
| `email`       | TEXT    | Unique email                |
| `age`         | INTEGER | User age                    |
| `created_at`  | TEXT    | Creation timestamp          |
| `updated_at`  | TEXT    | Last modification timestamp |
| `sync_status` | TEXT    | Local synchronization state |

---

# 📝 Posts Table

Current schema:

```sql
CREATE TABLE posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'synced',

  FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
```

### Columns

| Column        | Type    | Description                 |
| ------------- | ------- | --------------------------- |
| `id`          | INTEGER | Primary key                 |
| `user_id`     | INTEGER | Foreign key to `users.id`   |
| `title`       | TEXT    | Post title                  |
| `body`        | TEXT    | Post content                |
| `created_at`  | TEXT    | Creation timestamp          |
| `updated_at`  | TEXT    | Last modification timestamp |
| `sync_status` | TEXT    | Local synchronization state |

---

# 🔗 Relationships

The relationship is:

```text
users.id
   │
   │
   ▼
posts.user_id
```

For example:

```text
User 1
 ├── Post 1
 ├── Post 2
 └── Post 3

User 2
 ├── Post 4
 └── Post 5
```

This is a:

```text
One User → Many Posts
```

relationship.

---

# 🔐 Foreign Keys

The posts table uses:

```sql
FOREIGN KEY (user_id)
REFERENCES users(id)
ON DELETE CASCADE
ON UPDATE CASCADE
```

This prevents posts from referencing a user that doesn't exist.

The application also enables foreign key enforcement:

```sql
PRAGMA foreign_keys = ON;
```

---

# 🗑️ ON DELETE CASCADE

Because the relationship uses:

```sql
ON DELETE CASCADE
```

deleting a user automatically deletes that user's posts.

Example:

```text
Before:

User 1
 ├── Post 1
 ├── Post 2
 └── Post 3

Delete User 1

After:

User 1 ❌
Post 1 ❌
Post 2 ❌
Post 3 ❌
```

This is useful when child records should not exist without their parent.

---

# 🔎 SQL JOIN

The application demonstrates retrieving posts together with their users.

Example:

```sql
SELECT
  users.id AS user_id,
  users.name AS user_name,
  users.email AS user_email,

  posts.id AS post_id,
  posts.title AS post_title,
  posts.body AS post_body

FROM users

INNER JOIN posts
  ON users.id = posts.user_id;
```

Instead of doing:

```text
Get posts
    ↓
For every post
    ↓
Get user separately
```

we can retrieve the related data using one JOIN query.

---

# 🚀 JOIN Pagination

The Posts page implements real SQL pagination.

The query uses:

```sql
LIMIT ?
OFFSET ?
```

For example:

```text
Page 1:
LIMIT 10
OFFSET 0

Page 2:
LIMIT 10
OFFSET 10

Page 3:
LIMIT 10
OFFSET 20
```

The calculation is:

```dart
final offset = (page - 1) * pageSize;
```

The resulting SQL concept is:

```sql
SELECT ...
FROM users
INNER JOIN posts
  ON users.id = posts.user_id
ORDER BY posts.created_at DESC
LIMIT 10
OFFSET 20;
```

This prevents the application from loading every post into memory at once.

---

# 📑 Pagination Flow

The Posts page uses lazy loading:

```text
Open Posts Page
       ↓
Load Page 1
       ↓
Display 10 posts
       ↓
User scrolls
       ↓
Near bottom?
       ↓
Load Page 2
       ↓
Display next 10 posts
       ↓
Continue...
```

---

# ⚡ Database Indexes

The project creates indexes for frequently queried columns.

```sql
CREATE INDEX idx_posts_user_id
ON posts(user_id);
```

```sql
CREATE INDEX idx_posts_created_at
ON posts(created_at);
```

```sql
CREATE INDEX idx_posts_sync_status
ON posts(sync_status);
```

```sql
CREATE INDEX idx_users_sync_status
ON users(sync_status);
```

Indexes can significantly improve query performance when tables become large.

---

# 💡 Why Index `user_id`?

The application frequently performs:

```sql
WHERE user_id = ?
```

and:

```sql
JOIN posts
ON users.id = posts.user_id
```

Therefore:

```text
posts.user_id
```

is a good candidate for an index.

---

# 🔄 Transactions

The project includes a real transaction feature:

```text
Create User + First Post
```

Instead of:

```text
INSERT User

INSERT Post
```

as two independent operations, both operations are placed inside one transaction.

```text
BEGIN
  │
  ├── INSERT User
  │
  ├── Get generated User ID
  │
  └── INSERT First Post
  │
COMMIT
```

---

# 👤 Create User + First Post

The application provides:

```text
Create
├── Create User
└── Create User + First Post
```

When the second option is selected, the app collects:

### User

* Name
* Email
* Age

### First Post

* Title
* Body

Then the database performs:

```text
Transaction
     ↓
Insert User
     ↓
Get generated user ID
     ↓
Insert Post with user ID
     ↓
Commit
```

---

# 🔐 Transaction Atomicity

The important property of a transaction is **atomicity**.

The operation should behave as one unit.

Either:

```text
User + Post
```

are both saved,

or:

```text
User + Post
```

are both rejected.

We don't want:

```text
User ✅
Post ❌
```

when the operation is supposed to create both.

---

# ❌ Transaction Rollback Testing

The project contains a dedicated transaction failure test.

The test intentionally throws an exception:

```dart
throw Exception(
  'Simulated post insertion failure',
);
```

The test simulates:

```text
BEGIN TRANSACTION
       ↓
INSERT USER
       ↓
ERROR ❌
       ↓
ROLLBACK
```

Then it checks the database.

Expected result:

```text
User does not exist
Post does not exist
```

This proves that the transaction was rolled back successfully.

---

# 🧪 Transaction Test Output

The application can display:

```text
✓ Test database created
✓ User inserted inside transaction
✓ Simulating post insertion failure...
✓ Transaction failed as expected
✓ User was rolled back
✓ No post was saved
✓ Transaction rollback verified successfully
```

---

# 🗃️ Database Migrations

The project demonstrates database versioning.

The current database version is:

```dart
static const int databaseVersion = 3;
```

The database evolves through three versions.

---

# Version 1

Initial schema:

```text
users
├── id
├── name
├── email
├── age
└── created_at

posts
├── id
├── user_id
├── title
├── body
└── created_at
```

---

# Version 2

Version 2 adds:

```text
updated_at
```

to both tables.

```text
users
├── ...
├── created_at
└── updated_at

posts
├── ...
├── created_at
└── updated_at
```

The migration uses:

```sql
ALTER TABLE users
ADD COLUMN updated_at TEXT;
```

and:

```sql
UPDATE users
SET updated_at = created_at;
```

The same process is used for posts.

---

# Version 3

Version 3 adds:

```text
sync_status
```

to both tables.

It also creates indexes.

```text
users
├── ...
├── updated_at
└── sync_status

posts
├── ...
├── updated_at
└── sync_status
```

---

# 🔄 Migration Flow

The database evolution is:

```text
V1
 │
 │ Add updated_at
 ▼
V2
 │
 │ Add sync_status
 │ Add indexes
 ▼
V3
```

This is important because production applications cannot simply delete the database every time the schema changes.

Existing user data must survive database upgrades.

---

# 🧪 Migration Testing

The project includes a migration testing screen.

The test creates a temporary V1 database:

```text
Create V1
   ↓
Insert test data
   ↓
Migrate V1 → V2
   ↓
Verify updated_at
   ↓
Migrate V2 → V3
   ↓
Verify sync_status
   ↓
Verify indexes
   ↓
Verify original data
```

---

# Migration Test Verification

The test verifies:

* V1 database can be created
* V1 data can be inserted
* V1 → V2 migration works
* `updated_at` exists
* V2 → V3 migration works
* `sync_status` exists
* required indexes exist
* original user data survives
* original post data survives

Example output:

```text
✓ Created database version 1
✓ Inserted V1 test data
✓ Migrated V1 → V2
✓ updated_at columns exist
✓ Migrated V2 → V3
✓ sync_status columns exist
✓ Original data preserved
✓ All indexes exist
✓ Migration test database cleaned
```

---

# 📦 Domain Entities

The project separates database models from domain entities.

## User

```dart
class User {
  final int? id;
  final String name;
  final String email;
  final int age;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });
}
```

---

# Post

```dart
class Post {
  final int? id;
  final int userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const Post({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });
}
```

---

# PostWithUser

`PostWithUser` represents the result of a JOIN.

```dart
class PostWithUser {
  final Post post;
  final User user;

  const PostWithUser({
    required this.post,
    required this.user,
  });
}
```

Conceptually:

```text
PostWithUser
├── Post
└── User
```

This keeps the JOIN result clean at the domain level.

---

# 🧱 Data Models

Database records are converted into Dart models.

The main models are:

```text
UserModel
PostModel
PostWithUserModel
```

They are responsible for converting between:

```text
SQLite Map
    ↕
Dart Model
```

For example:

```dart
UserModel.fromMap(...)
```

and:

```dart
user.toMap()
```

---

# 🗂️ Data Sources

The local data sources communicate directly with SQLite.

### UserLocalDataSource

Responsible for:

```text
Insert User
Get Users
Get User By ID
Update User
Delete User
Create User + First Post
```

### PostLocalDataSource

Responsible for:

```text
Insert Post
Get Posts By User
Get Paginated Posts
JOIN Posts + Users
Get Pending Posts
Update Post
Delete Post
```

---

# 🏛️ Repository Layer

The repository separates the domain layer from the database implementation.

Example:

```text
Presentation
     ↓
Repository
     ↓
Local Data Source
     ↓
SQLite
```

The domain layer doesn't need to know that SQLite is being used.

---

# 📱 Application Features

The application contains several screens.

## Users Page

Features:

* Display users
* Create user
* Delete user
* Open user's posts
* Create user + first post
* Show synchronization status

---

## User Posts Page

Features:

* Display posts belonging to a user
* Create post
* Update post
* Delete post
* Refresh posts
* Display sync status

---

## Posts Page

Features:

* Display all posts
* Display post owner
* SQL JOIN
* Pagination
* Infinite scrolling
* Pull-to-refresh
* Synchronization status

---

## Migration Test Page

Features:

* Run migration test
* Test V1 → V2
* Test V2 → V3
* Verify columns
* Verify indexes
* Verify data preservation

---

## Transaction Test Page

Features:

* Run transaction rollback test
* Simulate transaction failure
* Verify rollback
* Verify no partial data remains

---

# 🔄 Sync Status

The database contains a:

```text
sync_status
```

field.

Possible values used by the application include:

```text
synced
pending
failed
conflict
```

For example, when a user creates a record locally:

```text
Create User
    ↓
SQLite
    ↓
sync_status = pending
```

This prepares the project for the next stage:

```text
Offline-first Architecture
```

---

# 🌐 Offline-First Preparation

Although this project does not implement a complete remote API synchronization system, the database is prepared for it.

The intended flow is:

```text
Application
    ↓
SQLite
    ↓
Display cached data
    ↓
Remote API
    ↓
Sync changes
```

Local modifications can use:

```text
pending
```

while successful synchronization can change the state to:

```text
synced
```

---

# 🧠 Key SQLite Concepts Learned

After completing this project, you should understand:

### Relationships

```text
One-to-many
User → Posts
```

### Foreign Keys

```text
posts.user_id
        ↓
users.id
```

### Cascading

```text
Delete User
    ↓
Delete User's Posts
```

### JOINs

```text
users + posts
```

### Pagination

```text
LIMIT + OFFSET
```

### Indexes

```text
Faster frequently-used queries
```

### Transactions

```text
Multiple operations → one atomic operation
```

### Rollback

```text
Failure → undo transaction
```

### Migrations

```text
V1 → V2 → V3
```

### Migration Testing

```text
Verify schema + data after migration
```

---

# ⚙️ Dependencies

The project uses:

```yaml
dependencies:
  flutter:
    sdk: flutter

  sqflite: ^2.4.2
  path: ^1.9.1
```

Run:

```bash
flutter pub get
```

---

# ▶️ Running the Project

Clone the repository:

```bash
git clone <your-repository-url>
```

Navigate into the project:

```bash
cd sqlite_part_2
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# 🧪 Testing the Features

## Test 1 — Create User

Go to:

```text
Users
    ↓
Create
    ↓
Create User
```

Enter the user information.

The user should appear in the list.

---

## Test 2 — Create User + First Post

Go to:

```text
Users
    ↓
Create
    ↓
Create User + First Post
```

Enter:

```text
User
Name
Email
Age

Post
Title
Body
```

Press:

```text
Create
```

Both records should be created in one transaction.

---

## Test 3 — JOIN Pagination

Create multiple users and posts.

Open:

```text
Posts
```

Scroll down.

The application should load:

```text
Page 1
Page 2
Page 3
...
```

Each post should display its related user.

---

## Test 4 — Migration

Open:

```text
Migration Test
```

Press:

```text
Run Migration Test
```

The application should report:

```text
Migration Test Passed
```

---

## Test 5 — Transaction Rollback

Open:

```text
Transaction Test
```

Press:

```text
Run Rollback Test
```

The test intentionally fails inside a transaction.

The expected result is:

```text
User inserted
     ↓
Failure
     ↓
Rollback
     ↓
User removed
```

The test should report:

```text
Transaction rollback verified successfully
```

---

# 🧹 Development Notes

During development, database schema changes can sometimes cause conflicts with an already-created local database.

For this learning project, if you intentionally change the schema without creating the appropriate migration, you can clear the application's local database data and run the app again.

In a production application, **do not simply delete the user's database**. Create a proper migration.

---

# ⚠️ Important Production Considerations

This project is designed for learning and demonstration.

For a production application, consider:

* More robust migration strategies
* Automated migration tests
* Repository error handling
* Database transaction boundaries
* Soft deletes for synchronized data
* Conflict resolution
* Background synchronization
* Database encryption when required
* Query performance analysis
* Proper pagination strategy for very large datasets
* Unit and integration tests
* Backup and recovery strategies

---

# 📈 What Comes Next?

This project prepares the foundation for the next local-storage topics:

```text
SQLite
  ↓
Drift
  ↓
Hive
  ↓
Isar
  ↓
SharedPreferences
  ↓
Secure Storage
  ↓
Encrypted Database
  ↓
Offline-First Architecture
  ↓
Cache
  ↓
Synchronization
  ↓
Conflict Resolution
```

The next major step is to take this SQLite database and implement a real:

```text
Offline-First Architecture
```

with:

```text
Local SQLite
     +
Remote API
     +
Synchronization
     +
Pending Changes
     +
Conflict Resolution
```

---

# 🎓 Learning Outcome

After completing SQLite Part 2, you should be comfortable with more than basic CRUD.

You should understand how to build a relational SQLite layer that supports:

```text
                SQLite
                   │
        ┌──────────┴──────────┐
        │                     │
      Users                  Posts
        │                     │
        └──── Relationship ───┘
                   │
                 JOIN
                   │
              Pagination
                   │
                Indexes
                   │
              Transactions
                   │
                Rollback
                   │
               Migration
                   │
             Migration Tests
```

This is the foundation for building more reliable and scalable local data layers in Flutter.

---

## ⭐ Topics Covered

* [x] SQLite relationships
* [x] One-to-many relationship
* [x] Foreign keys
* [x] Cascade delete
* [x] JOIN
* [x] JOIN pagination
* [x] SQL indexes
* [x] Transactions
* [x] Transaction rollback
* [x] Transaction failure testing
* [x] Database migrations
* [x] V1 → V2 migration
* [x] V2 → V3 migration
* [x] Migration testing
* [x] Data preservation
* [x] Clean Architecture
* [x] Repository Pattern
* [x] Local Data Source Pattern
* [x] Flutter UI integration
* [x] Sync status foundation
* [x] Offline-first preparation

---

## 📌 Part of Flutter Local Storage Mastery

**Phase 7 — Local Storage**

This repository focuses specifically on:

> **SQLite — Advanced / Part 2**

The purpose is to learn not only how to store data locally, but how to design and maintain a reliable relational local database in a real Flutter application.
