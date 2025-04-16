# Architektura UI dla Express Flash Cards

## 1. Przegląd struktury UI

Nasza aplikacja składa się z kilku głównych widoków, które współpracują, aby zapewnić użytkownikowi intuicyjne zarządzanie fiszkami oraz kolekcjami, zarówno przy użyciu funkcji ręcznego tworzenia, jak i generowania za pomocą AI. Aplikacja korzysta z modalów do operacji (dodawanie, edycja, usuwanie), a nawigacja jest zaprojektowana tak, aby była responsywna, dostępna (WCAG AA) i bezpieczna. Integracja z Turbo streams umożliwia asynchroniczną synchronizację danych, a użycie RubyUI i TailwindCSS zapewnia spójny wygląd.

## 2. Lista widoków

- **Ekran logowania**

  - Ścieżka: `/sessions/new`
  - Główny cel: Umożliwienie użytkownikowi logowanie do systemu.
  - Kluczowe informacje: Formularz logowania z polami e-mail i hasło.
  - Kluczowe komponenty: Formularz, walidacja pól, przycisk logowania.
  - UX, dostępność i bezpieczeństwo: Prosty interfejs, natywna walidacja HTML5, wsparcie dla czytników ekranu.

- **Widok kolekcji**

  - Ścieżka: `/collections`
  - Główny cel: Prezentacja listy kolekcji użytkownika.
  - Kluczowe informacje: Nazwa kolekcji, przyciski tworzenia, edycji i usuwania.
  - Kluczowe komponenty: Lista kolekcji, modal do tworzenia/edycji, potwierdzenie usunięcia.
  - UX, dostępność i bezpieczeństwo: Czytelna lista, natywne walidacje, potwierdzenie operacji krytycznych.

- **Widok fiszek w kolekcji**

  - Ścieżka: `/collections/:id`
  - Główny cel: Wyświetlanie fiszek przypisanych do danej kolekcji.
  - Kluczowe informacje: Przód, tył fiszki, typ fiszki (manual, ai, edited_ai).
  - Kluczowe komponenty: Lista fiszek, modal do dodawania/edycji fiszki, przyciski usuwania.
  - UX, dostępność i bezpieczeństwo: Intuicyjna edycja (jedna fiszka na raz), asynchroniczne aktualizacje (Turbo streams), intuicyjne komunikaty walidacyjne i błędy.

- **Ekran generowania fiszek przez AI**

  - Ścieżka: `/flashcards/generate`
  - Główny cel: Pozwolenie użytkownikowi na wygenerowanie propozycji fiszek przez AI na podstawie wprowadzonego tekstu.
  - Kluczowe informacje: Tekst wejściowy (do 1000 znaków), wskaźnik limitów (znaki, liczba propozycji), lista propozycji.
  - Kluczowe komponenty: Pole tekstowe, licznik znaków, przycisk generowania, lista propozycji, możliwość zatwierdzania/edycji każdej propozycji.
  - UX, dostępność i bezpieczeństwo: Natychmiastowa informacja o przekroczeniu limitu, intuicyjne powiadomienia o sukcesie lub błędzie, integracja z systemem AI.

- **Modalne widoki operacyjne**
  - Ścieżki: Używane w różnych widokach (kolekcje, fiszki)
  - Główny cel: Umożliwienie operacji takich jak tworzenie, edycja i usuwanie bez zmiany widoku głównego.
  - Kluczowe informacje: Formularze modalne dostosowane do operacji, potwierdzenia operacji krytycznych.
  - Kluczowe komponenty: Modal, formularz, przyciski zatwierdzenia/anulowania, komunikaty błędów.
  - UX, dostępność i bezpieczeństwo: Łatwość użycia, responsywność, spełnienie standardów dostępności (WCAG AA).

## 3. Mapa podróży użytkownika

1. Użytkownik trafia na ekran logowania (`/sessions/new`) i wprowadza adres email oraz hasło.
2. Po zalogowaniu użytkownik zostaje przekierowany do widoku kolekcji (`/collections`), gdzie widzi listę swoich kolekcji.
3. Użytkownik wybiera kolekcję, co przenosi go do widoku fiszek (`/collections/:id`), gdzie może przeglądać, dodawać, edytować lub usuwać fiszki.
4. Aby wygenerować nowe fiszki, użytkownik przełącza się na ekran generowania AI (`/flashcards/generate`), gdzie wkleja tekst i otrzymuje propozycje.
5. Użytkownik zatwierdza wybrane propozycje, które pojawiają się w widoku fiszek.
6. W trakcie korzystania z aplikacji, modalne formularze umożliwiają edycję i potwierdzenie operacji, takich jak usuwanie zapisanych w kolekcji fiszek i kolekcji.
7. Komunikaty, spinnery i powiadomienia (toast notifications) informują użytkownika o stanie operacji.

## 4. Układ i struktura nawigacji

- Główna nawigacja w aplikacji będzie umieszczona na pasku (navbar) zawierającym:
  - Link do widoku kolekcji,
  - Opcję wylogowania.
- Nawigacja będzie responsywna, wspierana przez TailwindCSS i RubyUI, z uwzględnieniem różnych rozmiarów ekranów oraz standardów dostępności (WCAG AA).

## 5. Kluczowe komponenty

- **Formularz logowania:** Umożliwia wprowadzenie danych logowania z walidacją HTML5 i obsługą błędów.
- **Lista kolekcji:** Dynamicznie renderowana lista kolekcji użytkownika z opcjami edycji i usuwania.
- **Lista fiszek:** Interaktywna lista fiszek w wybranej kolekcji, z możliwością szybkiej edycji i usuwania.
- **Modal operacyjny:** Wspólny komponent dla tworzenia, edycji i usuwania zarówno fiszek, jak i kolekcji.
- **Ekran generowania fiszek AI:** Komponenty umożliwiające wprowadzenie tekstu, wyświetlenie liczników, listę propozycji oraz interaktywne zatwierdzanie lub edycję wygenerowanych fiszek.
- **Dodawanie fiszek do kolekcji** User musi widzieć w jakiej kolekcji dodaje nowe fiszki.
- **Spinner i powiadomienia (Toast):** Globalne komponenty informujące o postępie operacji oraz ewentualnych błędach.
- **Elementy nawigacyjne:** Pasek nawigacji, breadcrumb i responsywne menu, które umożliwiają przejście między widokami.
