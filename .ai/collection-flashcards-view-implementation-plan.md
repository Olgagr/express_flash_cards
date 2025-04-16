# Plan implementacji widoku: Lista fiszek w kolekcji

## 1. Przegląd

Widok ten ma na celu wyświetlenie listy fiszek należących do konkretnej kolekcji wybranej przez użytkownika. Umożliwi użytkownikowi przeglądanie zawartości (przód, tył) oraz typu każdej fiszki w danej kolekcji. Widok jest kluczowym elementem nawigacji i zarządzania treścią w aplikacji.

**Uwaga:** Podstawowa relacja między Kolekcjami a Fiszkami jest typu wiele-do-wielu (poprzez model `FlashcardsCollection`), co oznacza, że jedna fiszka może należeć do wielu kolekcji. Ten widok koncentruje się jednak na wyświetlaniu fiszek powiązanych z _jedną_, aktualnie przeglądaną kolekcją.

## 2. Routing widoku

Widok będzie dostępny pod następującą ścieżką:

- `GET /collections/:id`
- Helper ścieżki: `collection_path(collection)`
- Kontroler i akcja: `CollectionsController#show` (do utworzenia)

## 3. Struktura komponentów (widoków częściowych ERB)

```
app/views/collections/show.html.erb
├── Nagłówek (np. <h1><%= @collection.name %></h1>)
└── turbo_frame_tag :flashcards_list do
    └── render partial: "flashcards/flashcards_list", locals: { flashcards: @flashcards }
        └── render partial: "flashcards/_flashcard", collection: @flashcards, as: :flashcard
            ├── div#flashcard_<%= flashcard.id %> (kontener dla Turbo Streams)
            │   ├── div (Przód: flashcard.front_content)
            │   ├── div (Tył: flashcard.back_content)
            │   └── div (Typ: flashcard.flashcard_type)
            └── (Opcjonalnie: Linki/przyciski do edycji/usuwania w przyszłości)
    └── (Opcjonalnie: Komponent paginacji, jeśli zaimplementowana)
```

## 4. Szczegóły komponentów (widoków częściowych ERB)

### `collections/show.html.erb`

- **Opis komponentu:** Główny szablon widoku dla pojedynczej kolekcji. Wyświetla tytuł kolekcji i zawiera ramkę Turbo Frame dla listy fiszek.
- **Główne elementy:** `<h1>` dla tytułu kolekcji, `turbo_frame_tag` do osadzenia listy fiszek.
- **Obsługiwane interakcje:** Ładowanie strony.
- **Obsługiwana walidacja:** Pośrednio przez kontroler (autoryzacja, znalezienie kolekcji).
- **Propsy (Zmienne instancji):** `@collection` (obiekt `Collection`).

### `flashcards/_flashcards_list.html.erb`

- **Opis komponentu:** Renderuje listę fiszek przekazanych do widoku częściowego. Odpowiada za iterację po kolekcji fiszek i renderowanie każdej z nich za pomocą `flashcards/_flashcard.html.erb`. Może zawierać logikę wyświetlania komunikatu o braku fiszek lub kontrolki paginacji.
- **Główne elementy:** Kontener listy (np. `<div>`, `<ul>`), warunek sprawdzający obecność fiszek (`if flashcards.present?`), pętla (`each`) renderująca `_flashcard`, komunikat o braku fiszek, (opcjonalnie) kontrolki paginacji.
- **Obsługiwane interakcje:** Wyświetlanie listy, (opcjonalnie) nawigacja paginacyjna (przez Turbo Frame).
- **Obsługiwana walidacja:** Sprawdzenie, czy kolekcja `flashcards` jest pusta.
- **Propsy (Zmienne lokalne):** `flashcards` (kolekcja obiektów `Flashcard`).

### `flashcards/_flashcard.html.erb`

- **Opis komponentu:** Wyświetla szczegóły pojedynczej fiszki (przód, tył, typ). Jest renderowany dla każdego elementu w kolekcji `@flashcards`. Każda fiszka jest opakowana w element z unikalnym ID DOM (`dom_id(flashcard)`) dla potencjalnych przyszłych aktualizacji przez Turbo Streams.
- **Główne elementy:** Element kontenera (np. `<li>`, `<div>`) z `id="flashcard_<%= flashcard.id %>"`, elementy wyświetlające `flashcard.front_content`, `flashcard.back_content`, `flashcard.flashcard_type`.
- **Obsługiwane interakcje:** Wyświetlanie danych. (W przyszłości: kliknięcie przycisków edycji/usuwania).
- **Obsługiwana walidacja:** Brak. Zakłada, że obiekt `flashcard` zawiera wymagane atrybuty.
- **Propsy (Zmienna lokalna):** `flashcard` (obiekt `Flashcard`).

## 6. Zarządzanie stanem

Zarządzanie stanem odbywa się głównie po stronie serwera (Rails). Kontroler pobiera odpowiedni stan (`@collection`, `@flashcards`) i przekazuje go do widoku. Hotwire (Turbo) zarządza aktualizacjami DOM i nawigacją w ramach ramek (frames) bez potrzeby złożonego zarządzania stanem po stronie klienta dla podstawowego widoku listy.

## 7. Integracja API

Integracja odbywa się poprzez standardowy cykl żądanie-odpowiedź w Rails, a nie przez bezpośrednie wywołania API z frontendu (JavaScript fetch).

1. Użytkownik klika link do kolekcji (np. `/collections/1`).
2. Żądanie `GET /collections/1` trafia do `CollectionsController#show`.
3. Kontroler:
   - Pobiera kolekcję: `@collection = Current.user.collections.find(params[:id])`. Obsługuje błąd `RecordNotFound`.
   - Pobiera fiszki dla kolekcji: `@flashcards = @collection.flashcards` (wykorzystując relację `has_many :flashcards, through: :flashcards_collections` do pobrania fiszek powiązanych z `@collection` poprzez tabelę `flashcards_collections`). Opcjonalnie można dodać paginację.
4. Kontroler renderuje widok `app/views/collections/show.html.erb`, przekazując zmienne instancji `@collection` i `@flashcards`.
5. Widok ERB jest przetwarzany na HTML i wysyłany do przeglądarki.

**Endpoint Description (`GET /collections/{collection_id}/flashcards`) jest w tym kontekście opisem danych, które kontroler Rails powinien przygotować i udostępnić widokowi, a nie endpointem REST API wywoływanym przez JavaScript.**

## 8. Interakcje użytkownika

- **Kliknięcie linku do kolekcji:** Użytkownik jest przenoszony na stronę `/collections/:id`, gdzie widzi nazwę kolekcji i listę jej fiszek.
- **(Opcjonalnie) Kliknięcie linku paginacji:** Jeśli zaimplementowano paginację wewnątrz ramki Turbo Frame (`:flashcards_list`), kliknięcie linku "Następna strona" lub numeru strony spowoduje asynchroniczne załadowanie odpowiedniej strony fiszek i zaktualizowanie tylko obszaru listy, bez przeładowania całej strony.

## 9. Warunki i walidacja

- **Poziom kontrolera:**
  - **Uwierzytelnienie:** Użytkownik musi być zalogowany. Jeśli nie, następuje przekierowanie do strony logowania. To jest zaimplementowane przez wbudowane mechanizmy Rails (kontroller ApplicationController i moduł Authentication)
  - **Autoryzacja i istnienie zasobu:** Użytkownik musi być właścicielem kolekcji, a kolekcja o danym `id` musi istnieć. W kontrolerze `CollectionsController#show` należy użyć np. `Current.user.collections.find(params[:id])`. W przypadku braku uprawnień lub nieznalezienia rekordu, Rails domyślnie zwróci błąd 404 lub można zaimplementować przekierowanie z komunikatem błędu (`flash[:alert]`).
- **Poziom widoku (`_flashcards_list.html.erb`):**
  - **Pusta kolekcja:** Widok częściowy powinien sprawdzić, czy kolekcja `@flashcards` jest pusta (`flashcards.empty?` lub `flashcards.blank?`). Jeśli tak, zamiast pustej listy powinien wyświetlić stosowny komunikat, np. "Brak fiszek w tej kolekcji.".

## 10. Obsługa błędów

- **Brak dostępu / Nie znaleziono kolekcji:** Kontroler powinien obsłużyć wyjątek `ActiveRecord::RecordNotFound` (lub podobny mechanizm autoryzacji) i zwrócić stronę błędu 404 lub przekierować użytkownika z komunikatem `flash[:alert]`.
- **Niezalogowany użytkownik:** Mechanizm uwierzytelniania (np. Devise) automatycznie przekieruje na stronę logowania.
- **Błąd serwera (np. błąd bazy danych):** Standardowa obsługa błędów 500 przez Rails. Błąd powinien być logowany po stronie serwera.
- **Pusta kolekcja:** Widok (`_flashcards_list.html.erb`) wyświetla komunikat informacyjny zamiast pustej listy (patrz punkt 9).

## 11. Kroki implementacji

1.  **Utworzenie Kontrolera i Akcji:**
    - Wygeneruj `CollectionsController`, jeśli jeszcze nie istnieje (`rails g controller Collections`).
    - Dodaj akcję `show` do `CollectionsController`.
    - Zaimplementuj logikę pobierania `@collection` i `@flashcards` w akcji `show`, w tym uwierzytelnianie i autoryzację (`before_action :authenticate_user!`, `Current.user.collections.find(params[:id])`).
2.  **Definicja Routingu:**
    - W pliku `config/routes.rb` dodaj trasę dla widoku kolekcji: `resources :collections, only: [:show]` (lub dostosuj, jeśli `resources :collections` już istnieje).
3.  **Utworzenie Głównego Widoku (`show.html.erb`):**
    - Stwórz plik `app/views/collections/show.html.erb`.
    - Dodaj podstawową strukturę HTML (np. z użyciem layoutu aplikacji).
    - Wyświetl nazwę kolekcji (`@collection.name`).
    - Dodaj `turbo_frame_tag :flashcards_list`.
4.  **Utworzenie Widoku Częściowego Listy (`_flashcards_list.html.erb`):**
    - Stwórz plik `app/views/flashcards/_flashcards_list.html.erb`.
    - Wewnątrz `show.html.erb`, w ramce Turbo Frame, wywołaj `render partial: "flashcards/flashcards_list", locals: { flashcards: @flashcards }`.
    - W `_flashcards_list.html.erb` zaimplementuj logikę sprawdzania, czy `flashcards` są obecne. Jeśli tak, iteruj po nich; jeśli nie, wyświetl komunikat "Brak fiszek...".
5.  **Utworzenie Widoku Częściowego Fiszki (`_flashcard.html.erb`):**
    - Stwórz plik `app/views/flashcards/_flashcard.html.erb`.
    - W pętli w `_flashcards_list.html.erb` renderuj ten partial: `render partial: "flashcards/flashcard", collection: flashcards, as: :flashcard`.
    - W `_flashcard.html.erb` wyświetl `flashcard.front_content`, `flashcard.back_content` i `flashcard.flashcard_type`. Opakuj całość w element z `id: dom_id(flashcard)`.
6.  **Styling (TailwindCSS):**
    - Dodaj odpowiednie klasy Tailwind do elementów HTML we wszystkich utworzonych plikach ERB, aby uzyskać pożądany wygląd listy fiszek.
7.  **Implementacja Paginacji (Opcjonalnie):**
    - Dodaj gem `pagy` lub inny mechanizm paginacji.
    - Zaktualizuj kontroler (`CollectionsController#show`), aby pobierał spaginowane `@flashcards`.
    - Dodaj kontrolki paginacji w `_flashcards_list.html.erb`, upewniając się, że linki paginacji działają poprawnie w kontekście Turbo Frame (mogą wymagać `data-turbo-frame="_top"` lub odpowiedniego targetowania, jeśli paginacja ma odświeżać tylko ramkę).
8.  **Testowanie:**
    - Napisz testy systemowe (integration tests) sprawdzające, czy widok poprawnie wyświetla fiszki dla danej kolekcji, obsługuje puste kolekcje oraz czy działa autoryzacja i uwierzytelnienie.
    - Napisz testy jednostkowe/kontrolera dla `CollectionsController#show`.
