# API Документация

## Обзор

Приложение предоставляет несколько API endpoints для различных целей:
- **Internal API** — для внутренних сервисов (только localhost)
- **Mobile API** — для мобильного приложения волонтёров
- **Parkzhrun API** — для интеграции с системой Parkzhrun

Все API endpoints возвращают JSON и используют стандартные HTTP коды ответов.

## Internal API

### Базовый URL
```
/api/internal
```

### Авторизация
Доступ разрешён только с `127.0.0.1` (localhost).

### Endpoints

#### Создание пользователя
```
POST /api/internal/user
```

**Параметры:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password",
    "first_name": "Иван",
    "last_name": "Иванов",
    "telegram_id": 123456789,
    "telegram_user": "username"
  },
  "athlete": {
    "name": "Иван Иванов",
    "male": true,
    "parkrun_code": 123456,
    "fiveverst_code": 790000001,
    "runpark_code": 7000000001,
    "parkzhrun_code": 690000001
  },
  "athlete_id": 123
}
```

**Ответы:**
- `201 Created` — пользователь успешно создан
- `422 Unprocessable Entity` — ошибки валидации

**Пример ответа с ошибками:**
```json
{
  "errors": {
    "user": ["Email has already been taken"],
    "athlete": ["Name can't be blank"]
  }
}
```

#### Генерация ссылки авторизации
```
POST /api/internal/user/auth_link
```

**Параметры:**
```json
{
  "user_id": 1,
  "domain": "ru"
}
```

**Ответ:**
```json
{
  "link": "https://s95.ru/users/auth_links/abc123token"
}
```

#### Обновление атлета
```
PATCH /api/internal/athlete
```

**Параметры:**
```json
{
  "athlete": {
    "name": "Иван Иванов",
    "male": true,
    "club_id": 1,
    "event_id": 1
  }
}
```

**Ответы:**
- `200 OK` — успешно обновлено
- `422 Unprocessable Entity` — ошибки валидации
- `404 Not Found` — атлет не найден

## Mobile API

### Базовый URL
```
/api/mobile
```

### Авторизация
Не требуется (используется токен активности).

### Локализация
Поддерживается параметр `locale` (ru, rs, en):
```
GET /api/mobile/athletes/123456/info?locale=ru
```

### Endpoints

#### Информация об атлете
```
GET /api/mobile/athletes/:code/info
```

**Параметры:**
- `code` — код атлета (parkrun_code, fiveverst_code, runpark_code, parkzhrun_code или id)
- `locale` (query) — язык ответа (ru, rs, en)

**Ответ:**
```json
{
  "id": 123,
  "name": "Иван Иванов",
  "male": true,
  "code": 123456,
  "club": {
    "id": 1,
    "name": "Бегуны Москвы"
  },
  "event": {
    "id": 1,
    "name": "Кузьминки",
    "code_name": "kuzminki"
  }
}
```

**Коды ответов:**
- `200 OK` — успешно
- `404 Not Found` — атлет не найден

#### Отправка результатов с таймера
```
POST /api/mobile/activities/stopwatch
```

**Параметры:**
```json
{
  "token": "activity_secret_token",
  "results": [
    {
      "position": 1,
      "total_time": "00:18:30"
    },
    {
      "position": 2,
      "total_time": "00:19:15"
    }
  ]
}
```

**Формат времени:** `HH:MM:SS` (часы:минуты:секунды)

**Коды ответов:**
- `200 OK` — результаты приняты в обработку
- `422 Unprocessable Entity` — ошибка валидации или активность не найдена
- `404 Not Found` — активность не найдена

**Примечания:**
- Активность должна быть неопубликованной
- Дата активности должна быть сегодняшней
- Результаты обрабатываются асинхронно через `TimerProcessingJob`

#### Отправка результатов со сканера
```
POST /api/mobile/activities/scanner
```

**Параметры:**
```json
{
  "token": "activity_secret_token",
  "results": [
    {
      "position": "P1",
      "code": "A123456"
    },
    {
      "position": "P2",
      "code": "A123457"
    }
  ]
}
```

**Формат:**
- `position` — позиция финиша (например, "P1", "P2")
- `code` — код атлета (A + parkrun_code или другой код)

**Коды ответов:**
- `200 OK` — результаты приняты в обработку
- `422 Unprocessable Entity` — ошибка валидации или активность не найдена
- `404 Not Found` — активность не найдена

**Примечания:**
- Активность должна быть неопубликованной
- Дата активности должна быть сегодняшней
- Результаты обрабатываются асинхронно через `ScannerProcessingJob`

#### Отправка живых результатов
```
POST /api/mobile/activities/live
```

**Параметры:**
```json
{
  "token": "activity_secret_token",
  "activityStartTime": 1704556800,
  "results": [
    {
      "position": 1,
      "total_time": "00:18:30.45"
    },
    {
      "position": 2,
      "total_time": "00:19:15.12"
    }
  ]
}
```

**Формат:**
- `activityStartTime` — Unix timestamp начала забега
- `total_time` — время в формате `HH:MM:SS.MM` (с миллисекундами)

**Коды ответов:**
- `200 OK` — результаты обновлены
- `422 Unprocessable Entity` — ошибка валидации или активность не найдена
- `404 Not Found` — активность не найдена

**Примечания:**
- Результаты транслируются в реальном времени через ActionCable
- Активность должна быть неопубликованной
- Дата активности должна быть сегодняшней

## Parkzhrun API

### Базовый URL
```
/api/parkzhrun
```

### Авторизация
Требуется API ключ в заголовке:
```
Authorization: <api_key>
```

API ключ настраивается в Rails credentials:
```ruby
Rails.application.credentials.parkzhrun_api_key
```

### Endpoints

#### Обновление атлета
```
PATCH /api/parkzhrun/athletes/:id
```

**Заголовки:**
```
Authorization: <api_key>
Content-Type: application/json
```

**Параметры:**
```json
{
  "name": "Иван Иванов",
  "male": true,
  "club_id": 1,
  "event_id": 1
}
```

**Коды ответов:**
- `200 OK` — успешно обновлено
- `401 Unauthorized` — неверный API ключ
- `422 Unprocessable Entity` — ошибки валидации
- `404 Not Found` — атлет не найден

#### Создание активности
```
POST /api/parkzhrun/activities
```

**Заголовки:**
```
Authorization: <api_key>
Content-Type: application/json
```

**Параметры:**
```json
{
  "event_id": 1,
  "date": "2024-01-06",
  "description": "Описание забега"
}
```

**Коды ответов:**
- `201 Created` — активность создана
- `401 Unauthorized` — неверный API ключ
- `422 Unprocessable Entity` — ошибки валидации

**Ответ:**
```json
{
  "id": 123,
  "event_id": 1,
  "date": "2024-01-06",
  "description": "Описание забега",
  "published": false,
  "token": "generated_secret_token"
}
```

## Коды ошибок

### HTTP статус коды

- `200 OK` — успешный запрос
- `201 Created` — ресурс успешно создан
- `400 Bad Request` — неверный формат запроса
- `401 Unauthorized` — требуется авторизация
- `403 Forbidden` — доступ запрещён
- `404 Not Found` — ресурс не найден
- `422 Unprocessable Entity` — ошибки валидации
- `500 Internal Server Error` — внутренняя ошибка сервера

### Формат ошибок

```json
{
  "errors": {
    "field_name": ["Error message 1", "Error message 2"]
  }
}
```

или

```json
{
  "error": "Error message"
}
```

## Rate Limiting

API защищено от злоупотреблений через Rack::Attack. Ограничения настраиваются в `config/initializers/rack_attack.rb`.

## Версионирование

В настоящее время API не версионируется. При необходимости изменения будут обратно совместимыми или будет добавлена версия в URL.

## Примеры использования

### cURL примеры

#### Создание пользователя (Internal API)
```bash
curl -X POST http://localhost:3000/api/internal/user \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password",
      "first_name": "Иван",
      "last_name": "Иванов"
    },
    "athlete": {
      "name": "Иван Иванов",
      "male": true
    }
  }'
```

#### Получение информации об атлете (Mobile API)
```bash
curl http://localhost:3000/api/mobile/athletes/123456/info?locale=ru
```

#### Отправка результатов с таймера (Mobile API)
```bash
curl -X POST http://localhost:3000/api/mobile/activities/stopwatch \
  -H "Content-Type: application/json" \
  -d '{
    "token": "activity_token",
    "results": [
      {"position": 1, "total_time": "00:18:30"},
      {"position": 2, "total_time": "00:19:15"}
    ]
  }'
```

#### Обновление атлета (Parkzhrun API)
```bash
curl -X PATCH http://localhost:3000/api/parkzhrun/athletes/123 \
  -H "Authorization: your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Иван Иванов",
    "male": true
  }'
```

## Webhooks

В настоящее время приложение не поддерживает webhooks. Уведомления отправляются через:
- Email (ActionMailer)
- Telegram бот (если настроен)

