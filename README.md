<h1 align="center">Counter</h1>

<p align="center">
  <img src=".github/assets/stack.svg" height="28" alt="Swift · UIKit · iOS" />
</p>

iOS-счётчик с историей действий и сохранением состояния между запусками.

[Запуск](#запуск) · [Хранение данных](#хранение-данных) · [English](#english)

## Возможности

- Увеличение и уменьшение значения на 1, сброс до нуля.
- Защита от отрицательного значения с записью попытки в историю.
- Журнал действий с датой и временем, доступный для чтения и выделения текста.
- Сохранение числа и последних **1000 записей** истории между запусками.
- Тактильный отклик при нажатии кнопок.

## Запуск

Нужны **macOS, Xcode с iOS SDK 17.2 или новее**. Проект использует Swift 5; текущий deployment target — **iOS 17.2**.

```bash
git clone https://github.com/artemleonich/Counter.git
cd Counter
open Counter.xcodeproj
```

Выберите схему **Counter**, симулятор и нажмите **Run** (⌘R). В проекте настроена поддержка iPhone и iPad.

Для физического устройства выберите свою команду в **Signing & Capabilities**.

## Хранение данных

[CounterStore](Counter/Stores/CounterStore.swift) отвечает за состояние:

| Данные | Хранилище |
| --- | --- |
| Значение счётчика | `UserDefaults`, ключ `Counter.countNumber` |
| История | `counter_history.json` в Application Support |
| Запись истории | `HistoryEntry`: дата и текст действия |

История сериализуется через `Codable` и записывается атомарно. При превышении 1000 записей удаляются самые старые. Контроллер обновляет интерфейс и передаёт действия хранилищу.

## Структура

```text
Counter/
├── ViewController.swift     # интерфейс и действия
├── Stores/CounterStore.swift
├── Models/HistoryEntry.swift
├── Base.lproj/              # главный экран и launch screen
├── Assets.xcassets/         # иконка и ресурсы
├── AppDelegate.swift
├── SceneDelegate.swift
└── Info.plist
CounterTests/                # проверки хранилища
CounterUITests/              # запуск и измерение запуска приложения
Counter.xcodeproj/
```

## Проверки

В `CounterTests` есть проверки изменения и восстановления значения, границы нуля, сохранения и лимита истории, обработки отсутствующего или повреждённого JSON, форматирования и работы с `UserDefaults`.

Чтобы запустить тесты, откройте проект, выберите симулятор и нажмите **Test** (⌘U). UI-тесты проверяют запуск приложения и измеряют время запуска.

## English

An iOS counter built with Swift and UIKit. Increment, decrement and reset the value; attempts to go below zero are recorded in the timestamped history. Button taps provide haptic feedback.

The count is stored in UserDefaults, while the latest 1,000 history entries are saved as JSON in Application Support. Open `Counter.xcodeproj`, choose the Counter scheme and a simulator, then press ⌘R. The current deployment target is iOS 17.2. Run the included tests with ⌘U.

## Автор / Author

Артём Леонов · [artemleonich](https://github.com/artemleonich)

