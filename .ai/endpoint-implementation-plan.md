# API Endpoint Implementation Plan: POST /flashcards/generate

## 1. Przegląd punktu końcowego

Endpoint ma na celu wygenerowanie propozycji fiszek przy użyciu AI. Na podstawie podanego tekstu (maksymalnie 1000 znaków) generowane są propozycje zawierające treść pytania (front_content) oraz odpowiedzi (back_content). Endpoint zwraca wynik w postaci struktury JSON zawierającej tablicę propozycji.

## 2. Szczegóły żądania

- **Metoda HTTP:** POST
- **Struktura URL:** /flashcards/generate
- **Parametry:**

  - **Wymagane:**
    - input_text (string, maksymalnie 1000 znaków)
  - **Opcjonalne:** Żadne

- **Body Request (JSON):**

```json
{
  "input_text": "Your text input here (max 1000 characters)"
}
```

## 3. Szczegóły odpowiedzi

- **Kod 200 OK:** W przypadku prawidłowego przetworzenia żądania
  - **Body Response:**
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
- **Kod 400 Bad Request:** Jeśli `input_text` przekracza 1000 znaków lub brakuje wymaganego pola
- **Kod 500 Internal Server Error:** W przypadku nieoczekiwanych błędów po stronie serwera

## 4. Przepływ danych

1. Klient wysyła żądanie POST do `/flashcards/generate` z JSON zawierającym `input_text`.
2. Kontroler (np. `FlashcardsController`) waliduje wejście sprawdzając długość `input_text`.
3. W przypadku poprawnej walidacji, kontroler wywołuje service object (np. `FlashcardGenerationService`), który przetwarza logikę generowania propozycji.
4. Service integruje się z modułem AI w celu wygenerowania propozycji fiszek.
5. Otrzymane propozycje zostają opakowane w strukturę JSON i zwrócone do klienta jako odpowiedź.

## 5. Względy bezpieczeństwa

- **Walidacja wejścia:** Weryfikacja obecności pola `input_text` i ograniczenie długości do 1000 znaków.
- **Rate Limiting:** Rozważenie implementacji mechanizmu ograniczania liczby żądań, aby zapobiec nadużyciom.
- **Bezpieczna integracja z AI:** Zapewnienie, że wywołania do modułu AI są bezpieczne i nie narażają systemu na ujawnienie danych lub inne zagrożenia.

## 6. Obsługa błędów

- **400 Bad Request:** Gdy `input_text` jest zbyt długi lub brakuje wymaganego pola. Szczegółowy komunikat błędu informuje o problemie z danymi wejściowymi.
- **500 Internal Server Error:** W przypadku nieoczekiwanych błędów, z zachowaniem bezpieczeństwa, aby nie ujawniać wewnętrznych szczegółów systemu.

## 7. Rozważania dotyczące wydajności

- **Wstępna walidacja:** Walidacja wejścia na etapie kontrolera pozwala na szybkie odrzucenie niepoprawnych żądań zanim nastąpi kosztowna operacja generowania AI.
- **Asynchroniczność:** Jeśli generowanie propozycji stanie się czasochłonne, rozważenie przeniesienia logiki do background jobs.
- **Caching:** Rozważenie mechanizmu cache'owania odpowiedzi dla identycznych lub podobnych zapytań, aby zmniejszyć obciążenie systemu.

## 8. Etapy wdrożenia

1. Utworzenie nowej akcji `generate` w kontrolerze `FlashcardsController` do obsługi żądania POST na `/flashcards/generate`.
2. Walidacja długości `input_text` (maks. 1000 znaków).
3. Stworzenie service object (np. `FlashcardGenerationService`) odpowiedzialnego za integrację z modułem AI oraz generowanie propozycji fiszek.
4. Implementacja logiki wywołania modułu AI wewnątrz service object w postaci mock-a. Nie implementuj prawdziwego request-a do LLM-a.
5. Zbudowanie odpowiedzi JSON zgodnie ze specyfikacją i zwrócenie jej przez kontroler.
6. Dodanie testów jednostkowych oraz integracyjnych w celu zapewnienia prawidłowego działania endpointu.
7. Przeprowadzenie przeglądu kodu (code review) oraz testów bezpieczeństwa i wydajności.
8. Wdrożenie zmiany na środowisku testowym, a następnie po pozytywnym przeglądzie na produkcję.
