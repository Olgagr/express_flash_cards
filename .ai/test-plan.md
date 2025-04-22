# Plan Testów dla Aplikacji Express Flash Cards

## 1. Wprowadzenie i cele testowania

### 1.1. Wprowadzenie

Niniejszy dokument przedstawia plan testów dla aplikacji webowej "Express Flash Cards". Aplikacja ma na celu ułatwienie nauki poprzez fiszki, oferując zarówno manualne tworzenie, jak i generowanie wspomagane przez AI, w ramach zarządzanych przez użytkownika kolekcji. Projekt wykorzystuje stos technologiczny oparty na Ruby on Rails 8, Hotwire (Turbo/Stimulus), TailwindCSS i SQLite3.

### 1.2. Cele testowania

Głównymi celami procesu testowania są:

- Weryfikacja zgodności zdefiniowanych wymagań funkcjonalnych (PRD) i niefunkcjonalnych.
- Zapewnienie wysokiej jakości i stabilności aplikacji, ze szczególnym uwzględnieniem kluczowych przepływów użytkownika.
- Wykrycie i zaraportowanie defektów przed wdrożeniem produkcyjnym.
- Ocena użyteczności i intuicyjności interfejsu użytkownika.
- Sprawdzenie poprawności integracji z komponentami Hotwire (Turbo, Stimulus) i zewnętrznym serwisem AI.
- Weryfikacja mechanizmów bezpieczeństwa (uwierzytelnianie, autoryzacja).
- Zapewnienie poprawnego działania aplikacji w docelowym środowisku.

## 2. Zakres testów

### 2.1. Funkcjonalności objęte testami

- **Uwierzytelnianie:**
  - Logowanie użytkownika.
- **Zarządzanie Kolekcjami:**
  - Wyświetlanie listy kolekcji.
  - Tworzenie nowej kolekcji (przez modal).
  - Edycja nazwy kolekcji (przez modal).
  - Usuwanie kolekcji (z potwierdzeniem).
  - Wyświetlanie komunikatu dla pustej listy kolekcji.
- **Zarządzanie Fiszkami:**
  - Wyświetlanie listy fiszek w ramach wybranej kolekcji.
  - Wyświetlanie zawartości (przód, tył).
  - Wyświetlanie komunikatu dla pustej listy fiszek.
  - Zarządzanie relacją M:N Fiszka-Kolekcja (przypisywanie/usuwanie z kolekcji).
- **Generowanie Fiszek AI:**
  - Wyświetlanie widoku generowania AI dla kolekcji.
  - Wprowadzanie tekstu źródłowego (z walidacją limitu 1000 znaków).
  - Wyświetlanie licznika znaków.
  - Inicjowanie procesu generowania.
  - Wyświetlanie spinnera/wskaźnika ładowania podczas generowania.
  - Wyświetlanie listy wygenerowanych propozycji fiszek (przód, tył).
  - Możliwość zapisu pojedynczej propozycji jako nowej fiszki w kolekcji.
  - Możliwość edycji propozycji przed zapisem (do weryfikacji implementacji).
  - Możliwość odrzucenia propozycji.
  - Obsługa błędów ze strony serwisu AI.
- **UI/UX:**
  - Poprawność działania dynamicznych elementów interfejsu (modale, Turbo Frames, Turbo Streams).
  - Responsywność podstawowych widoków na różnych rozmiarach ekranu (desktop, tablet, mobile).
  - Czytelność i spójność komunikatów systemowych (błędy walidacji, powiadomienia toast).
  - Podstawowa weryfikacja dostępności (WCAG AA).
- **Bezpieczeństwo:**
  - Autoryzacja – dostęp użytkownika wyłącznie do własnych kolekcji i fiszek.
  - Podstawowa weryfikacja ochrony przed CSRF (mechanizmy Rails).

### 2.2. Funkcjonalności wyłączone z testów (w ramach MVP)

- Zaawansowane testy wydajnościowe i obciążeniowe.
- Szczegółowe testy wizualne (visual regression testing dla TailwindCSS).
- Testy kompatybilności na szerokiej gamie przeglądarek i systemów operacyjnych (skupienie na najnowszych wersjach Chrome/Firefox).
- Zaawansowane scenariusze bezpieczeństwa (testy penetracyjne).
- Import/eksport danych.
- Funkcje współdzielenia.
- Obsługa treści innych niż tekstowe w fiszkach.
- Testy specyficzne dla konfiguracji Litestream (chyba że jest to docelowe środowisko produkcyjne).

## 3. Typy testów do przeprowadzenia

- **Testy jednostkowe (Unit Tests):**
  - Cel: Weryfikacja poprawności działania izolowanych komponentów (modele, helpery, logika serwisów/klas pomocniczych).
  - Narzędzia: Minitest oraz fixtures.
  - Zakres: Walidacje modeli, asocjacje, metody niestandardowe, logika biznesowa, generowanie HTML.
- **Testy integracyjne (Integration Tests):**
  - Cel: Weryfikacja interakcji pomiędzy różnymi komponentami systemu (kontrolery, routing, widoki częściowe, interakcja z bazą danych).
  - Narzędzia: Minitest (testy kontrolerów).
  - Zakres: Poprawność odpowiedzi kontrolerów (statusy HTTP, rendery szablonów, przypisania zmiennych), działanie routingu, podstawowe interakcje z bazą danych w kontekście żądania.
- **Testy systemowe / End-to-End (E2E Tests):**
  - Cel: Weryfikacja kompletnych przepływów użytkownika w środowisku zbliżonym do produkcyjnego, symulując interakcje w przeglądarce. Kluczowe dla testowania Hotwire.
  - Narzędzia: Rails System Tests (Capybara + sterownik przeglądarki np. Selenium/Cuprite).
  - Zakres: Logowanie, CRUD na kolekcjach i fiszkach (z użyciem modalów), przepływ generowania AI, działanie Turbo Frames/Streams, walidacja po stronie klienta (Stimulus), responsywność, podstawowa dostępność.
- **Testy eksploracyjne:**
  - Cel: Nieskryptowane testowanie aplikacji w celu odkrycia nieprzewidzianych błędów i problemów z użytecznością.
  - Technika: Testerzy "bawią się" aplikacją, próbując różnych scenariuszy i danych wejściowych.
- **Testy akceptacyjne użytkownika (UAT):**
  - Cel: Potwierdzenie przez interesariuszy (np. Product Ownera), że aplikacja spełnia wymagania biznesowe.
  - Technika: Przeprowadzenie predefiniowanych scenariuszy przez końcowych użytkowników lub ich reprezentantów.

## 4. Scenariusze testowe dla kluczowych funkcjonalności

_(Przykładowe scenariusze - pełna lista zostanie opracowana w dedykowanym dokumencie/narzędziu)_

**4.1. Logowanie:**

- **TC1:** Poprawne logowanie przy użyciu prawidłowych danych. Oczekiwany rezultat: Użytkownik przekierowany do widoku kolekcji (`/collections`).
- **TC2:** Nieudane logowanie przy użyciu nieprawidłowego hasła. Oczekiwany rezultat: Wyświetlenie komunikatu błędu na stronie logowania.
- **TC3:** Nieudane logowanie przy użyciu nieistniejącego adresu e-mail. Oczekiwany rezultat: Wyświetlenie komunikatu błędu.
- **TC4:** Próba dostępu do strony wymagającej logowania (np. `/collections`) bez bycia zalogowanym. Oczekiwany rezultat: Przekierowanie na stronę logowania.

**4.2. Zarządzanie Kolekcjami (CRUD przez modal):**

- **TC5:** Wyświetlenie pustej listy kolekcji. Oczekiwany rezultat: Widoczny komunikat "Brak kolekcji, dodaj pierwszą!".
- **TC6:** Otwarcie modala tworzenia nowej kolekcji. Oczekiwany rezultat: Modal jest widoczny i zawiera formularz z polem "Nazwa".
- **TC7:** Utworzenie nowej kolekcji z poprawną nazwą. Oczekiwany rezultat: Modal znika, nowa kolekcja pojawia się na liście (aktualizacja przez Turbo Stream), wyświetla się powiadomienie o sukcesie.
- **TC8:** Próba utworzenia kolekcji z pustą nazwą. Oczekiwany rezultat: Modal pozostaje otwarty, pod polem "Nazwa" pojawia się błąd walidacji.
- **TC9:** Otwarcie modala edycji istniejącej kolekcji. Oczekiwany rezultat: Modal jest widoczny, pole "Nazwa" zawiera aktualną nazwę kolekcji.
- **TC10:** Zmiana nazwy istniejącej kolekcji. Oczekiwany rezultat: Modal znika, nazwa kolekcji na liście zostaje zaktualizowana (Turbo Stream), pojawia się powiadomienie o sukcesie.
- **TC11:** Anulowanie tworzenia/edycji kolekcji. Oczekiwany rezultat: Modal znika, lista kolekcji pozostaje bez zmian.
- **TC12:** Usunięcie kolekcji (potwierdzenie w oknie dialogowym przeglądarki). Oczekiwany rezultat: Kolekcja znika z listy (Turbo Stream), pojawia się powiadomienie o sukcesie.
- **TC13:** Anulowanie usuwania kolekcji w oknie dialogowym. Oczekiwany rezultat: Kolekcja pozostaje na liście.

**4.3. Generowanie Fiszek AI:**

- **TC14:** Przejście do widoku generowania AI dla wybranej kolekcji. Oczekiwany rezultat: Widoczny formularz z polem tekstowym, licznikiem znaków (0/1000) i przyciskiem "Generuj" (nieaktywny).
- **TC15:** Wprowadzenie tekstu poniżej limitu znaków. Oczekiwany rezultat: Licznik znaków aktualizuje się, przycisk "Generuj" staje się aktywny.
- **TC16:** Wprowadzenie tekstu przekraczającego limit 1000 znaków. Oczekiwany rezultat: Licznik znaków wskazuje przekroczenie (np. 1050/1000, zmiana koloru), przycisk "Generuj" staje się nieaktywny.
- **TC17:** Pomyślne wygenerowanie propozycji fiszek. Oczekiwany rezultat: Wyświetla się wskaźnik ładowania, a następnie pod formularzem pojawia się lista propozycji (przód/tył) z przyciskami "Zapisz"/"Odrzuć" (lub podobnymi).
- **TC18:** Zapisanie wygenerowanej propozycji. Oczekiwany rezultat: Propozycja znika z listy, (opcjonalnie) pojawia się powiadomienie o sukcesie. Fiszka powinna być widoczna na liście fiszek danej kolekcji.
- **TC19:** Odrzucenie wygenerowanej propozycji. Oczekiwany rezultat: Propozycja znika z listy.
- **TC20:** Obsługa błędu podczas komunikacji z serwisem AI. Oczekiwany rezultat: Wyświetlenie stosownego komunikatu błędu dla użytkownika (np. "Nie udało się wygenerować fiszek, spróbuj ponownie później").

**4.4. Autoryzacja:**

- **TC21:** Użytkownik A próbuje uzyskać dostęp do kolekcji użytkownika B (np. przez bezpośrednie wpisanie URL `/collections/ID_kolekcji_B`). Oczekiwany rezultat: Błąd 403 Forbidden lub przekierowanie/informacja o braku dostępu.

## 5. Środowisko testowe

- **Środowisko developerskie:** Lokalne maszyny deweloperów (macOS, Linux, Windows z WSL2). Baza danych: SQLite3. Serwer: Puma.
- **Środowisko testowe (Staging):** Dedykowany serwer możliwie zbliżony do środowiska produkcyjnego. Baza danych: SQLite3 (lub docelowa baza produkcyjna, jeśli inna niż SQLite). Serwer: Puma. Ciągła integracja (CI) z GitHub Actions uruchamiająca testy automatyczne.
- **Środowisko produkcyjne:** Docelowa infrastruktura wdrożeniowa (np. Kamal, Docker). Baza danych: SQLite3 z Litestream (lub inna). Serwer: Puma. Monitoring.

## 6. Narzędzia do testowania

- **Automatyzacja testów:**
  - Rails Minitest
  - Rails System Tests (Capybara) ze sterownikiem Selenium/Cuprite (testy E2E)
- **Zarządzanie testami i raportowanie błędów:**
  - Narzędzie do zarządzania przypadkami testowymi (np. TestRail, Xray for Jira, arkusz kalkulacyjny - w zależności od skali projektu).
  - System śledzenia błędów (np. Jira, GitHub Issues).
- **Ciągła Integracja (CI):**
  - GitHub Actions (konfiguracja w `.github/workflows/ci.yml`).
- **Narzędzia deweloperskie przeglądarki:**
  - Inspektor elementów, konsola JavaScript, zakładka sieciowa (do debugowania testów E2E i analizy działania Hotwire).
- **(Opcjonalnie) Narzędzia do testów wizualnych:** Percy, Applitools.
- **(Opcjonalnie) Narzędzia do testów dostępności:** Axe, WAVE.

## 7. Harmonogram testów

_(Harmonogram jest przykładowy i powinien być dostosowany do realnego planu projektu)_

- **Faza 1: Rozwój i testy jednostkowe/integracyjne:** Równolegle z implementacją funkcjonalności przez deweloperów. Testy uruchamiane lokalnie i na CI przy każdym pushu/pull requeście.
- **Faza 2: Testy systemowe (E2E):** Po zintegrowaniu kluczowych funkcjonalności na środowisku Staging. Iteracyjne pisanie i uruchamianie testów E2E pokrywających główne przepływy. (np. Tydzień 1-2 cyklu testowego).
- **Faza 3: Testy eksploracyjne i regresyjne:** Po ustabilizowaniu głównych funkcjonalności. Skupienie na mniej oczywistych scenariuszach i weryfikacji, czy poprawki nie wprowadziły nowych błędów. (np. Tydzień 2-3 cyklu testowego).
- **Faza 4: Testy akceptacyjne użytkownika (UAT):** Przed planowanym wdrożeniem. Przeprowadzenie testów przez interesariuszy na środowisku Staging. (np. Tydzień 3 cyklu testowego).
- **Faza 5: Testy przedprodukcyjne:** Ostateczne sprawdzenie na środowisku produkcyjnym (jeśli możliwe) lub Staging tuż przed wdrożeniem. (np. Ostatni dzień przed wdrożeniem).

## 8. Kryteria akceptacji testów

### 8.1. Kryteria wejścia (rozpoczęcia fazy testów)

- Dostępna stabilna wersja aplikacji na środowisku testowym (Staging).
- Ukończone i zintegrowane kluczowe funkcjonalności przewidziane w danym etapie.
- Dostępna dokumentacja wymagań (PRD) i projektowa (np. plany UI/API).
- Przygotowane środowisko testowe i narzędzia.
- Zdefiniowane i dostępne (przynajmniej wstępnie) przypadki testowe.

### 8.2. Kryteria wyjścia (zakończenia testów / gotowości do wdrożenia)

- Wszystkie zaplanowane przypadki testowe dla krytycznych i wysokopriorytetowych funkcjonalności zostały wykonane.
- Procent zakończonych sukcesem przypadków testowych osiągnął ustalony próg (np. 95% dla krytycznych, 90% dla wysokich).
- Brak nierozwiązanych błędów krytycznych (blokujących) i wysokiego priorytetu.
- Liczba błędów średniego i niskiego priorytetu mieści się w akceptowalnych granicach, a ich wpływ jest znany i zaakceptowany przez interesariuszy.
- Przeprowadzone i zaakceptowane testy UAT (jeśli dotyczy).
- Dokumentacja testowa (raporty z testów, lista znanych błędów) jest aktualna.

## 9. Role i odpowiedzialności w procesie testowania

- **Deweloperzy:**
  - Pisanie i utrzymanie testów jednostkowych i integracyjnych.
  - Naprawa błędów zgłoszonych przez zespół QA i użytkowników.
  - Uczestnictwo w testach eksploracyjnych.
  - Wsparcie w konfiguracji środowisk testowych.
- **Inżynierowie QA / Testerzy:**
  - Projektowanie i tworzenie planu testów.
  - Projektowanie, implementacja i utrzymanie testów systemowych (E2E).
  - Wykonywanie testów manualnych (eksploracyjnych, UAT).
  - Raportowanie i śledzenie błędów.
  - Przygotowanie raportów z testów.
  - Weryfikacja poprawek błędów.
  - Zarządzanie środowiskiem testowym (we współpracy z DevOps/developerami).
- **Product Owner / Interesariusze:**
  - Dostarczenie wymagań i kryteriów akceptacji.
  - Uczestnictwo w testach UAT.
  - Podejmowanie decyzji dotyczących priorytetów błędów i gotowości do wdrożenia.
- **(Opcjonalnie) DevOps / Administratorzy:**
  - Konfiguracja i utrzymanie środowisk CI/CD oraz Staging/Produkcja.
  - Monitoring aplikacji.

## 10. Procedury raportowania błędów

1.  **Wykrycie błędu:** Błąd może zostać wykryty podczas testów automatycznych, manualnych, eksploracyjnych lub zgłoszony przez użytkownika.
2.  **Rejestracja błędu:** Każdy wykryty błąd jest rejestrowany w systemie śledzenia błędów (np. Jira, GitHub Issues). Zgłoszenie powinno zawierać:
    - **Tytuł:** Krótki, zwięzły opis problemu.
    - **Opis:** Szczegółowy opis błędu, w tym:
      - Kroki do reprodukcji (jasne i precyzyjne).
      - Obserwowany rezultat.
      - Oczekiwany rezultat.
    - **Środowisko:** Wersja aplikacji, przeglądarka, system operacyjny, środowisko (np. Staging, Produkcja).
    - **Priorytet:** Waga błędu z perspektywy biznesowej/użytkownika (np. Krytyczny, Wysoki, Średni, Niski).
    - **Dotkliwość (Severity):** Wpływ błędu na działanie systemu (np. Blokujący, Poważny, Drobny, Kosmetyczny).
    - **Załączniki:** Zrzuty ekranu, nagrania wideo, logi (jeśli relevantne).
    - **Przypisanie:** Początkowo do lidera zespołu QA lub deweloperskiego do triage'u.
3.  **Triage błędu:** Ocena zgłoszenia, potwierdzenie reprodukowalności, ustalenie ostatecznego priorytetu i przypisanie do odpowiedniego dewelopera.
4.  **Naprawa błędu:** Deweloper analizuje błąd, implementuje poprawkę i wdraża ją na środowisko testowe.
5.  **Weryfikacja poprawki:** Tester weryfikuje, czy błąd został poprawnie naprawiony na środowisku testowym. Przeprowadza również testy regresyjne w powiązanym obszarze funkcjonalnym.
6.  **Zamknięcie błędu:** Jeśli poprawka jest skuteczna, błąd zostaje zamknięty w systemie śledzenia. Jeśli nie, błąd jest ponownie otwierany i wraca do dewelopera z odpowiednim komentarzem.
