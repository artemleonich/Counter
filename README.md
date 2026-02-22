# Counter

**[Русский](#русский) | [English](#english)**

---

## Русский

### Описание

Counter — iOS-приложение «Счётчик», написанное на Swift с использованием UIKit. Позволяет увеличивать, уменьшать и сбрасывать значение счётчика. Все изменения фиксируются в журнале истории с указанием даты и времени. Приложение не допускает уменьшения счётчика ниже нуля.

### Возможности

- Увеличение счётчика на 1 (кнопка «+»)
- Уменьшение счётчика на 1 (кнопка «−»), с защитой от отрицательных значений
- Сброс счётчика до 0
- Журнал истории изменений с метками времени
- Тактильная обратная связь (вибро-отклик) при нажатии кнопок
- Автоматическая прокрутка журнала истории

### Технологии

- Swift
- UIKit
- Xcode
- Interface Builder (Storyboard)
- XCTest (Unit- и UI-тесты)

### Структура проекта

```
Counter/
├── Counter/
│   ├── AppDelegate.swift       # Делегат приложения
│   ├── SceneDelegate.swift     # Делегат сцены
│   ├── ViewController.swift    # Основной контроллер со счётчиком
│   ├── Assets.xcassets/        # Ресурсы (иконки, изображения)
│   ├── Base.lproj/             # Storyboard
│   └── Info.plist              # Конфигурация приложения
├── CounterTests/               # Unit-тесты
├── CounterUITests/             # UI-тесты
└── Counter.xcodeproj/          # Файл проекта Xcode
```

### Требования

- iOS 13.0+
- Xcode 15.0+
- Swift 5.0+

### Установка и запуск

Клонируйте репозиторий:

```bash
git clone https://github.com/artemleonich/Counter.git
```

Откройте проект в Xcode:

```bash
cd Counter
open Counter.xcodeproj
```

Выберите симулятор или подключённое устройство и нажмите **Run** (⌘R).

### Автор

Артём — [GitHub](https://github.com/artemleonich)

---

## English

### Description

Counter is an iOS app built with Swift and UIKit. It allows users to increment, decrement, and reset a counter value. All changes are logged in a history journal with timestamps. The app prevents the counter from going below zero.

### Features

- Increment counter by 1 ("+" button)
- Decrement counter by 1 ("−" button), with protection against negative values
- Reset counter to 0
- Change history log with timestamps
- Haptic feedback on button presses
- Auto-scrolling history journal

### Tech Stack

- Swift
- UIKit
- Xcode
- Interface Builder (Storyboard)
- XCTest (Unit and UI tests)

### Project Structure

```
Counter/
├── Counter/
│   ├── AppDelegate.swift       # App delegate
│   ├── SceneDelegate.swift     # Scene delegate
│   ├── ViewController.swift    # Main counter view controller
│   ├── Assets.xcassets/        # Assets (icons, images)
│   ├── Base.lproj/             # Storyboard
│   └── Info.plist              # App configuration
├── CounterTests/               # Unit tests
├── CounterUITests/             # UI tests
└── Counter.xcodeproj/          # Xcode project file
```

### Requirements

- iOS 13.0+
- Xcode 15.0+
- Swift 5.0+

### Installation

Clone the repository:

```bash
git clone https://github.com/artemleonich/Counter.git
```

Open the project in Xcode:

```bash
cd Counter
open Counter.xcodeproj
```

Select a simulator or connected device and press **Run** (⌘R).

### Author

Artem — [GitHub](https://github.com/artemleonich)
