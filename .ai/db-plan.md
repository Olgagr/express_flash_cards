Jesteś doświadczonym programistą Ruby on Rails. Twoim zadaniem jest wygenerowanie migracji bazy danych.
Poniżej znajduje się podsumowanie rozmowy dotyczącej planowania bazy danych dla MVP "Express flash cards".
Weź również pod uwage, ze
<conversation_summary>
<decisions>
Zdecydowano o utworzeniu czterech głównych encji: users, flashcards, collections i stats (bez osobnej encji dla propozycji generowanych przez AI).
Relacje ustalone są następujące:
1:N między users a flashcards
N:M między flashcards a collections (poprzez join table zawierającą flashcard_id i collection_id)
1:N między users a collections
1:1 między users a stats
W tabeli flashcards dodano kolumnę flashcard_type ograniczoną check constraint, zezwalającą tylko na wartości "manual", "ai" i "edited_ai".
Przy usuwaniu użytkownika, wszystkie związane rekordy (flashcards, collections i stats) są usuwane kaskadowo.
Utworzone zostaną indeksy dla kolumn user_id w tabelach flashcards, collections i stats, a także indeksy na kolumnie flashcard_type w flashcards oraz na kluczach w join table.
Mechanizmy kontroli dostępu (RLS) będą implementowane na poziomie aplikacji, nie w samej bazie danych.
</decisions>
<matched_recommendations>
Utworzenie migracji Rails dla głównych encji (users, flashcards, collections i stats), korzystając z konwencji Rails (np. użycie timestamps dla automatycznego zarządzania datami).
Stworzenie join table dla relacji N:M między flashcards a collections, zawierającej tylko flashcard_id i collection_id.
Zastosowanie check constraint na kolumnie flashcard_type w tabeli flashcards, aby wymusić dozwolone wartości ("manual", "ai", "edited_ai").
Implementacja kaskadowego usuwania rekordów powiązanych z użytkownikiem.
Dodanie indeksów na krytycznych kolumnach (m.in. user_id, flashcard_type oraz kluczach w join table) w celu optymalizacji zapytań.
Dokumentacja i potwierdzenie, że kontrola dostępu będzie realizowana na poziomie aplikacji, co umożliwia uproszczenie struktury bazy danych.
</matched_recommendations>
<database_planning_summary>
Projekt bazy danych dla MVP "Express flash cards" obejmuje:
Główne encje: users, flashcards, collections i stats.
users: id (PK), email_address, password_digest, created_at, updated_at
flashcards: id (PK), user_id (FK), front_content, back_content, flashcard_type, created_at, updated_at
collections: id (PK), user_id (FK), name, created_at, updated_at
stats: id (PK), user_id (FK), manual_flashcards_count, ai_flashcards_count, edited_ai_flashcards_count, created_at, updated_at
Relacje:
Użytkownik (users) ma wiele fiszek (flashcards) oraz kolekcji (collections).
Fiszki (flashcards) mogą należeć do wielu kolekcji (collections) dzięki dedykowanemu join table (łączącemu flashcard_id oraz collection_id).
Użytkownik ma jedne statystyki (stats) (relacja 1:1).
Fiszki mają atrybut flashcard_type, z ograniczeniem do wartości "manual", "ai" i "edited_ai".
Integralność danych jest zabezpieczona przez stosowanie foreign keys, ograniczeń NOT NULL, UNIQUE oraz check constraints.
Mechanizm usuwania kaskadowego zapewnia, że przy usunięciu użytkownika, usuwane są również wszystkie związane z nim rekordy.
Indeksy są zastosowane na kolumnach kluczowych, aby zoptymalizować zapytania.
Kontrola dostępu (RLS) nie jest zaimplementowana w bazie, lecz na poziomie aplikacji, co upraszcza strukturę bazy przy zapewnieniu bezpieczeństwa.
Rails wykorzysta mechanizm timestamps dla automatycznego zarządzania polami created_at i updated_at.
</database_planning_summary>
<unresolved_issues>
Brak nierozwiązanych kwestii – wszystkie aspekty planowania bazy danych zostały szczegółowo omówione i zatwierdzone.
</unresolved_issues>
</conversation_summary>
