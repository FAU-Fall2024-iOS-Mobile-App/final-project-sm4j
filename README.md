# Marvel Dream Teams

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

The **Marvel Dream Teams** app allows users to search for Marvel characters, create their own teams by adding up to 6 characters per team, and save their teams in their user accounts. The app utilizes the **Marvel API** to fetch character data and **Back4App/Parse** for user authentication. Users can also send friend requests and message their friends within the app.

### App Evaluation

**Category:** Entertainment / Social  
**Mobile:** Mobile application only  
**Story:** Users can create teams of Marvel characters, manage their teams, and interact with other users via friend requests and messages.  
**Market:** Marvel fans, comic book enthusiasts, and users interested in team-building apps.  
**Habit:** Occasional use, primarily for managing teams or discovering new characters.  
**Scope:** Narrow app, focusing on character search, team creation, and basic social interaction.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can register and log in to their account.
* User can search for Marvel characters by name, name start, or series.
* User can create a team of 6 Marvel characters.
* User can save a maximum of 10 teams.
* User can delete a team.
* User can send and receive friend requests.
* User can send messages to friends.

**Optional Nice-to-have Stories**

* User can persist their login session across app restarts.
* User can see a list of their teams and friends on their profile screen.

### 2. Screen Archetypes

- [ ] **Splash Screen**
  * Required User Feature: User sees a splash screen with the app logo and branding upon launching the app.
- [ ] **Login Screen**
  * Required User Feature: User can log in to the app using their Back4App account.
- [ ] **Character Search Screen**
  * Required User Feature: User can search for Marvel characters using name, name starts with, or series.
- [ ] **Team Creation Screen**
  * Required User Feature: User can create a team by selecting up to 6 characters.
- [ ] **Team Management Screen**
  * Required User Feature: User can view their saved teams and delete them if desired.
- [ ] **Friend Requests Screen**
  * Required User Feature: User can send and receive friend requests.
- [ ] **Messages Screen**
  * Required User Feature: User can send messages to friends.
- [ ] **Profile Screen**
  * Optional User Feature: User can view their saved teams and friend list.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

- [ ] Splash Screen
- [ ] Home Feed (Character Search)
- [ ] Team Management
- [ ] Profile (User Teams, Friends)
- [ ] Messages
- [ ] Friend Requests

**Flow Navigation** (Screen to Screen)

- [ ] **Splash Screen**
  * Leads to **Login Screen**
- [ ] **Login Screen**
  * Leads to **Character Search Screen**
- [ ] **Character Search Screen**
  * Leads to **Team Creation Screen**
- [ ] **Team Creation Screen**
  * Leads to **Team Management Screen**
- [ ] **Team Management Screen**
  * Leads to **Profile Screen**
- [ ] **Profile Screen**
  * Leads to **Friend Requests Screen**
- [ ] **Friend Requests Screen**
  * Leads to **Messages Screen**

## Wireframes

[Add picture of your hand sketched wireframes in this section]

### [BONUS] Digital Wireframes & Mockups

[Add your digital wireframes or mockups here]

### [BONUS] Interactive Prototype

[Include a link to an interactive prototype, if available]

## Schema

### Models

**User**
| Property  | Type   | Description                                   |
|-----------|--------|-----------------------------------------------|
| username  | String | Unique identifier for the user                |
| password  | String | User's password for login authentication      |
| email     | String | User's email address                          |
| teams     | Array  | Array of team objects saved by the user       |
| friends   | Array  | Array of user objects representing friends    |
| messages  | Array  | Array of message objects between friends     |

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
- [POST] `/friend_requests` - To send a friend request to another user.
- [POST] `/messages` - To send a message to a friend.
- [GET] `/users/{userID}/friends` - To retrieve a list of the user's friends.
