# Opis usługi

OpenRouter to usługa umożliwiająca integrację z API OpenRouter, która wspomaga czaty oparte na LLM (Large Language Models). Usługa ta umożliwia wysyłanie komunikatów systemowych oraz użytkownika, przetwarzanie zapytań i odbieranie odpowiedzi w ustalonym formacie JSON. Dzięki dynamicznemu generowaniu treści oraz zarządzaniu sesjami, OpenRouter pozwala na elastyczną i efektywną komunikację z modelem językowym.

# Opis konstruktora

Konstruktor usługi inicjalizuje podstawowe ustawienia:

- Konfigurację połączenia z API (endpoint, klucz API),
- Domyślny komunikat systemowy,
- Parametry modelu (nazwa modelu, temperatura, max_tokens itp.),
- Ustawienia response_format ze schematem walidacji,
- Mechanizmy logowania i obsługi sesji czatu.

# Publiczne metody i pola

## Metody:

1. `send_chat_message(message: string): Response` – Wysyła komunikat (systemowy lub użytkownika) do API i zwraca odpowiedź.
2. `get_chat_response(): Response` – Pobiera oraz przekształca odpowiedź API zgodnie z ustalonym schematem.
3. `configure_api(config: object): void` – Umożliwia dynamiczną konfigurację ustawień API i modelu.

## Pola:

1. `system_message: string` – Domyślny komunikat systemowy wysyłany do API.
2. `user_message: string` – Aktualny komunikat użytkownika, który zostaje przekazany do API.
3. `model_name: string` – Nazwa wykorzystywanego modelu (np. "openrouter-model-1").
4. `model_params: object` – Parametry modelu, takie jak: { temperature: 0.7, max_tokens: 512, top_p: 1.0, frequency_penalty: 0, presence_penalty: 0 }.

# Prywatne metody i pola

## Metody:

1. `prepare_payload(message: string): object` – Przygotowuje payload zapytania do API, łącząc komunikat z dodatkowymi parametrami.
2. `transform_response(api_response: object): object` – Przekształca surową odpowiedź API do formatu zgodnego z następującym obiektem:

```
{response: 'any'}
```

3. `handle_error(error: Error): void` – Centralny mechanizm do obsługi błędów, który zarządza retry, logowaniem i powiadomieniami.

## Pola:

1. `api_endpoint: string` – URL endpointa API OpenRouter.
2. `retry_policy: object` – Konfiguracja retry (np. liczba prób, delay, exponential backoff).

# Obsługa błędów

Potencjalne scenariusze błędów i podejścia:

1. Błąd sieciowy (np. brak połączenia, timeout).
   - Rozwiązanie: Implementacja mechanizmu retry z exponential backoff.
2. Błąd autentykacji (np. niewłaściwy token API).
   - Rozwiązanie: Weryfikacja i odświeżanie tokena przed wysyłką zapytania.
3. Błąd walidacji odpowiedzi (niezgodny schemat JSON).
   - Rozwiązanie: Walidacja odpowiedzi przy użyciu predefiniowanego schema oraz fallback na komunikaty błędu.
4. Błąd serwera (np. 500 Internal Server Error).
   - Rozwiązanie: Rejestrowanie błędów oraz automatyczne powiadomienia do administratora.
5. Nieoczekiwane wyjątki (runtime errors).
   - Rozwiązanie: Globalny mechanizm obsługi wyjątków z logowaniem i generowaniem alertów.

# Kwestie bezpieczeństwa

1. Zapewnienie komunikacji za pomocą HTTPS.
2. Przechowywanie klucza API i wrażliwych danych w zmiennych środowiskowych.
3. Walidacja oraz sanityzacja wszystkich danych wejściowych i wyjściowych.
4. Implementacja rate limiting i mechanizmów wykrywania nadużyć.

# Plan wdrożenia krok po kroku

2. **Implementacja API Clienta**:

   - Utwórz klasę odpowiedzialną za komunikację z API OpenRouter.
   - Zaimplementuj metody: `prepare_payload`, `send_chat_message` oraz `get_chat_response`.
   - Klucz do OpenRouter API key znajduje się w Rails credentials `Rails.application.credentials.open_router_api_key`
   - Skonfiguruj mechanizm retry oraz obsługi błędów.

3. **Integracja transformacji odpowiedzi**:

   - Utwórz metodę `transform_response`, która waliduje odpowiedź korzystając z deklarowanego `response_format`.
   - Zaimplementuj walidację JSON schema przy użyciu odpowiednich gemów lub bibliotek.

4. **Konfiguracja komunikatów i parametrów modelu**:

   - Ustaw domyślny komunikat systemowy, np.: "System: You are a helpful and precise assistant.".
   - Przygotuj przykładowy komunikat użytkownika, np.: "User: Proszę o pomoc z moim zadaniem.".
   - Zdefiniuj `response_format` wg wzoru:
     { type: 'json_schema', json_schema: { name: 'chatResponseFormat', strict: true, schema: { message: 'string', timestamp: 'string', model: 'string', token_usage: 'number' } } }
   - Skonfiguruj nazwę modelu (np. "openrouter-model-1") oraz parametry modelu (np. { temperature: 0.7, max_tokens: 512, top_p: 1.0 }).

5. **Implementacja obsługi błędów**:

   - Zaimplementuj globalny mechanizm `handle_error`, obejmujący retry, logowanie oraz alerty.
   - Przetestuj różne scenariusze błędów w środowisku deweloperskim.
