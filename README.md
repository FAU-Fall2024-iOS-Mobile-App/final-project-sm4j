# Marvel Dream Teams

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)
5. [Media](#Media)

## Overview

### Description

The **Marvel Dream Teams** app allows users to search for Marvel characters, create their own teams by adding up to 6 characters per team, and save those teams in their user accounts. The app uses the **Marvel API** to fetch character data and **Back4App/Parse** for user authentication. Users can also send friend requests and message their friends if they choose to use these optional features.

### App Evaluation

**Category:** Entertainment / Social  
**Mobile:** Mobile application only  
**Story:** Users can create teams of Marvel characters, manage their teams, and optionally interact with other users via friend requests and messages.  
**Market:** Marvel fans, comic book enthusiasts, and users interested in team-building apps.  
**Habit:** Occasional use, primarily for managing teams or discovering new characters.  
**Scope:** Narrow app, focusing on character search, team creation, and optional social interaction.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can register and log in to their account.
- [x] User can search for Marvel characters by name, name start, or series.
- [x] User can create a team of 6 Marvel characters.
- [x] User can save a maximum of 10 teams.
- [x] User can delete a team.
- [x] User can view their saved teams.
- [x] User can view detailed information about each character, including name, description, and image.

**Optional Nice-to-have Stories**

- [x] User can persist their login session across app restarts.
- [ ] User can send and receive friend requests.
- [ ] User can send messages to friends.
- [ ] User can view their profile with saved teams and friends list (if friend feature is used).

### 2. Screen Archetypes

- [x] **Splash Screen**
  * Required User Feature: User sees a splash screen with the app logo and branding upon launching the app.
- [x] **Login Screen**
  * Required User Feature: User can log in to the app using their Back4App account.
- [x] **Sign Up Screen**
  * Required User Feature: User can sign up for a Back4app account.
- [x] **Character Search Screen**
  * Required User Feature: User can search for Marvel characters using name, name starts with, or series.
- [x] **Character Info Screen**
  * Required User Feature: User can view detailed character information, including name, description, and image.
- [x] **Team Creation Screen**
  * Required User Feature: User can create a team by selecting up to 6 characters.
- [x] **Team Management Screen**
  * Required User Feature: User can view their saved teams, which are displayed as a stack list with distinct selectable colors or icons.
  * Required User Feature: User can select a team from the list, which leads to a detailed view of the team.
- [ ] **Profile Screen** (Optional)
  * User can view their saved teams and friend list (if friend feature is used).
- [ ] **Friend Requests Screen** (Optional)
  * Optional User Feature: User can send and receive friend requests.
- [ ] **Messages Screen** (Optional)
  * Optional User Feature: User can send messages to friends.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

- [x] Home Feed (Character Search)
- [x] Team Management
- [x] Team Creation
- [ ] Profile (Optional)
- [ ] Messages (Optional)
- [ ] Friend Requests (Optional)

**Flow Navigation** (Screen to Screen)

- [x] **Splash Screen**
  * Leads to **Login Screen**
- [x] **Login Screen**
  * Leads to **Character Search Screen**
  * Leads to **Sign Up Screen**
- [x] **Sign Up Screen**
  * Leads to **Character Search Screen**
- [x] **Character Search Screen**
  * Leads to **Character Info Screen**
  * Leads to **Team Management Screen**
- [x] **Character Info Screen**
  * Leads back to **Character Search Screen** or **Team Detail Screen**
- [x] **Team Management Screen**
  * Leads to **Team Creation Screen**
  * Leads to **Team Detail Screen** (Displays selected team and its members)
- [x] **Team Detail Screen**
  * Leads to **Character Info Screen** (for viewing individual character info)
- [ ] **Profile Screen** (Optional)
  * Leads to **Friend Requests Screen** (Optional)
  * Leads to **Messages Screen** (Optional)
- [ ] **Friend Requests Screen** (Optional)
  * Leads back to **Profile Screen** (Optional)
- [ ] **Messages Screen** (Optional)
  * Leads back to **Profile Screen**

## Wireframes

![Wireframe](https://i.imgur.com/SmetTqA.png)

## Schema

### Models

**User**
| Property  | Type   | Description                                   |
|-----------|--------|-----------------------------------------------|
| username  | String | Unique identifier for the user                |
| password  | String | User's password for login authentication      |
| email     | String | User's email address                          |
| teams     | Array  | Array of team objects saved by the user       |
| friends   | Array  | Array of user objects representing friends (optional) |
| messages  | Array  | Array of message objects between friends (optional) |

**Character**
| Property    | Type   | Description                                   |
|-------------|--------|-----------------------------------------------|
| name        | String | Name of the Marvel character                  |
| description | String | Short description of the character            |
| imageURL    | String | URL for the character's image                 |
| series      | String | The Marvel series the character appears in    |

**Team**
| Property    | Type   | Description                                   |
|-------------|--------|-----------------------------------------------|
| name        | String | Name of the team                              |
| characters  | Array  | Array of character objects in the team        |
| userID      | String | ID of the user who created the team           |

### Networking

- [GET] `/characters` - To retrieve a list of characters based on search parameters.
- [POST] `/users/register` - To register a new user.
- [POST] `/users/login` - To log in a user.
- [POST] `/teams` - To create a new team.
- [DELETE] `/teams/{teamID}` - To delete an existing team.
- [POST] `/friend_requests` (optional) - To send a friend request to another user.
- [POST] `/messages` (optional) - To send a message to a friend.
- [GET] `/users/{userID}/friends` (optional) - To retrieve a list of the user's friends.

## Media

### Milestone 8 Progress

![Guide](https://i.imgur.com/EE1Bawb.gif)

### Milestone 9 Progress

![Guide](https://i.imgur.com/BFzlzs0.gif)
