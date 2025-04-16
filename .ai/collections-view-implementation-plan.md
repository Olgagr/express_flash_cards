# Plan implementacji widoku Kolekcji (`/collections`)

## 1. Przegląd

Widok `/collections` służy do zarządzania kolekcjami fiszek przez zalogowanego użytkownika. Umożliwia wyświetlanie listy istniejących kolekcji, tworzenie nowych, edytowanie ich nazw oraz usuwanie. Interakcje odbywają się dynamicznie, wykorzystując Hotwire (Turbo Frames, Turbo Streams) do aktualizacji interfejsu bez przeładowywania całej strony, a stylizacja oparta jest na TailwindCSS.

## 2. Routing widoku

Widok powinien być dostępny pod standardową ścieżką RESTful dla zasobu `collections`:

- **Ścieżka:** `/collections`
- **Metoda HTTP:** `GET`
- **Akcja kontrolera:** `CollectionsController#index`

## 3. Struktura komponentów (widoków częściowych ERB)

```
app/views/
└── collections/
    ├── index.html.erb            # Główny plik widoku listy
    │   ├── (Opcjonalnie: _header.html.erb) # Nagłówek i przycisk "Nowa kolekcja"
    │   └── <turbo-frame id="collections_list">
    │       └── (Zawartość listy - może być w index.html.erb lub _collections_list.html.erb)
    │           └── _collection.html.erb  # Pojedynczy element listy kolekcji
    │
    ├── new.html.erb              # Widok dla akcji 'new' - renderuje zawartość modala
    │   └── <turbo-frame id="modal">
    │       └── _form_modal.html.erb
    │
    ├── edit.html.erb             # Widok dla akcji 'edit' - renderuje zawartość modala
    │   └── <turbo-frame id="modal">
    │       └── _form_modal.html.erb
    │
    ├── _form_modal.html.erb      # Formularz tworzenia/edycji kolekcji (wewnątrz modala)
    │
    ├── create.turbo_stream.erb   # Odpowiedź Turbo Stream dla akcji 'create'
    ├── update.turbo_stream.erb   # Odpowiedź Turbo Stream dla akcji 'update'
    └── destroy.turbo_stream.erb  # (Opcjonalnie) Odpowiedź Turbo Stream dla akcji 'destroy'

app/views/layouts/application.html.erb # Powinien zawierać kontener na modal i powiadomienia
    <turbo-frame id="modal"></turbo-frame>
    <div id="notifications"></div>
```

## 4. Szczegóły komponentów

### `CollectionsListView` (`index.html.erb`)

- **Opis:** Główny kontener widoku listy kolekcji. Zawiera nagłówek, przycisk do inicjowania tworzenia nowej kolekcji oraz obszar (Turbo Frame) do dynamicznego wyświetlania listy.
- **Główne elementy:** `<h1>`, przycisk `link_to "Nowa kolekcja", new_collection_path, data: { turbo_frame: "modal" }`, `<turbo-frame id="collections_list">` ładujący początkową listę.
- **Obsługiwane interakcje:** Kliknięcie przycisku "Nowa kolekcja".
- **Obsługiwana walidacja:** Brak.
- **Propsy:** Przyjmuje `@collections` z kontrolera do początkowego renderowania listy wewnątrz ramki.

### `CollectionListComponent` (wewnątrz `<turbo-frame id="collections_list">`)

- **Opis:** Wyświetla listę kolekcji. Jest opakowany w Turbo Frame, aby umożliwić dynamiczne aktualizacje (dodawanie, usuwanie, odświeżanie elementów).
- **Główne elementy:** Kontener listy (np. `<ul>`, `<div>`), iteruje po `@collections` renderując partial `_collection.html.erb` dla każdego elementu.
- **Obsługiwane interakcje:** Brak bezpośrednich (delegacja do elementów listy).
- **Obsługiwana walidacja:** Brak.
- **Propsy:** `@collections`.

### `CollectionListItemComponent` (`_collection.html.erb`)

- **Opis:** Reprezentuje pojedynczy wiersz/element na liście kolekcji. Wyświetla nazwę kolekcji oraz przyciski akcji (Edytuj, Usuń). Musi mieć unikalne ID DOM (`dom_id(collection)`) dla targetowania przez Turbo Streams.
- **Główne elementy:** Kontener elementu (np. `<li>`, `<div>`) z `id: dom_id(collection)`, nazwa kolekcji (`collection.name`), przycisk/link "Edytuj" (`link_to "Edytuj", edit_collection_path(collection), data: { turbo_frame: "modal" }`), przycisk/link "Usuń" (`link_to "Usuń", collection_path(collection), data: { turbo_method: :delete, turbo_confirm: "Czy na pewno chcesz usunąć tę kolekcję?" }`).
- **Obsługiwane interakcje:** Kliknięcie "Edytuj", kliknięcie "Usuń".
- **Obsługiwana walidacja:** Potwierdzenie usunięcia (`turbo_confirm`).
- **Propsy:** `collection` (pojedynczy obiekt kolekcji).

### `CollectionFormModalComponent` (`_form_modal.html.erb`)

- **Opis:** Formularz używany do tworzenia i edycji kolekcji, renderowany wewnątrz modala (okna dialogowego) zarządzanego przez Turbo Frame (`id="modal"`).
- **Główne elementy:** `<%= form_with(model: collection, ...) %>`, pole tekstowe dla nazwy (`form.text_field :name`), przycisk "Zapisz" (`form.submit`), przycisk/link "Anuluj" (może zamykać modal za pomocą JS/Stimulusa lub linkować do tej samej strony czyszcząc ramkę). Wyświetlanie błędów walidacji (`collection.errors`).
- **Obsługiwane interakcje:** Wprowadzanie tekstu, Submisja formularza, Kliknięcie "Anuluj".
- **Obsługiwana walidacja:**
  - **Frontend:** Atrybut HTML5 `required` na polu nazwy.
  - **Backend:** Walidacja modelu `Collection` (np. `validates :name, presence: true`). Błędy zwrócone przez kontroler (w `@collection.errors`) są wyświetlane w formularzu po nieudanej próbie zapisu (przez Turbo Stream aktualizujący modal).
- **Propsy:** `collection` (nowy lub istniejący obiekt kolekcji).

## 6. Zarządzanie stanem

Zarządzanie stanem odbywa się głównie po stronie serwera (Rails).

- Lista kolekcji (`@collections`) jest ładowana przez kontroler.
- Stan formularza (wprowadzone dane, błędy walidacji) jest zarządzany przez Rails (`form_with`, `@collection.errors`) i aktualizowany przez Turbo Streams.
- Widoczność modala jest kontrolowana przez zawartość ramki `<turbo-frame id="modal">`. Pusta ramka oznacza ukryty modal, wypełniona oznacza widoczny.
- Ewentualne bardziej złożone stany UI (np. animacje modala, obsługa zamykania przez ESC/kliknięcie tła) mogą wymagać prostego kontrolera Stimulus.

## 7. Integracja API (Kontroler)

Integracja odbywa się poprzez standardowe akcje RESTful kontrolera `CollectionsController`:

- **`index`:** Pobiera `@collections = current_user.collections` (wymaga dodania logiki `current_user` i zakreskowania) i renderuje `index.html.erb`.
- **`new`:** Inicjalizuje `@collection = Collection.new` i renderuje `new.html.erb` (który renderuje `_form_modal.erb` w ramce `modal`).
- **`create`:** Tworzy nową kolekcję `current_user.collections.build(collection_params)`.
  - **Sukces:** Odpowiada `create.turbo_stream.erb` (dodaje element do listy, czyści modal, pokazuje powiadomienie).
  - **Błąd:** Renderuje `create.turbo_stream.erb` (aktualizuje modal z formularzem i błędami).
- **`edit`:** Znajduje `@collection = current_user.collections.find(params[:id])` i renderuje `edit.html.erb` (który renderuje `_form_modal.erb` w ramce `modal`).
- **`update`:** Aktualizuje kolekcję `@collection = current_user.collections.find(params[:id])`.
  - **Sukces:** Odpowiada `update.turbo_stream.erb` (zamienia element na liście, czyści modal, pokazuje powiadomienie).
  - **Błąd:** Renderuje `update.turbo_stream.erb` (aktualizuje modal z formularzem i błędami).
- **`destroy`:** Usuwa kolekcję `@collection = current_user.collections.find(params[:id])`.
  - **Sukces:** Odpowiada `destroy.turbo_stream.erb` (usuwa element z listy, pokazuje powiadomienie) LUB przekierowuje do `collections_path` z powiadomieniem (Turbo Drive obsłuży odświeżenie).

## 8. Interakcje użytkownika

- **Wyświetlenie listy:** Użytkownik wchodzi na `/collections`. Widzi listę swoich kolekcji.
- **Rozpoczęcie tworzenia:** Użytkownik klika "Nowa kolekcja". Modal pojawia się z pustym formularzem.
- **Anulowanie tworzenia/edycji:** Użytkownik klika "Anuluj" w modalu. Modal znika.
- **Zapisanie nowej kolekcji (poprawnie):** Użytkownik wypełnia nazwę, klika "Zapisz". Modal znika, nowa kolekcja pojawia się na liście, pojawia się komunikat o sukcesie.
- **Zapisanie nowej kolekcji (błąd walidacji):** Użytkownik nie wypełnia nazwy, klika "Zapisz". Modal pozostaje, formularz wyświetla błąd przy polu nazwy.
- **Rozpoczęcie edycji:** Użytkownik klika "Edytuj" przy kolekcji. Modal pojawia się z formularzem wypełnionym nazwą tej kolekcji.
- **Zapisanie edycji (poprawnie):** Użytkownik zmienia nazwę, klika "Zapisz". Modal znika, nazwa kolekcji na liście zostaje zaktualizowana, pojawia się komunikat o sukcesie.
- **Zapisanie edycji (błąd walidacji):** Użytkownik usuwa nazwę, klika "Zapisz". Modal pozostaje, formularz wyświetla błąd przy polu nazwy.
- **Usunięcie kolekcji:** Użytkownik klika "Usuń" przy kolekcji. Pojawia się natywne okno dialogowe przeglądarki z pytaniem potwierdzającym.
- **Potwierdzenie usunięcia:** Użytkownik potwierdza. Kolekcja znika z listy, pojawia się komunikat o sukcesie.
- **Anulowanie usunięcia:** Użytkownik anuluje. Nic się nie dzieje.

## 9. Warunki i walidacja

- **Obecność nazwy kolekcji:** Wymagane przy tworzeniu i edycji.
  - **Komponent:** `CollectionFormModalComponent`.
  - **Weryfikacja:** Atrybut `required` w HTML (frontend), `validates :name, presence: true` w modelu `Collection` (backend).
  - **Wpływ na UI:** Niewypełnienie pola i próba zapisu skutkuje wyświetleniem komunikatu błędu przy polu w modalu (bez zamykania modala).
- **Uwierzytelnienie użytkownika:** Wymagane do dostępu do całego widoku i wszystkich akcji.
  - **Komponent:** Cały widok `/collections` i jego akcje.
  - **Weryfikacja:** `before_action :authenticate_user!` w kontrolerze.
  - **Wpływ na UI:** Niezalogowany użytkownik jest przekierowywany na stronę logowania.
- **Potwierdzenie usunięcia:** Wymagane przed wykonaniem akcji `destroy`.
  - **Komponent:** `CollectionListItemComponent` (przycisk Usuń).
  - **Weryfikacja:** Atrybut `data-turbo-confirm` na linku usuwania (frontend).
  - **Wpływ na UI:** Wyświetlenie okna dialogowego przeglądarki. Akcja jest kontynuowana tylko po potwierdzeniu.

## 10. Obsługa błędów

- **Błędy walidacji (422 Unprocessable Entity):** Kontroler (`create`, `update`) renderuje odpowiedź Turbo Stream (`create.turbo_stream.erb` lub `update.turbo_stream.erb`), która aktualizuje zawartość ramki `modal`, ponownie wyświetlając formularz (`_form_modal.html.erb`) wraz z błędami walidacji pobranymi z obiektu `@collection.errors`.
- **Brak autoryzacji (401 Unauthorized):** Obsługiwane przez mechanizm uwierzytelniania (np. Devise), zazwyczaj przekierowanie do strony logowania.
- **Zasób nie znaleziony (404 Not Found):** Jeśli użytkownik spróbuje edytować/usunąć nieistniejącą kolekcję, `find` w kontrolerze zgłosi `ActiveRecord::RecordNotFound`, co Rails domyślnie zamieni na odpowiedź 404.
- **Błędy serwera (5xx Internal Server Error):** Standardowe strony błędów Rails. W przypadku żądań Turbo, mogą wymagać dodatkowej obsługi dla lepszego UX (np. globalny event listener dla `turbo:fetch-request-error`).
- **Błędy sieciowe:** Turbo może wyświetlić domyślny komunikat. Rozważyć dedykowaną obsługę.
- **Komunikaty dla użytkownika:** Sukcesy (utworzono, zaktualizowano, usunięto) i potencjalne błędy (inne niż walidacja) powinny być komunikowane za pomocą powiadomień flash, renderowanych w dedykowanym kontenerze `#notifications` za pomocą Turbo Streams. Należy stworzyć partial `app/views/shared/_flash.html.erb`.

## 11. Kroki implementacji

1.  **Kontroler:**
    - Upewnij się, że `CollectionsController` ma `before_action :authenticate_user!`.
    - Zmodyfikuj akcje (`index`, `edit`, `update`, `destroy`), aby operowały na kolekcjach bieżącego użytkownika (`current_user.collections...`) zamiast `Collection.all` lub `Collection.find`.
    - Upewnij się, że akcje `create` i `update` poprawnie obsługują `respond_to` dla formatu `:turbo_stream` w przypadku błędów walidacji (renderowanie strumienia aktualizującego modal).
    - Zdecyduj o obsłudze `destroy`: przekierowanie (prostsze) czy odpowiedź `:turbo_stream` (bardziej dynamiczne). Zaimplementuj wybraną opcję.
    - Dodaj obsługę powiadomień flash (`flash[:notice]`, `flash[:alert]`) w akcjach.
2.  **Model:**
    - Dodaj walidację `validates :name, presence: true` do modelu `Collection`.
    - Upewnij się, że model `User` ma relację `has_many :collections`.
3.  **Routing:**
    - Sprawdź, czy `resources :collections` jest zdefiniowane w `config/routes.rb`.
4.  **Widoki:**
    - **Layout:** Dodaj `<turbo-frame id="modal"></turbo-frame>` i `<div id="notifications"></div>` w `app/views/layouts/application.html.erb`. Stwórz partial `app/views/shared/_flash.html.erb` do renderowania powiadomień.
    - **`index.html.erb`:** Stwórz strukturę widoku z nagłówkiem, przyciskiem "Nowa kolekcja" (linkującym do `new_collection_path` z `data: { turbo_frame: 'modal' }`) i ramką `<turbo-frame id="collections_list">`. Wewnątrz ramki wyrenderuj listę `@collections` używając partial `_collection.html.erb`.
    - **`_collection.html.erb`:** Stwórz partial dla pojedynczego elementu listy. Użyj `dom_id(collection)` jako ID kontenera. Wyświetl `collection.name`. Dodaj linki "Edytuj" (do `edit_collection_path(collection)` z `data: { turbo_frame: 'modal' }`) i "Usuń" (do `collection_path(collection)` z `data: { turbo_method: :delete, turbo_confirm: '...' }`).
    - **`_form_modal.html.erb`:** Stwórz partial z formularzem (`form_with model: collection`). Dodaj pole `:name` (z `required: true`), przycisk submit i link/przycisk "Anuluj". Dodaj logikę wyświetlania błędów walidacji (`collection.errors`).
    - **`new.html.erb` / `edit.html.erb`:** Stwórz te pliki tak, aby renderowały _tylko_ ramkę `<turbo-frame id="modal">` zawierającą partial `_form_modal.html.erb`.
    - **Turbo Streams (`create.turbo_stream.erb`, `update.turbo_stream.erb`, `destroy.turbo_stream.erb`):** Zaimplementuj logikę Turbo Stream zgodnie z opisem w sekcji 7 (Integracja API), używając `turbo_stream.append`, `turbo_stream.replace`, `turbo_stream.remove`, `turbo_stream.update` do manipulacji listą (`#collections_list`, `dom_id(...)`), modalem (`#modal`) i powiadomieniami (`#notifications`).
5.  **Styling:** Zastosuj klasy TailwindCSS do wszystkich elementów widoku, aby uzyskać pożądany wygląd, dbając o czytelność i responsywność. Ostyluj modal i powiadomienia.
6.  **Testowanie:** Przetestuj wszystkie ścieżki interakcji użytkownika, włączając przypadki sukcesu i błędów (walidacja, usuwanie). Sprawdź działanie Turbo Streams i aktualizację UI.
