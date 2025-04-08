# Express Flash Cards

## Table of Contents

- [Project Description](#project-description)
- [Tech Stack](#tech-stack)
- [Getting Started Locally](#getting-started-locally)
- [Available Scripts](#available-scripts)
- [Project Scope](#project-scope)
- [Project Status](#project-status)
- [License](#license)

## Project Description

Express Flash Cards is a web application that facilitates effective learning through spaced repetition flashcards. It supports AI-assisted flashcard generation from user-provided text (up to 1000 characters) as well as manual flashcard creation. Users can manage their flashcards and organize them into collections, all within a secure environment provided by a basic authentication system.

## Tech Stack

- **Ruby 3.3**
- **Ruby on Rails 8** (with Turbo Drive, Turbo Frames, and Stimulus)
- **SQLite3** (with litestream gem for backups)

Additional key components from the project include:

- **Puma**: Web server
- **Importmap Rails**: JavaScript with ESM import maps
- **Turbo Rails**: SPA-like page acceleration
- **Stimulus Rails**: Modern JavaScript framework
- **Jbuilder**: JSON API creation
- Other gems like propshaft, solid_cache, solid_queue, and more used to enhance performance and functionality.

## Getting Started Locally

### Prerequisites

- Ruby (version 3.3 recommended)
- Rails (version 8.0.1 or later)
- SQLite3

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/express_flash_cards.git
   cd express_flash_cards
   ```
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Set up the database:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```
4. Start the Rails server:
   ```bash
   bin/rails server
   ```
5. Open your browser and navigate to `http://localhost:3000` to view the application.

## Available Scripts

- `bin/rails server` - Starts the Rails web server.
- `bin/rails console` - Opens the Rails interactive console.
- `bin/rails db:migrate` - Runs database migrations.
- `bin/rails test` - Executes the test suite.

Additional commands such as `bin/rails db:rollback` or `bin/rails db:seed` may also be used as needed.

## Project Scope

The project is designed as an MVP (Minimum Viable Product) and includes the following features:

- **AI-Assisted Flashcard Generation**: Generate flashcards from a text input (up to 1000 characters).
- **Manual Flashcard Creation**: Allow users to create flashcards by manually entering the question (front) and answer (back).
- **Flashcard Management**: View, edit, and delete flashcards.
- **Collection Management**: Create, edit, and organize flashcard collections, with options to assign flashcards to one or multiple collections.
- **Spaced Repetition Integration**: Schedule flashcard reviews based on a spaced repetition algorithm.
- **User Authentication**: Enable secure access through user registration and login processes.
- **Statistics Tracking**: Monitor AI-generated flashcards versus manually created ones, along with user acceptance rates.

**Note:** The MVP scope focuses on core functionalities, and future iterations may expand upon these features.

## Project Status

This project is currently in the MVP stage with core functionalities under active development. Future enhancements and refinements are planned as the project evolves.

## License

This project is licensed under the MIT License.
