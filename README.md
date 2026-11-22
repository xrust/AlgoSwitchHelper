# AlgoSwitchHelper

[Русский](#русский) · [English](#english)

## English

An Expert Advisor for **MetaTrader 4** that presses the **Algo Trading** toolbar button on or off. It never trades, reads no account data and uses no network.

It exists for the *MT-Remote Economic Calendar Feed* Expert (Guard: stop the advisors before news, switch them on again afterwards, switch the button on for the time of closing the orders). It can be used by any other program the same way.

### Why an Expert Advisor

MQL4 cannot press this button directly. A template can hold an Expert and cannot hold a script, so the calling Expert opens a chart, applies a template with this helper to it, the helper presses the button once and closes the chart.

### How it works

- It posts one `WM_COMMAND` message (the command of the Algo Trading button, 33020) to the main window of its own terminal: exactly what a mouse click does.
- It looks at the state first: "off" on an already off button does nothing.
- The result is left in the global variables of the terminal: `MTX_ALGO_STATE` (1 trading allowed, 0 not) and `MTX_ALGO_TIME` (local time of the end of the work).
- Input `Mode`: 0 switch off, 1 switch on, 2 toggle, 3 do nothing (the default; it lets you save a template with the helper).
- Input `CloseChart`: close the chart of the helper when done.

### Installation

1. Put `AlgoSwitchHelper.mq4` (or the compiled `.ex4`) into `MQL4\Experts` of your terminal (a subfolder is fine) and compile it in MetaEditor.
2. Allow DLL imports: *Tools - Options - Expert Advisors - Allow DLL imports*. The helper imports `user32.dll` (`GetAncestor`, `GetParent`, `PostMessageW`) and nothing else.
3. In the *MT-Remote Economic Calendar Feed* Expert set `AlgoSwitchHelperPath` (the subfolder inside `MQL4\Experts`, empty if the file is in the Experts folder itself) and `AlgoSwitchHelperName` (the file name without `.ex4`, `AlgoSwitchHelper` by default).
4. You do not have to put the helper on any chart by hand.

Tested on MetaTrader 4 build 1492.

### Safety

DLL imports are needed only for one system call (`PostMessage`). The source is open, read it before you allow it.

## Русский

Советник для **MetaTrader 4**, который включает и выключает кнопку **«Алго-трейдинг»** на панели инструментов. Он ничего не торгует, не читает данные счёта и не использует сеть.

Нужен советнику *MT-Remote Economic Calendar Feed* (Guard: остановить советников перед новостью, включить их потом, включить кнопку на время закрытия ордеров). Любая другая программа может использовать его так же.

### Почему это советник

MQL4 не позволяет нажать эту кнопку напрямую. В шаблон можно положить советника, но не скрипт: вызывающий советник открывает график, применяет к нему шаблон с этим помощником, помощник один раз нажимает кнопку и закрывает график.

### Как это работает

- Он отправляет главному окну своего терминала одно сообщение `WM_COMMAND` (команда кнопки «Алго-трейдинг», 33020): то же самое, что щелчок мышью.
- Сначала смотрит на состояние: «выключить» при уже выключенной кнопке ничего не делает.
- Результат остаётся в глобальных переменных терминала: `MTX_ALGO_STATE` (1 торговля разрешена, 0 нет) и `MTX_ALGO_TIME` (локальное время конца работы).
- Параметр `Mode`: 0 выключить, 1 включить, 2 переключить, 3 ничего не делать (по умолчанию, чтобы сохранить шаблон с помощником).
- Параметр `CloseChart`: закрыть график помощника по окончании.

### Установка

1. Положите `AlgoSwitchHelper.mq4` (или готовый `.ex4`) в `MQL4\Experts` терминала (можно в подпапку) и скомпилируйте в MetaEditor.
2. Разрешите импорт DLL: *Сервис - Настройки - Советники - Разрешить импорт DLL*. Помощник импортирует `user32.dll` (`GetAncestor`, `GetParent`, `PostMessageW`) и ничего больше.
3. В советнике *MT-Remote Economic Calendar Feed* задайте `AlgoSwitchHelperPath` (подпапка внутри `MQL4\Experts`, пусто, если файл лежит прямо в папке Experts) и `AlgoSwitchHelperName` (имя файла без `.ex4`, по умолчанию `AlgoSwitchHelper`).
4. Прикреплять помощника к графикам вручную не нужно.

Проверено на MetaTrader 4, сборка 1492.

### Безопасность

Импорт DLL нужен только ради одного системного вызова (`PostMessage`). Исходный код открыт, прочтите его перед тем, как разрешать.
