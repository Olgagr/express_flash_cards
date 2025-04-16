# Plan implementacji widoku Kolekcji

## 1. Przegląd

Widok Kolekcji (`/collections`) służy do wyświetlania, tworzenia, edycji i usuwania kolekcji fiszek użytkownika. Interakcje (tworzenie, edycja, usuwanie) odbywają się za pomocą modalnych okien dialogowych (komponenty Ruby UI) i są obsługiwane dynamicznie przez Hotwire (Turbo Streams) w celu aktualizacji listy bez przeładowywania strony.

## 2. Routing widoku

Widok powinien być dostępny pod ścieżką:
`/collections`

## 3. Struktura komponentów

Główna struktura widoku będzie oparta na komponentach Ruby UI i standardowych elementach Rails:

app/views/collections/index.html.erb
├── H1 "Kolekcje"
├── RubyUI::DialogTrigger (dla przycisku "Nowa kolekcja")
│ └── RubyUI::Dialog (kontener modala)
│ └── app/views/collections/form.html.erb (formularz dla nowej kolekcji)
├── turbo_frame_tag :collections_list (kontener listy kolekcji)
│ └── app/views/collections/collections.html.erb (renderuje listę)
│ └── (pętla po @collections)
│ └── app/views/collections/collection.html.erb (pojedynczy element listy, id: dom_id(collection))
│ ├── Nazwa kolekcji
│ ├── RubyUI::DialogTrigger (dla przycisku "Edytuj")
│ │ └── RubyUI::Dialog (kontener modala)
│ │ └── app/views/collections/form.html.erb (formularz edycji, z danymi kolekcji)
│ └── RubyUI::DialogTrigger (dla przycisku "Usuń")
│ └── RubyUI::Dialog (kontener modala potwierdzenia)
│ └── app/views/collections/delete_confirmation.html.erb (treść potwierdzenia)
└── DIV#notifications (kontener na powiadomienia flash)

## 4. Szczegóły komponentów

### `CollectionsIndexView` (`index.html.erb`)

- **Opis:** Główny szablon strony. Zawiera tytuł, przycisk do otwarcia modala tworzenia nowej kolekcji oraz ramkę Turbo (`turbo_frame_tag`) do dynamicznego ładowania i aktualizowania listy kolekcji.
- **Główne elementy:** `h1`, `RubyUI::Button` (opakowany w `RubyUI::DialogTrigger`), `turbo_frame_tag :collections_list`.
- **Obsługiwane interakcje:** Kliknięcie przycisku "Nowa kolekcja" otwiera modal z formularzem.
- **Obsługiwana walidacja:** Brak bezpośredniej walidacji; delegowana do formularza w modalu.
- **Propsy:** Brak.

### `CollectionsList` (`_collections.html.erb` wewnątrz `turbo_frame_tag :collections_list`)

- **Opis:** Partial renderujący listę kolekcji. Iteruje po zmiennej `@collections` i renderuje partial `_collection.html.erb` dla każdego elementu. Jest celem dla operacji Turbo Stream (`append`, `replace`, `remove`).
- **Główne elementy:** Pętla (`@collections.each`), `render partial: "collections/collection"`.
- **Obsługiwane interakcje:** Aktualizacje przez Turbo Streams.
- **Obsługiwana walidacja:** Brak.
- **Propsy:** Otrzymuje lokalną zmienną `collections` (wynik `@collections` z kontrolera).

### `CollectionItem` (`_collection.html.erb`)

- **Opis:** Partial reprezentujący pojedynczy wiersz lub kartę kolekcji na liście. Wyświetla nazwę kolekcji oraz przyciski "Edytuj" i "Usuń". Musi mieć unikalne ID (`dom_id(collection)`).
- **Główne elementy:** Element HTML do wyświetlania `collection.name`, `RubyUI::Button` (jako `RubyUI::DialogTrigger` do edycji), `RubyUI::Button` (jako `RubyUI::DialogTrigger` do usunięcia).
- **Obsługiwane interakcje:** Kliknięcie "Edytuj" otwiera modal edycji. Kliknięcie "Usuń" otwiera modal potwierdzenia usunięcia.
- **Obsługiwana walidacja:** Brak.
- **Propsy:** Otrzymuje lokalną zmienną `collection`.

### `CollectionFormModal` (treść dla `RubyUI::Dialog`, np. w `_form.html.erb`)

- **Opis:** Formularz Rails (`form_with`) do tworzenia lub edycji kolekcji, opakowany w komponenty modalne Ruby UI.
- **Główne elementy:** `RubyUI::DialogHeader`, `RubyUI::DialogTitle`, `form_with(model: collection, ...)` zawierający `RubyUI::FormField`, `RubyUI::Label`, `RubyUI::Input` (dla `:name`), `RubyUI::FormFieldError` (miejsce na błędy walidacji), `RubyUI::DialogFooter`, `RubyUI::Button` (Submit), `RubyUI::Button` (Anuluj - do zamknięcia modala, może wymagać Stimulusa lub specyficznej obsługi Ruby UI).
- **Obsługiwane interakcje:** Wysłanie formularza (metody `POST` dla nowej, `PUT`/`PATCH` dla edycji). Kliknięcie "Anuluj" zamyka modal.
- **Obsługiwana walidacja:**
  - Pole `name`: Wymagane (`presence: true` w modelu `Collection`).
  - Wyświetlanie błędów: Błędy walidacji zwrócone przez serwer (`collection.errors`) są renderowane w obszarze `RubyUI::FormFieldError` za pomocą aktualizacji Turbo Stream. Atrybut `required` w HTML dla podstawowej walidacji przeglądarki.
- **Propsy:** Otrzymuje lokalną zmienną `collection` (nowy obiekt dla tworzenia, istniejący dla edycji).

### `DeleteConfirmationModal` (treść dla `RubyUI::Dialog`, np. w `_delete_confirmation.html.erb`)

- **Opis:** Modal z pytaniem o potwierdzenie przed usunięciem kolekcji.
- **Główne elementy:** `RubyUI::DialogHeader`, `RubyUI::DialogTitle`, `RubyUI::DialogDescription` (tekst potwierdzenia), `RubyUI::DialogFooter`, `RubyUI::Button` (Potwierdź - jako `link_to` z `data: { turbo_method: :delete }`), `RubyUI::Button` (Anuluj).
- **Obsługiwane interakcje:** Kliknięcie "Potwierdź" wysyła żądanie `DELETE`. Kliknięcie "Anuluj" zamyka modal.
- **Obsługiwana walidacja:** Brak.
- **Propsy:** Otrzymuje lokalną zmienną `collection` (do zbudowania URL i `dom_id`).

## 6. Zarządzanie stanem

Zarządzanie stanem jest minimalne po stronie klienta. Główny stan (lista kolekcji) jest zarządzany po stronie serwera (`@collections`). Komponenty Ruby UI (np. `Dialog`) zarządzają swoim wewnętrznym stanem (np. otwarcie/zamknięcie). Hotwire (Turbo Streams) aktualizuje DOM, aby odzwierciedlić zmiany stanu na serwerze.

## 7. Integracja API

Integracja odbywa się poprzez standardowe mechanizmy Rails i Hotwire:

- **`GET /collections`:** Ładowanie widoku `index.html.erb` (Turbo Drive).
- **`POST /collections`:** Wysłanie formularza tworzenia (`form_with`). Obsługiwane przez `CollectionsController#create`. Odpowiedź Turbo Stream (`create.turbo_stream.erb`) aktualizuje listę i ewentualnie zamyka modal oraz pokazuje powiadomienie. W przypadku błędu (422), odpowiedź Turbo Stream aktualizuje formularz w modalu, pokazując błędy.
- **`PUT /collections/:id`:** Wysłanie formularza edycji (`form_with`). Obsługiwane przez `CollectionsController#update`. Odpowiedź Turbo Stream (`update.turbo_stream.erb`) aktualizuje element listy, zamyka modal i pokazuje powiadomienie. W przypadku błędu (422), odpowiedź Turbo Stream aktualizuje formularz w modalu.
- **`DELETE /collections/:id`:** Kliknięcie linku potwierdzającego usunięcie (`link_to` z `data-turbo-method: :delete`). Obsługiwane przez `CollectionsController#destroy`. Odpowiedź Turbo Stream (`destroy.turbo_stream.erb`) usuwa element z listy i pokazuje powiadomienie.

## 8. Interakcje użytkownika

- **Załadowanie strony:** Użytkownik widzi listę swoich kolekcji.
- **Kliknięcie "Nowa kolekcja":** Otwiera się modal z pustym formularzem.
- **Wysłanie formularza "Nowa kolekcja" (poprawne dane):** Modal zamyka się, nowa kolekcja pojawia się na liście (animacja opcjonalna), wyświetla się powiadomienie o sukcesie.
- **Wysłanie formularza "Nowa kolekcja" (niepoprawne dane):** Modal pozostaje otwarty, pod polem `name` pojawia się komunikat o błędzie.
- **Kliknięcie "Edytuj" przy kolekcji:** Otwiera się modal z formularzem wypełnionym nazwą danej kolekcji.
- **Wysłanie formularza "Edytuj" (poprawne dane):** Modal zamyka się, nazwa kolekcji na liście zostaje zaktualizowana, wyświetla się powiadomienie o sukcesie.
- **Wysłanie formularza "Edytuj" (niepoprawne dane):** Modal pozostaje otwarty, pod polem `name` pojawia się komunikat o błędzie.
- **Kliknięcie "Usuń" przy kolekcji:** Otwiera się modal z pytaniem o potwierdzenie.
- **Kliknięcie "Potwierdź usunięcie":** Modal zamyka się, kolekcja znika z listy, wyświetla się powiadomienie o sukcesie.
- **Kliknięcie "Anuluj" (w dowolnym modalu):** Modal zamyka się bez wprowadzania zmian.

## 9. Warunki i walidacja

- **Walidacja:** Główna walidacja odbywa się po stronie serwera w modelu `Collection`.
  - `name`: Musi być obecne (`presence: true`).
- **Prezentacja błędów:** Błędy są przekazywane z kontrolera do widoku (formularza w modalu) za pomocą odpowiedzi Turbo Stream, która aktualizuje kontener na błędy (`RubyUI::FormFieldError`) pod odpowiednim polem.
- **Wymagane pola (Frontend):** Pole `name` w formularzu powinno mieć atrybut `required`, aby zapewnić podstawową informację zwrotną w przeglądarce, ale nie zastępuje to walidacji serwerowej.

## 10. Obsługa błędów

- **Błędy walidacji (422 Unprocessable Entity):** Jak opisano powyżej, formularz w modalu jest ponownie renderowany przez Turbo Stream z widocznymi komunikatami błędów.
- **Rekord nie znaleziony (404 Not Found):** Kontroler powinien przechwycić `ActiveRecord::RecordNotFound` i odpowiedzieć odpowiednim komunikatem (np. przez flash i Turbo Stream lub przekierowanie).
- **Brak autoryzacji (401 Unauthorized / 403 Forbidden):** System uwierzytelniania (np. Devise) powinien obsłużyć przekierowania do strony logowania.
- **Błąd serwera (500 Internal Server Error):** Wyświetlana jest standardowa strona błędu 500 Rails.
- **Powiadomienia (Flash):** Sukcesy i ogólne błędy powinny być komunikowane za pomocą powiadomień flash renderowanych w dedykowanym kontenerze (`#notifications`) za pomocą Turbo Streams. Należy stworzyć partial `app/views/shared/_flash.html.erb`.

## 11. Kroki implementacji

1.  **Model:** Upewnij się, że model `Collection` ma walidację `validates :name, presence: true`.
2.  **Kontroler (`CollectionsController`):**
    - Sprawdź akcje `index`, `new`, `edit`.
    - Zmodyfikuj akcje `create` i `update`, aby w przypadku błędu walidacji (blok `else`) odpowiadały za pomocą Turbo Stream, renderując ponownie partial formularza (`_form.html.erb`) wewnątrz modala.
    - Zmodyfikuj akcję `destroy`, aby odpowiadała za pomocą Turbo Stream (`turbo_stream.remove(dom_id(@collection))`) zamiast `redirect_to`. Dodaj renderowanie powiadomienia flash przez Turbo Stream.
    - Upewnij się, że `collection_params` zezwala na `:name`.
3.  **Routing:** Sprawdź, czy `resources :collections` jest zdefiniowane w `config/routes.rb`.
4.  **Widoki:**
    - Stwórz `app/views/collections/index.html.erb` z tytułem, przyciskiem "Nowa kolekcja" (`RubyUI::DialogTrigger`) i `turbo_frame_tag :collections_list`.
    - Stwórz partial `app/views/collections/_collections.html.erb` renderujący listę kolekcji (iteracja i renderowanie `_collection.html.erb`).
    - Stwórz partial `app/views/collections/_collection.html.erb` z nazwą kolekcji, przyciskami "Edytuj" i "Usuń" (oba jako `RubyUI::DialogTrigger`), używając `dom_id(collection)`.
    - Stwórz partial `app/views/collections/_form.html.erb` z `form_with` i komponentami Ruby UI (`DialogHeader`, `Input`, `Button` itp.). Upewnij się, że formularz poprawnie obsługuje zarówno tworzenie (obiekt `@collection` jest nowy), jak i edycję (obiekt `@collection` istnieje). Dodaj miejsce na wyświetlanie błędów (`collection.errors`).
    - Stwórz partial `app/views/collections/_delete_confirmation.html.erb` z treścią potwierdzenia i przyciskami Potwierdź (`link_to` z `data-turbo-method: :delete`) i Anuluj.
    - Stwórz partial `app/views/shared/_flash.html.erb` do renderowania powiadomień. Dodaj kontener `<div id="notifications"></div>` w głównym layoucie aplikacji lub `index.html.erb`.
5.  **Turbo Streams:**
    - Stwórz `app/views/collections/create.turbo_stream.erb`: Powinien zawierać `turbo_stream.append` dla nowej kolekcji do `:collections_list`, `turbo_stream.prepend` dla powiadomienia flash oraz akcję zamykającą modal (może wymagać niestandardowego stream action lub Stimulusa). W przypadku błędu, powinien zawierać `turbo_stream.update` dla kontenera formularza w modalu.
    - Stwórz `app/views/collections/update.turbo_stream.erb`: Powinien zawierać `turbo_stream.replace` dla edytowanej kolekcji, `turbo_stream.prepend` dla powiadomienia flash oraz akcję zamykającą modal. W przypadku błędu, powinien zawierać `turbo_stream.update` dla kontenera formularza w modalu.
    - Stwórz `app/views/collections/destroy.turbo_stream.erb`: Powinien zawierać `turbo_stream.remove` dla usuwanej kolekcji oraz `turbo_stream.prepend` dla powiadomienia flash.
6.  **Styling (Opcjonalnie):** Dostosuj wygląd komponentów Ruby UI za pomocą klas Tailwind CSS, jeśli domyślny wygląd wymaga modyfikacji.
7.  **JavaScript (Minimalnie):** Jeśli zamknięcie modala Ruby UI po udanej operacji Turbo Stream nie działa automatycznie, może być potrzebny prosty kontroler Stimulus lub niestandardowa akcja Turbo Stream do obsługi tego. Sprawdź dokumentację Ruby UI Dialog.
8.  **Testy:** Napisz testy systemowe (np. używając Capybary), aby zweryfikować pełny przepływ CRUD dla kolekcji, w tym interakcje z modalem i aktualizacje listy przez Turbo Streams.
