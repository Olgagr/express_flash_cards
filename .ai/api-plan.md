# REST API Plan

## 1. Resources

- **Users** (database table: users)

  - Columns: id (PK), email_address, password_digest, created_at, updated_at

- **Flashcards** (database table: flashcards)

  - Columns: id (PK), user_id (FK), front_content, back_content, flashcard_type, created_at, updated_at
  - Check Constraint: flashcard_type must be one of "manual", "ai", or "edited_ai"
  - Indexed on user_id and flashcard_type

- **Collections** (database table: collections)

  - Columns: id (PK), user_id (FK), name, created_at, updated_at
  - Indexed on user_id

- **Stats** (database table: stats)

  - Columns: id (PK), user_id (FK), manual_flashcards_count, ai_flashcards_count, edited_ai_flashcards_count, created_at, updated_at
  - Indexed on user_id

- **FlashcardCollections** (join table for many-to-many relationship between flashcards and collections)
  - Columns: flashcard_id, collection_id
  - Indexed on both keys

## 2. Endpoints

### Flashcards

- **POST /flashcards**

  - **Description:** Create new flashcards manually.
  - **Request JSON Structure:**
    ```json
    [
      {
        "front_content": "Question text",
        "back_content": "Answer text",
        "flashcard_type": "any flashcard type (manual, ai, edited_ai)",
        "collection_id": 1
      }
    ]
    ```
  - **Response JSON Structure:**
    ```json
    [
      {
        "id": 1,
        "front_content": "Question text",
        "back_content": "Answer text",
        "flashcard_type": "manual",
        "collection_id": 1,
        "created_at": "...",
        "updated_at": "..."
      }
    ]
    ```
  - **Success Codes:** 201 Created
  - **Error Codes:** 400 Bad Request, 422 Unprocessable Entity

- **POST /flashcards/generate**

  - **Description:** Generate flashcard proposals using AI based on input text (max 1000 characters).
  - **Request JSON Structure:**
    ```json
    {
      "input_text": "Your text input here (max 1000 characters)"
    }
    ```
  - **Response JSON Structure:**
    ```json
    {
      "proposals": [
        {
          "front_content": "Generated question",
          "back_content": "Generated answer"
        }
      ]
    }
    ```
  - **Success Codes:** 200 OK
  - **Error Codes:** 400 Bad Request (if text exceeds limit)

- **GET /flashcards/:id**

  - **Description:** Retrieve a specific flashcard by its ID.
  - **Response JSON Structure:**
    ```json
    {
      "id": 1,
      "front_content": "...",
      "back_content": "...",
      "flashcard_type": "manual",
      "created_at": "...",
      "updated_at": "..."
    }
    ```
  - **Success Codes:** 200 OK
  - **Error Codes:** 401 Unauthorized, 403 Forbidden, 404 Not Found

- **PUT /flashcards/:id**

  - **Description:** Update an existing flashcard.
  - **Request JSON Structure:**
    ```json
    {
      "front_content": "Updated question",
      "back_content": "Updated answer",
      "flashcard_type": "a valid flashcard type: manual, ai, edited_ai",
      "collection_id": 1
    }
    ```
  - **Response JSON Structure:**
    ```json
    {
      "id": 1,
      "front_content": "Updated question",
      "back_content": "Updated answer",
      "flashcard_type": "edited_ai",
      "created_at": "...",
      "updated_at": "..."
    }
    ```
  - **Success Codes:** 200 OK
  - **Error Codes:** 400 Bad Request, 422 Unprocessable Entity

- **DELETE /flashcards/:id**
  - **Description:** Delete a specific flashcard.
  - **Response:** No content
  - **Success Codes:** 204 No Content
  - **Error Codes:** 401 Unauthorized, 403 Forbidden, 404 Not Found

### Collections

- **GET /collections**

  - **Description:** List all collections for the authenticated user.
  - **Query Parameters:**
    - `page` (optional)
    - `per_page` (optional)
  - **Response JSON Structure:**
    ```json
    [
      {
        "id": 1,
        "name": "Collection Name",
        "created_at": "...",
        "updated_at": "..."
      }
    ]
    ```
  - **Success Codes:** 200 OK
  - **Error Codes:** 401 Unauthorized

- **POST /collections**

  - **Description:** Create a new collection.
  - **Request JSON Structure:**
    ```json
    {
      "name": "My Collection"
    }
    ```
  - **Response JSON Structure:**
    ```json
    {
      "id": 1,
      "name": "My Collection",
      "created_at": "...",
      "updated_at": "..."
    }
    ```
  - **Success Codes:** 201 Created
  - **Error Codes:** 400 Bad Request, 422 Unprocessable Entity

- **GET /collections/:id**

  - **Description:** Retrieve details of a specific collection, optionally including its associated flashcards.
  - **Response JSON Structure:**
    ```json
    {
      "id": 1,
      "name": "My Collection",
      "flashcards": [
        { "id": 1, "front_content": "...", "back_content": "..." }
      ],
      "created_at": "...",
      "updated_at": "..."
    }
    ```
  - **Success Codes:** 200 OK
  - **Error Codes:** 401 Unauthorized, 403 Forbidden, 404 Not Found

- **PUT /collections/:id**

  - **Description:** Update an existing collection.
  - **Request JSON Structure:**
    ```json
    {
      "name": "Updated Collection Name"
    }
    ```
  - **Response JSON Structure:**
    ```json
    {
      "id": 1,
      "name": "Updated Collection Name",
      "created_at": "...",
      "updated_at": "..."
    }
    ```
  - **Success Codes:** 200 OK
  - **Error Codes:** 400 Bad Request, 422 Unprocessable Entity

- **DELETE /collections/:id**

  - **Description:** Delete a specific collection. (Note: Deleting a collection does not delete the associated flashcards.)
  - **Success Codes:** 204 No Content
  - **Error Codes:** 401 Unauthorized, 403 Forbidden, 404 Not Found

- **POST /collections/:collection_id/flashcards**

  - **Description:** Add a flashcard to a collection.
  - **Request JSON Structure:**
    ```json
    {
      "flashcard_id": 1
    }
    ```
  - **Response:** Confirmation message with updated association.
  - **Success Codes:** 200 OK
  - **Error Codes:** 400 Bad Request, 404 Not Found

- **DELETE /collections/:collection_id/flashcards/:flashcard_id**
  - **Description:** Remove a flashcard from a collection.
  - **Success Codes:** 204 No Content
  - **Error Codes:** 401 Unauthorized, 403 Forbidden, 404 Not Found

## 3. Authentication and Authorization

- **Authentication Mechanism:**

  - Based on session cookies. Users authenticate via standard login endpoints (handled separately), and the session cookie is sent with each request.
  - Unauthenticated requests will result in a 401 Unauthorized error.

- **Authorization:**
  - Each endpoint scopes data to the authenticated user. Requests for resources not owned by the user return 403 Forbidden.

## 4. Validation and Business Logic

- **Input Validation:**

  - All endpoints validate required fields and proper data types.
  - For flashcards, the `flashcard_type` must be one of "manual", "ai", or "edited_ai" (enforced by database check constraint).
  - The `/flashcards/generate` endpoint validates that `input_text` does not exceed 1000 characters.

- **Business Logic:**

  - **AI Generation:** Integration with an AI service to generate flashcard proposals. Users review proposals and decide to save, edit, or discard them.
  - **Manual Creation, Update, and Deletion:** Standard CRUD operations with cascade deletion enforced by the database for associated records (e.g., deleting a user cascades deletes on flashcards, collections, and stats).
  - **Association Management:** Endpoints for assigning and removing flashcards from collections ensure many-to-many relationships are maintained properly.
  - **SRS Review:** The review endpoints update flashcards' review schedules based on user input, leveraging an existing SRS algorithm library.

- **Error Handling and Security:**
  - Endpoints return appropriate HTTP status codes:
    - 400 Bad Request for malformed input
    - 401 Unauthorized for unauthenticated access
    - 403 Forbidden for unauthorized access
    - 404 Not Found for missing resources
    - 422 Unprocessable Entity for validation failures
  - Rate limiting may be applied to sensitive endpoints (e.g., `/flashcards/generate`) to mitigate abuse.
  - Database indexes (e.g., on `user_id` and `flashcard_type`) and query parameters ensure efficient performance.
