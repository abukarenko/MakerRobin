# Robin Nano V3.1 — Marlin 2.1.2.8

Подготовлено 11 октября 2026. Исходный проект: `C:\Marlin\Marlin-2.1.2.8`.
Отдельная копия: `Marlin-RobinNano31`. Исходная папка не изменяется.

## Конфигурация

- STM32F407VET6, 512 КиБ Flash; PlatformIO `mks_robin_nano_v3_1`.
- Адрес приложения `0x0800C000`, загрузчик сохраняется. В полном заводском дампе по смещению `0xC000` обнаружены начальный SP `0x2001FFD8` и Reset_Handler `0x0800DD99`.
- CoreXY, стол 210×210 мм, Z до 160 мм; настройки механики перенесены из текущего исходника, не из старых заметок.
- Шаги/мм X/Y/Z/E: 80/80/780/420. Максимальные скорости 120/120/4/10 мм/с.
- Один экструдер, термисторы хотэнда и стола типа 1, температурные защиты сохранены.
- X/Y/Z/E0: TMC2209 UART, 800 мА RMS, 16 микрошагов, интерполяция включена, StealthChop. Автопереход в SpreadCycle отключён. `M122` с расширенной диагностикой.
- BLTouch: PA8 управление; сигнал на Z− (PC8), замена Z-концевика; safe homing, bilinear 10×9. Смещение {0,24,0} из исходника. Z-offset 0 требует калибровки на принтере.
- FAN0 (PC14) — обдув детали. FAN1 (PB1) — автоматический вентилятор хотэнда, включение при 50 °C.
- TFT: ILI9488 SPI 480×320, TFT_COLOR_UI, XPT2046, калибровка touch, без энкодера. Интерфейс английский, как в исходнике.
- Для ILI9488 SPI: COLMOD=0x66; RGB565 буфер преобразуется в RGB666, передача синхронная, чтобы не конфликтовать с touch на SPI1. Параллельный режим остаётся RGB565.

## Проводка дисплея

Текущая версия: один шлейф EXP2. Нумерация дисплея начинается с VDD=1.

| Дисплей | Номер пина дисплея | Контакт платы |
|---|---|---|
| VDD + BL | 1 + 8 | EXP2-10, 3V3; подсветка постоянно включена |
| GND | 2 | EXP2-9 |
| CS | 3 | EXP2-4, PE10 |
| RST | 4 | EXP2-3, PE8 |
| D/C | 5 | EXP2-7, PE12 |
| SDI + TDI | 6 + 12 | EXP2-6, PA7 |
| SCK + TCK | 7 + 10 | EXP2-2, PA5 |
| TCS | 11 | EXP2-5, PE11 |
| TDO | 13 | EXP2-1, PA6 |
| SDO, PEN | 9, 14 | не подключать |

EXP2-8 (RESET платы) не подключать. EXP1 для дисплея не используется.

Модуль microSD на дисплее не используется; используется слот платы.

## BLTouch

Три провода: GND, 5V, управляющий сигнал PA8 в разъём BLTOUCH.
Два провода: GND и сигнал в разъём Z−. Порядок проверять по надписям, не только по цветам.

## Проверка после прошивки

Сборка не доказывает работу дисплея, touch, BLTouch и механики. Прошивка пока не записана.
На стенде без термисторов не давать команды нагрева; температурные защиты не отключены.
До homing: проверить M115, M503, M122 (microsteps=16), температуры M105,
BLTouch deploy/stow и срабатывание входа. Затем проверить направления и концевики.
При первом старте согласовать EEPROM с новой конфигурацией: M502, M500 после проверки
новых значений; старые сохранённые параметры не использовать вслепую.
На CoreXY команда X приводит в действие оба двигателя X/Y.

## Резервная копия

Полный исходный Flash: `firmware_MKS_Robin_Nano V3.1_0x80000.bin`, 524288 байт.
SHA256: `559FFF95D516A43EEBAE5B412F4816B73278F53E882783C44D4C9B6582574238`.
Для восстановления полный дамп пишется ST-Link по `0x08000000`.
Новый файл приложения пишется по `0x0800C000`, не по адресу загрузчика.

## Сборка

```powershell
& 'C:\Users\basachka\.platformio\penv\Scripts\platformio.exe' run -d Marlin-RobinNano31 -e mks_robin_nano_v3_1
```

Результат ожидается в `.pio/build/mks_robin_nano_v3_1/Robin_nano_v3.bin`.
Для обновления через microSD скопировать его в корень карты и перезапустить плату.
Для TFT_COLOR_UI папка assets не нужна.

## Первая сборка (архивная версия на двух EXP)

PlatformIO SUCCESS. Flash: 264028 / 475136 байт (55,6%); RAM: 49448 / 131072 байт (37,7%).
Архивный файл: `release/archive_two_EXP/Robin_nano_v3.bin`, 264552 байта.
SHA256: `b121f0b3790fe82f52bacfb456f62fcda185631c59619501591734afda1b5457`.
Проверен вектор запуска: SP `0x2001FFD8`, Reset_Handler `0x0800DC85`.
Исходные файлы C:\Marlin\Marlin-2.1.2.8 не изменены — проверены по контрольным суммам.
Единственное предупреждение компилятора: снять DIAG-перемычки, поскольку SENSORLESS_HOMING отключён.
Прошивка на плату не записана; работа дисплея, touch и BLTouch на оборудовании пока не проверена.

## EXP2-only build

PlatformIO SUCCESS, 263972 / 475136 Flash, 49448 / 131072 RAM.
Current file: `release/Robin_nano_v3.bin`, 264496 bytes.
SHA256: `b3a61da4ef69356b2a25eb687c5cc5c41b31d3a7ed91bf47d24355015138fa3b`.
Address: 0x0800C000. ST-Link CMD uses this updated file.
Not flashed or hardware-tested yet.

## Исправление изображения и проверка touch

После первой проверки на оборудовании пользователь сообщил: негативные цвета,
поворот изображения на 180°, отсутствие реакции сенсора.
Изменения следующей сборки:

- `TFT_ROTATION TFT_ROTATE_180` — поворот относительно предыдущей версии.
- Команда ILI9488 `INVON` — переключение инверсии панели; результат нужно проверить на экране.
- XPT2046: SPI mode 0, частота SPI1 1,3125 МГц вместо 5,25 МГц.
- Проводка EXP2 остаётся прежней.

После записи новой версии выполнить `M995` через терминал и нажать точки калибровки.
Если точки не реагируют, проверить TCS=EXP2-5, TDO=EXP2-1, TDI=EXP2-6,
TCK=EXP2-2, питание и отсутствие соединения SDO дисплея с MISO.
Калибровка сама по себе не исправляет отсутствие электрического обмена с сенсором.

Сборка исправлений: SUCCESS, Flash 263964 / 475136, RAM 49448 / 131072.
Файл release/Robin_nano_v3.bin: 264488 байт, SHA256 784b8ba835f3b79568fe16d34b3a4ec881f2102a470ecb32743b5df9474d86df.
Предыдущая версия сохранена в release/archive_single_EXP_before_display_fix.
Новая версия на плату не записана; исправления требуют проверки на оборудовании.

## Touch diagnostics
Calibration remains at Top left on hardware. Added M995 D: raw X/Y/Z1/Z2, no motion and no calibration change. Added RX/OVR flush before touch transaction on shared SPI. This is a diagnostic candidate, not a confirmed fix. TFT transmit already clears OVR after each byte.
Build SUCCESS: Flash 264284/475136; RAM 49448/131072. SHA256 5bde32149064c4622a49eecc629267cbbbb3a7790294596f2779b6006be5244b
Run M995 D without pressing, then while pressing the resistive panel with a plastic stylus. Keep display SDO disconnected, touch TDO connected to EXP2 pin 1.

## Software touch SPI trial
User confirmed continuity on all four touch wires. Hardware SPI diagnostic was all 4095. Use slow GPIO SPI mode 0 for touch, deselect TFT, disable SPI1, restore shared pins to alternate functions after each transaction. Clock at most 125 kHz (2 us half-cycle plus GPIO overhead). M995 D preserved. Successful build; hardware result pending. Flash 264468/475136. SHA256 0ad3afcd8c5d4dafe16ff5a6f555c34c7ee8b1bbef0e3cf7d0b5b1e0f00fe0f7

## Итог проверки пользователем, 2026-10-11
Текущая сборка записана. Пользователь подтвердил: дисплей настроен и работает нормально; сенсор работает с программным SPI после калибровки; BLTouch работает нормально. Проверка M119 при срабатывании, G28 и G29 отдельно не зафиксирована. Вопрос направления X разрешён: пользователь не учёл CoreXY. Исторические отметки выше о непроверенных сборках относятся к моменту их создания.
