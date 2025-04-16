# Plan implementacji widoku Generowania Fiszek przez AI

## 1. Przegląd

Widok ten umożliwia użytkownikom generowanie propozycji fiszek (przód i tył) za pomocą AI na podstawie wprowadzonego tekstu (do 1000 znaków). Użytkownik może następnie przejrzeć, zaakceptować lub odrzucić wygenerowane propozycje. Widok jest częścią procesu tworzenia fiszek w ramach konkretnej kolekcji.

## 2. Routing widoku

Widok powinien być dostępny pod ścieżką: `/collections/{collection_id}/flashcards/generate`

## 3. Struktura komponentów

Widok będzie składał się z następujących głównych komponentów zorganizowanych hierarchicznie:

```
GenerateFlashcardsView (app/views/flashcards/generate.html.erb)
│
├── FormularzWprowadzaniaTekstu (app/views/flashcards/_form.html.erb)
│   ├── PoleTekstowe (textarea)
│   ├── LicznikZnakow (span)
│   └── PrzyciskGeneruj (button)
│
└── ListaPropozycjiFiszek (app/views/flashcards/_proposals.html.erb - renderowane przez Turbo Stream)
    └── PropozycjaFiszki (app/views/flashcards/_proposal.html.erb)
        ├── PolePrzód (textarea)
        ├── PoleTył (textarea)
        ├── PrzyciskZapisz (button/link_to)
        └── PrzyciskAnuluj (button/link_to)
```

## 4. Szczegóły komponentów

### FormularzWprowadzaniaTekstu (`_form.html.erb`)

- **Opis komponentu:** Formularz umożliwiający użytkownikowi wprowadzenie tekstu i zainicjowanie procesu generowania fiszek przez AI. Znajduje się w głównym pliku widoku `generate.html.erb`.
- **Główne elementy:**
  - `form_with`: Główny element formularza Rails, skonfigurowany do wysyłania danych AJAX na endpoint `generate`.
  - `textarea`: Pole do wprowadzania tekstu przez użytkownika (`input_text`).
  - `span`: Wyświetla aktualną liczbę wprowadzonych znaków i limit (np. "150/1000").
  - `button`: Przycisk "Generuj" uruchamiający wysłanie formularza.
- **Obsługiwane interakcje:**
  - Wprowadzanie tekstu w polu `textarea`.
  - Kliknięcie przycisku "Generuj".
- **Obsługiwana walidacja:**
  - **Limit znaków:** Sprawdzanie po stronie klienta (JavaScript/Stimulus), czy liczba znaków w `textarea` nie przekracza 1000. Jeśli przekroczy, przycisk "Generuj" powinien być nieaktywny, a licznik znaków może zmienić kolor na czerwony. Walidacja serwerowa jest również obecna w kontrolerze.
  - **Obecność tekstu:** Przycisk "Generuj" powinien być nieaktywny, jeśli pole `textarea` jest puste.
- **Propsy:** `collection_id` (przekazywane do `form_with` w celu zbudowania poprawnego URL).

### ListaPropozycjiFiszek (`_proposals.html.erb` - Turbo Stream Target)

- **Opis komponentu:** Kontener wyświetlający listę propozycji fiszek wygenerowanych przez AI. Renderowany dynamicznie przez Turbo Stream w odpowiedzi na udane żądanie do endpointu `generate`. Będzie to `turbo_frame_tag` lub `div` z unikalnym ID, na który celuje Turbo Stream.
- **Główne elementy:**
  - Kontener `div` lub `turbo_frame_tag`.
  - Pętla iterująca po otrzymanych propozycjach i renderująca komponent `PropozycjaFiszki` dla każdej z nich.
- **Obsługiwane interakcje:** Brak bezpośrednich interakcji z tym komponentem; służy jako kontener.
- **Obsługiwana walidacja:** Brak.
- **Propsy:** `proposals` (tablica obiektów propozycji fiszek otrzymana z serwera).

### PropozycjaFiszki (`_proposal.html.erb`)

- **Opis komponentu:** Reprezentuje pojedynczą propozycję fiszki wygenerowaną przez AI, umożliwiając użytkownikowi jej zapisanie lub odrzucenie.
- **Główne elementy:**
  - Dwa pola `textarea` (lub `input type="text"`) wyświetlające proponowany `front_content` i `back_content`. Pola mogą być tylko do odczytu lub edytowalne w zależności od decyzji projektowej (PRD sugeruje możliwość edycji).
  - Przycisk/Link "Zapisz" (do zaimplementowania - prawdopodobnie wyśle żądanie do akcji `create` kontrolera `FlashcardsController`).
  - Przycisk/Link "Anuluj" (usuwa propozycję z widoku, bez zapisywania).
- **Obsługiwane interakcje:**
  - Edycja treści w polach `textarea` (jeśli zaimplementowane).
  - Kliknięcie "Zapisz".
  - Kliknięcie "Anuluj".
- **Obsługiwana walidacja:** Jeśli edycja jest możliwa, walidacja np. czy pola nie są puste przed zapisem.
- **Propsy:** `proposal` (obiekt z `front_content` i `back_content`).

## 6. Zarządzanie stanem

Zarządzanie stanem w tym widoku będzie minimalne po stronie klienta, głównie opierając się na standardowych mechanizmach Rails i Hotwire:

- **Licznik znaków:** Prosty kontroler Stimulus do aktualizacji licznika i zarządzania stanem przycisku "Generuj" na podstawie długości tekstu w `textarea`.
- **Lista propozycji:** Zarządzana przez Turbo Streams. Po udanym wywołaniu API, serwer odsyła Turbo Stream, który dodaje lub aktualizuje `ListaPropozycjiFiszek`.
- **Stan ładowania:** Można dodać wskaźnik ładowania (np. spinner) po kliknięciu "Generuj", ukrywając go po otrzymaniu odpowiedzi (sukces lub błąd) przez Turbo Stream lub odpowiedni callback Stimulus.

## 7. Integracja API

- Formularz `FormularzWprowadzaniaTekstu` wysyła żądanie **POST** na endpoint `/collections/{collection_id}/flashcards/generate`.
- Żądanie zawiera `input_text` w ciele JSON.
- W odpowiedzi na udane żądanie (status 200 OK), kontroler Rails (akcja `generate` w `FlashcardsController`) zwraca odpowiedź, która powinna zawierać Turbo Stream.
- Turbo Stream (`turbo_stream.replace` lub `turbo_stream.append`) zaktualizuje kontener `ListaPropozycjiFiszek`, renderując partial `_proposals.html.erb` z otrzymanymi propozycjami.
- W przypadku błędu (np. 400 Bad Request, 429 Too Many Requests, 500 Internal Server Error), serwer powinien zwrócić odpowiedni status HTTP. Można obsłużyć te błędy po stronie klienta (np. używając zdarzeń `turbo:submit-end` i sprawdzając status odpowiedzi) lub renderując Turbo Stream z komunikatem błędu.

## 8. Interakcje użytkownika

1.  **Wprowadzanie tekstu:** Użytkownik wpisuje lub wkleja tekst do `textarea`. Licznik znaków aktualizuje się na bieżąco. Jeśli limit 1000 znaków zostanie przekroczony, przycisk "Generuj" staje się nieaktywny, a licznik może wizualnie wskazywać błąd.
2.  **Generowanie propozycji:** Użytkownik klika przycisk "Generuj" (aktywny tylko gdy tekst jest obecny i nie przekracza limitu). Formularz jest wysyłany asynchronicznie. Może pojawić się wskaźnik ładowania.
3.  **Wyświetlanie propozycji:** Po pomyślnym przetworzeniu przez AI, serwer odsyła Turbo Stream, który renderuje `ListaPropozycjiFiszek` z wygenerowanymi propozycjami (`PropozycjaFiszki`). Wskaźnik ładowania znika.
4.  **Zapisywanie propozycji:** Użytkownik klika "Zapisz" przy danej propozycji. (Wymaga implementacji osobnej akcji, np. `FlashcardsController#create`). Propozycja może zniknąć z listy i/lub pojawić się komunikat o sukcesie.
5.  **Anulowanie propozycji:** Użytkownik klika "Anuluj". Propozycja znika z listy (można to obsłużyć przez Stimulus lub wysyłając żądanie do serwera, które zwróci Turbo Stream usuwający element).

## 9. Warunki i walidacja

- **Limit znaków (1000):**
  - **Komponent:** `FormularzWprowadzaniaTekstu`
  - **Weryfikacja:** Po stronie klienta (Stimulus) - blokuje przycisk "Generuj", wizualna informacja na liczniku. Po stronie serwera (`validate_input_text` w kontrolerze) - zwraca błąd 400.
  - **Wpływ na UI:** Dezaktywacja przycisku "Generuj", zmiana wyglądu licznika.
- **Obecność tekstu:**
  - **Komponent:** `FormularzWprowadzaniaTekstu`
  - **Weryfikacja:** Po stronie klienta (Stimulus) - blokuje przycisk "Generuj". Po stronie serwera (`validate_input_text` w kontrolerze) - zwraca błąd 400.
  - **Wpływ na UI:** Dezaktywacja przycisku "Generuj".
- **Rate Limiting:**
  - **Komponent:** Nie dotyczy bezpośrednio komponentu, obsługa na poziomie kontrolera.
  - **Weryfikacja:** Po stronie serwera (`rate_limit` w kontrolerze) - zwraca błąd 429.
  - **Wpływ na UI:** Wyświetlenie komunikatu o błędzie (np. przez Turbo Stream lub obsługę błędu w Stimulus).

## 10. Obsługa błędów

- **Przekroczenie limitu znaków (400 Bad Request):** Wyświetlić komunikat błędu zwrócony przez API w pobliżu formularza. Przycisk "Generuj" powinien pozostać/stać się nieaktywny.
- **Brak tekstu (400 Bad Request):** Podobnie jak wyżej, wyświetlić komunikat błędu.
- **Zbyt wiele żądań (429 Too Many Requests):** Wyświetlić komunikat błędu zwrócony przez API, informujący użytkownika o konieczności odczekania.
- **Błąd serwera (500 Internal Server Error):** Wyświetlić ogólny komunikat o błędzie, np. "Wystąpił nieoczekiwany błąd. Spróbuj ponownie później.".
- **Błąd generowania przez AI (w ramach serwisu):** Serwis `FlashcardGenerationService` powinien obsłużyć błędy komunikacji z AI. Jeśli generowanie się nie powiedzie, kontroler powinien zwrócić odpowiedni błąd (np. 500 lub specyficzny kod, jeśli rozróżniamy błędy AI) i wyświetlić stosowny komunikat użytkownikowi.
- **Sposób wyświetlania błędów:** Najlepiej użyć Turbo Streams do wstawienia komunikatu błędu w odpowiednie miejsce na stronie (np. nad formularzem lub w dedykowanym kontenerze na powiadomienia). Alternatywnie, obsłużyć zdarzenia `turbo:submit-end` w Stimulus i wyświetlić błąd na podstawie statusu odpowiedzi.

## 11. Kroki implementacji

1.  **Routing:** Zdefiniować trasę `get '/collections/:collection_id/flashcards/generate', to: 'flashcards#new_generate'` (lub podobną, jeśli `generate` ma być akcją GET wyświetlającą formularz) oraz upewnić się, że trasa POST `/collections/:collection_id/flashcards/generate` jest poprawnie skonfigurowana i wskazuje na `FlashcardsController#generate`.
2.  **Kontroler (Akcja GET):** Stworzyć akcję w `FlashcardsController` (np. `new_generate`), która będzie renderować widok `generate.html.erb`. Powinna ona pobrać `@collection` na podstawie `:collection_id`.
3.  **Widok (`generate.html.erb`):** Stworzyć główny plik widoku. Umieścić w nim `turbo_frame_tag` dla przyszłej listy propozycji (np. `<turbo_frame_tag "flashcard_proposals">`).
4.  **Partial formularza (`_form.html.erb`):** Stworzyć partial z formularzem (`form_with`), zawierający `textarea`, licznik znaków i przycisk "Generuj". Skonfigurować `form_with` do wysyłania na ścieżkę `generate` z odpowiednim `collection_id`.
5.  **Stimulus Controller (Licznik i Walidacja):** Stworzyć kontroler Stimulus do obsługi `textarea`:
    - Aktualizacja licznika znaków (`input` event).
    - Włączanie/wyłączanie przycisku "Generuj" na podstawie długości tekstu i obecności tekstu.
    - Opcjonalnie: wizualne wskazanie przekroczenia limitu.
6.  **Kontroler (Akcja POST - `generate`):** Upewnić się, że akcja `generate` w `FlashcardsController` zwraca Turbo Stream w odpowiedzi na udane żądanie. Przykład:
    ```ruby
    # flashcards_controller.rb
    def generate
      # ... (walidacja i wywołanie serwisu)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flashcard_proposals",
                                                  partial: "flashcards/proposals",
                                                  locals: { proposals: proposals, collection: @collection }) # Przekaż @collection
        end
        format.json { render json: { proposals: proposals } } # Zachowaj JSON dla API jeśli potrzebne
      end
    rescue StandardError => e
      # Obsługa błędów - np. renderowanie turbo_stream z błędem
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flashcard_proposals", html: "<div>Wystąpił błąd: #{e.message}</div>".html_safe) }
        format.json { render json: { error: "An unexpected error occurred" }, status: :internal_server_error }
      end
    end
    ```
7.  **Partial listy propozycji (`_proposals.html.erb`):** Stworzyć partial, który iteruje po `proposals` i renderuje partial `_proposal.html.erb` dla każdej propozycji. Ten partial będzie renderowany wewnątrz `turbo_frame_tag` "flashcard_proposals".
8.  **Partial propozycji (`_proposal.html.erb`):** Stworzyć partial wyświetlający pojedynczą propozycję z polami `front_content`, `back_content` oraz przyciskami "Zapisz" i "Anuluj". (Implementacja akcji dla tych przycisków wykracza poza zakres tego planu - wymaga `FlashcardsController#create` i potencjalnie innej akcji do anulowania).
9.  **Obsługa błędów (Turbo Streams):** Zmodyfikować obsługę błędów w akcji `generate`, aby renderowała Turbo Stream zastępujący np. ramkę propozycji komunikatem błędu.
10. **Styling (TailwindCSS):** Ostylować wszystkie elementy zgodnie z projektem UI, używając klas TailwindCSS.
11. **Testowanie:** Napisać testy integracyjne (np. Capybara) symulujące interakcje użytkownika: wprowadzanie tekstu, kliknięcie generuj, sprawdzanie pojawienia się propozycji, testowanie walidacji i obsługi błędów.
