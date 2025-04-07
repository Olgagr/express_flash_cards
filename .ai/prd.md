# Dokument wymagań produktu (PRD) - Express flash cards

## 1. Przegląd produktu

Projekt Express flash cards ma na celu stworzenie webowej aplikacji wspierającej efektywną naukę opartą na metodzie powtórek (spaced repetition). Użytkownicy będą mogli tworzyć i zarządzać swoimi fiszkami w dwóch trybach: ręcznym i przy użyciu AI. Dodatkowo zaimplementowany będzie podstawowy system uwierzytelniania, aby umożliwić bezpieczne przechowywanie fiszek w ramach kont użytkowników.

## 2. Problem użytkownika

Obecnie tworzenie wysokiej jakości fiszek jest pracochłonne i może odstraszać potencjalnych użytkowników od korzystania z efektywnej metody nauki opartej na powtórkach. Brakuje narzędzia, które automatyzuje proces generowania fiszek na podstawie istniejącego materiału (np. wklejanego tekstu). Z tego powodu wiele osób nie wykorzystuje potencjału SRS (Spaced Repetition System), mimo że jest to skuteczna metoda zapamiętywania.

## 3. Wymagania funkcjonalne

1. Generowanie fiszek przy pomocy AI

   - Użytkownik wprowadza do 1000 znaków tekstu (kopiuj-wklej).
   - System AI generuje propozycje fiszek (przód/tył – pytanie/odpowiedź) w formie tekstowej.
   - Użytkownik może przeglądać propozycje, zatwierdzać je, edytować lub odrzucać.

2. Ręczne tworzenie fiszek

   - Użytkownik samodzielnie uzupełnia tekst: przód (pytanie/fraza) i tył (odpowiedź/definicja) w formie tekstowej.

3. Zarządzanie fiszkami

   - Przeglądanie listy własnych fiszek.
   - Edycja istniejących fiszek (zarówno utworzonych ręcznie, jak i przez AI).
   - Usuwanie niepotrzebnych fiszek.

4. Zarządzanie kolekcjami

   - Tworzenie, edycja i usuwanie kolekcji.
   - Możliwość przypisywania jednej fiszki do wielu kolekcji.

5. Integracja z gotowym algorytmem powtórek

   - Fiszki są prezentowane użytkownikowi przez już istniejący system SRS.
   - Użytkownik ocenia, na ile dobrze pamięta daną fiszkę (gotowy mechanizm algorytmu powtórek).
   - Brak zaawansowanej konfiguracji algorytmu w ramach MVP – korzystamy z gotowej biblioteki.

6. System kontroli dostępu i kont użytkowników

   - Rejestracja i logowanie dla użytkowników (podstawowe bezpieczeństwo).
   - Przechowywanie fiszek w obrębie kont (uwierzytelnianie i autoryzacja na poziomie wybranych mechanizmów i dobrych praktyk).
   - Zabezpieczenia na poziomie wystarczającym w MVP (bez rozszerzonych zabezpieczeń).

7. Zbieranie statystyk

   - Liczba fiszek generowanych przez AI vs. ręcznie utworzonych.
   - Liczba i procent zaakceptowanych lub odrzuconych fiszek AI.
   - Statystyki przechowywane po stronie serwera i dostępne w formie raportów.

8. Komunikaty systemowe
   - Informowanie użytkownika o powodzeniu operacji: zapisu, edycji, usuwania fiszek/kolekcji.
   - Powiadomienia o rozpoczęciu i ukończeniu tworzenia fiszek przez AI.

## 4. Granice produktu

- Zakres MVP nie obejmuje zaimplementowania własnego zaawansowanego algorytmu powtórek (zamiast tego używamy istniejącej biblioteki).
- Brak importu z wielu formatów (PDF, DOCX itp.).
- Brak możliwości współdzielenia zestawów między użytkownikami i integracji z innymi platformami edukacyjnymi.
- Ograniczamy się do wersji webowej aplikacji (bez wersji mobilnych).
- Przy tworzeniu i edytowaniu fiszek obsługujemy wyłącznie treści tekstowe (bez materiałów multimedialnych).
- Maksymalny limit 1000 znaków tekstu do generowania fiszek przez AI, co nie obejmuje obróbki dużych czy rozbudowanych materiałów.

## 5. Historyjki użytkowników

### 5.1 Tworzenie i zarządzanie fiszkami

- ID: US-001  
  Tytuł: Generowanie fiszek przez AI  
  Opis: Jako użytkownik chcę wkleić fragment tekstu do 1000 znaków i otrzymać propozycje fiszek w celu automatycznego tworzenia treści do nauki.  
  Kryteria akceptacji:

  - Użytkownik może wkleić tekst liczący do 1000 znaków.
  - System AI generuje jedną lub więcej propozycji fiszek (przód i tył w formie tekstu).
  - Użytkownik może każdą propozycję zapisać (zatwierdzić), edytować lub anulować.

- ID: US-002  
  Tytuł: Ręczne tworzenie fiszek  
  Opis: Jako użytkownik chcę móc utworzyć fiszkę wprowadzając tekst dla przodu (pytanie) i tyłu (odpowiedź), aby zdefiniować własną treść.  
  Kryteria akceptacji:

  - Formularz pozwala wprowadzić tekst przodu i tyłu.
  - Po zapisaniu fiszka jest widoczna na liście fiszek.

- ID: US-003  
  Tytuł: Edycja fiszek  
  Opis: Jako użytkownik chcę mieć możliwość zmiany treści przodu i tyłu istniejącej fiszki, by poprawiać lub aktualizować jej zawartość.  
  Kryteria akceptacji:

  - Użytkownik może wybrać istniejącą fiszkę.
  - Po edycji i zapisaniu zmiany są widoczne na liście.

- ID: US-004  
  Tytuł: Usuwanie fiszek  
  Opis: Jako użytkownik chcę usuwać niepotrzebne lub błędnie utworzone fiszki, aby utrzymywać aktualny i przydatny zestaw materiałów do nauki.  
  Kryteria akceptacji:
  - Użytkownik może wybrać dowolną fiszkę do usunięcia.
  - Po usunięciu fiszka nie jest widoczna na liście.

### 5.2 Zarządzanie kolekcjami

- ID: US-005  
  Tytuł: Tworzenie i edycja kolekcji  
  Opis: Jako użytkownik chcę tworzyć kolekcje, aby grupować fiszki tematycznie, oraz edytować nazwy i opisy tych kolekcji.  
  Kryteria akceptacji:

  - Możliwość podania nazwy kolekcji i opcjonalnego opisu.
  - Zmiany w nazwie i opisie kolekcji są od razu widoczne na liście kolekcji.

- ID: US-006  
  Tytuł: Przypisywanie fiszek do kolekcji  
  Opis: Jako użytkownik chcę dodawać lub usuwać fiszki z moich kolekcji, aby łatwo organizować materiały do nauki.  
  Kryteria akceptacji:

  - Użytkownik może przypisać fiszkę do jednej lub wielu kolekcji.
  - Użytkownik może usunąć fiszkę z kolekcji.
  - Lista fiszek w obrębie kolekcji jest aktualizowana w czasie rzeczywistym.

- ID: US-007  
  Tytuł: Usuwanie kolekcji  
  Opis: Jako użytkownik chcę usuwać niepotrzebne kolekcje, aby utrzymywać porządek w moich materiałach.  
  Kryteria akceptacji:
  - Użytkownik może usunąć wybraną kolekcję.
  - Po usunięciu kolekcji, fiszki pozostają w systemie, ale nie są przypisane do danej kolekcji.

### 5.3 Bezpieczny dostęp (uwierzytelnianie i autoryzacja)

- ID: US-008  
  Tytuł: Zakładanie konta i logowanie  
  Opis: Jako nowy użytkownik chcę móc założyć konto, a następnie logować się, aby moje fiszki i kolekcje były bezpiecznie przechowywane i tylko ja miałbym do nich dostęp.  
  Kryteria akceptacji:
  - Formularz rejestracji umożliwia wprowadzenie koniecznych danych (np. adresu email, hasła).
  - System umożliwia logowanie i wylogowywanie.
  - Tylko zalogowany użytkownik ma dostęp do swoich fiszek i kolekcji.

### 5.4 Korzystanie z algorytmu powtórek

- ID: US-009  
  Tytuł: Przeglądanie fiszek w oparciu o algorytm powtórek  
  Opis: Jako użytkownik chcę wyświetlać fiszki zgodnie z potrzebami algorytmu powtórek, aby efektywnie się uczyć.  
  Kryteria akceptacji:
  - Użytkownik widzi wybraną fiszkę na podstawie harmonogramu algorytmu.
  - Użytkownik ocenia, na ile pamiętał daną fiszkę (np. wskazuje, czy była łatwa czy trudna).
  - System rejestruje te dane i aktualizuje plan powtórek na kolejne dni.

### 5.5 Statystyki

- ID: US-010  
  Tytuł: Statystyki skuteczności AI  
  Opis: Jako właściciel produktu chcę mieć wgląd w liczbę fiszek tworzonych przez AI, liczbę zaakceptowanych i odrzuconych propozycji, aby monitorować jakość generowanego materiału.  
  Kryteria akceptacji:
  - System zlicza liczbę fiszek wygenerowanych przez AI oraz liczbę zaakceptowanych i odrzuconych.
  - Statystyki aktualizują się w czasie niemal rzeczywistym.
  - Statystyki przechowywane są w bazie danych i dostępne tylko przez bazę danych. Nie będziemy ich nigdzie wyświetlać.

## 6. Metryki sukcesu

1. 75% fiszek generowanych przez AI jest akceptowanych przez użytkowników.
   - Mierzone za pomocą systemu zliczającego liczbę propozycji AI i liczbę zatwierdzonych generacji.
2. 75% wszystkich fiszek powstaje poprzez AI.
   - Zliczana liczba fiszek generowanych przez AI vs. ręcznie utworzonych.

Dokument ten opisuje założenia funkcjonalne i niefunkcjonalne (ograniczenia, metryki) dotyczące produktu MVP o nazwie Express flash cards. Zawiera kluczowe informacje niezbędne do realizacji projektu w założonym czasie oraz przy planowanym zespole (jedna osoba w ciągu miesiąca). Wszystkie opisane w wymaganiach funkcjonalności i historyjki użytkownika można przetestować, a kryteria akceptacji są możliwe do weryfikacji w praktyce.
