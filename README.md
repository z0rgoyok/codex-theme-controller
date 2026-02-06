# codex-theme-controller

Нативная macOS SwiftUI app для управления темой в запущенных инстансах Codex.

## Что и зачем

Приложение показывает текущие процессы `Codex` и позволяет применять темы через CDP (Chrome DevTools Protocol), без ручного поиска PID и портов.  
Интерфейс состоит из иконки в статус-баре (tray) и отдельного окна контроллера.

## Основные возможности

- Сканирование запущенных инстансов Codex (`PID`, команда, `--remote-debugging-port`).
- Иконка в tray (menu bar) с быстрыми действиями: открыть окно, refresh, apply all.
- Темы: `Darcula`, `Dracula`, `Nord`, `Monokai`.
- По выбору темы она сразу применяется к уже запущенным инстансам Codex.
- Master-detail UI: слева список инстансов, справа действия для выбранного инстанса.
- Кнопки `Apply to Selected` / `Reset Selected` для выбранного инстанса.
- Массовое применение `Apply to All`.
- Кнопка запуска нового Codex с нужным debug-портом: выбранная тема применяется автоматически после `Launch & Apply`.
- Последняя выбранная тема сохраняется и восстанавливается при следующем запуске контроллера.

## Требования

- macOS 14+
- Xcode 16+ / Swift 6+
- Для смены темы у инстанса он должен быть запущен с `--remote-debugging-port=<port>`.

## Запуск

```bash
cd /Users/deniszabozhanov/dev/tools/codex-theme-controller
make run-app
```

`make run-app` собирает `.app` bundle и запускает его через `open`, чтобы приложение было обычным macOS app (иконка в Dock + иконка в tray).
При закрытии окна процесс не завершается: остаётся активным в tray и окно можно открыть снова из пункта `Open Window`.
В актуальной версии окно разбито на секции `Theme`, `Selected Instance`, `Launch New Codex`, а сверху есть строка статуса с индикатором результата операции.
Клик по иконке в Dock всегда возвращает окно в фокус. Завершение: `Quit` в tray-меню или `Cmd+Q`.

## Проверка

```bash
cd /Users/deniszabozhanov/dev/tools/codex-theme-controller
swift test
swift build
```
