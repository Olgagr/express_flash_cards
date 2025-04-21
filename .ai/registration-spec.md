# Specyfikacja Techniczna: Rejestracja Użytkownika

## 1. Przegląd

Celem jest dodanie funkcjonalności rejestracji nowych użytkowników do aplikacji "Express flash cards", która już posiada mechanizm logowania. Implementacja będzie oparta o Ruby on Rails 8, wykorzystując standardowe mechanizmy Rails (`has_secure_password`) oraz Hotwire (Turbo) dla poprawy doświadczenia użytkownika.

## 2. Architektura Interfejsu Użytkownika (Frontend)

### 2.1. Nowe Widoki

- **`app/views/users/new.html.erb`**: Nowy widok zawierający formularz rejestracyjny.
  - Będzie dostępny pod ścieżką `/signup`.
  - Formularz zostanie wygenerowany przy użyciu helpera `form_with(model: @user, url: users_path)`.
  - Formularz powinien być opakowany w `turbo_frame_tag 'registration_form'` w celu umożliwienia dynamicznego renderowania błędów walidacji bez przeładowania całej strony.

### 2.2. Pola Formularza

Formularz rejestracyjny będzie zawierał następujące pola:

- Adres e-mail (`email`)
- Hasło (`password`)
- Potwierdzenie hasła (`password_confirmation`)

### 2.3. Walidacja i Komunikaty Błędów

- **Walidacja po stronie klienta**: Można dodać podstawową walidację HTML5 (np. `required`, `type="email"`), ale główna walidacja odbędzie się po stronie serwera.
- **Walidacja po stronie serwera**:
  - Obecność adresu e-mail.
  - Unikalność adresu e-mail.
  - Poprawność formatu adresu e-mail.
  - Obecność hasła (tylko przy tworzeniu).
  - Minimalna długość hasła (np. 6 znaków).
  - Zgodność hasła i potwierdzenia hasła.
- **Wyświetlanie błędów**:
  - Błędy walidacji zwrócone przez serwer będą wyświetlane bezpośrednio przy polach formularza.
  - W przypadku niepowodzenia walidacji w akcji `create`, kontroler ponownie wyrenderuje widok `new` ze statusem `unprocessable_entity`. Dzięki `turbo_frame_tag`, tylko zawartość ramki formularza zostanie odświeżona, pokazując błędy walidacji zwrócone przez helpery `form_with`.
  - Przykładowe komunikaty: "Email nie może być pusty", "Email jest już zajęty", "Hasło jest za krótkie (minimum 6 znaków)", "Potwierdzenie hasła nie zgadza się z hasłem".

### 2.4. Komunikaty Sukcesu

- Po pomyślnej rejestracji, użytkownik zostanie przekierowany na stronę logowania (`/login`) lub bezpośrednio do panelu aplikacji (jeśli zdecydujemy się na automatyczne logowanie po rejestracji - na razie przekierowanie na logowanie).
- Wyświetlony zostanie komunikat typu `flash[:notice]` informujący o sukcesie, np. "Konto zostało pomyślnie utworzone. Zaloguj się.".

## 3. Logika Backendowa

### 3.1. Routing (`config/routes.rb`)

Należy dodać następujące trasy:

```ruby
# config/routes.rb
get 'signup', to: 'users#new'
resources :users, only: [:create] # Tylko akcja 'create' jest potrzebna dla rejestracji przez ten kontroler
# Istniejące trasy logowania/sesji pozostają bez zmian
# get 'login', to: 'sessions#new'
# post 'login', to: 'sessions#create'
# delete 'logout', to: 'sessions#destroy'
```

### 3.2. Kontroler (`app/controllers/users_controller.rb`)

Należy utworzyć lub zmodyfikować kontroler `UsersController`:

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  # Zakładamy, że istnieje layout aplikacji
  # layout 'application' # Opcjonalnie, jeśli nie jest to domyślny

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Opcjonalnie: automatyczne logowanie po rejestracji
      start_new_session_for @user
      redirect_to after_authentication_url, notice: 'Konto zostało pomyślnie utworzone. Zaloguj się.'
    else
      # Ponowne renderowanie formularza wewnątrz Turbo Frame
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
```

### 3.3. Model (`app/models/user.rb`)

Model `User` musi zawierać odpowiednie walidacje i mechanizm `has_secure_password`:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # Dodaje metody do ustawiania i uwierzytelniania hasła
  # Wymaga obecności kolumny password_digest w bazie danych
  # Automatycznie dodaje wirtualne atrybuty: password i password_confirmation
  has_secure_password

  # Walidacje
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  # Walidacja password_confirmation jest dodawana automatycznie przez has_secure_password

  # Relacje (jeśli istnieją, np. z fiszkami, kolekcjami)
  # has_many :flashcards
  # has_many :collections
end
```

_Uwaga: Należy upewnić się, że tabela `users` posiada kolumnę `password_digest` typu string._

### 3.4. Obsługa Wyjątków

- Standardowa obsługa błędów walidacji przez Rails (`@user.save` zwracające `false`) jest wystarczająca dla przepływu rejestracji. Kontroler renderuje formularz ponownie z błędami.
- Potencjalne błędy bazy danych (np. naruszenie unikalności e-maila na poziomie bazy danych, jeśli walidacja Rails zawiedzie przez race condition) będą skutkować standardowym błędem 500, co jest akceptowalne dla MVP.

### 3.5. Integracja z Hotwire (Turbo)

- **Turbo Frames**: Jak wspomniano w sekcji 2.1 i 2.3, formularz rejestracyjny (`users/new.html.erb`) powinien być opakowany w `turbo_frame_tag 'registration_form'`. W przypadku niepowodzenia walidacji w `UsersController#create`, renderowanie `:new, status: :unprocessable_entity` spowoduje, że Turbo automatycznie odnajdzie ramkę o tym samym ID w odpowiedzi i podmieni jej zawartość, wyświetlając formularz z błędami bez przeładowania strony.
- **Turbo Streams**: W tym przepływie nie są wymagane żadne dodatkowe Turbo Streams. Przekierowanie po sukcesie i renderowanie widoku po błędzie są obsługiwane przez standardowe mechanizmy Rails i Turbo Frames.

## 5. Bezpieczeństwo

- Użycie `has_secure_password` zapewnia hashowanie haseł.
- Walidacja `user_params` chroni przed mass assignment vulnerabilities.
- Należy upewnić się, że aplikacja używa HTTPS w środowisku produkcyjnym.
