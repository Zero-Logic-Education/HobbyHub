# Спецификация дизайна HobbyHub

Этот документ содержит основные параметры дизайна, извлеченные из макетов Figma, для обеспечения консистентности при разработке.

## Цветовая палитра

| Название             | Hex-код   | Образец                                                  | Применение                 |
| :------------------- | :-------- | :------------------------------------------------------- | :------------------------- |
| **Primary**          | `#F17A5D` | ![#F17A5D](https://via.placeholder.com/15/F17A5D?text=+) | Кнопки, активные элементы  |
| **Secondary**        | `#FF8A7B` | ![#FF8A7B](https://via.placeholder.com/15/FF8A7B?text=+) | Второстепенные акценты     |
| **Accent**           | `#FF6B4A` | ![#FF6B4A](https://via.placeholder.com/15/FF6B4A?text=+) | Яркие акценты, уведомления |
| **Background**       | `#FAFAFA` | ![#FAFAFA](https://via.placeholder.com/15/FAFAFA?text=+) | Фон экранов                |
| **Surface**          | `#FFFFFF` | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF?text=+) | Карточки, модальные окна   |
| **Input Background** | `#FAE8ED` | ![#FAE8ED](https://via.placeholder.com/15/FAE8ED?text=+) | Поля ввода (Light Pink)    |
| **Text Primary**     | `#1A1A1A` | ![#1A1A1A](https://via.placeholder.com/15/1A1A1A?text=+) | Основные заголовки и текст |
| **Text Secondary**   | `#666666` | ![#666666](https://via.placeholder.com/15/666666?text=+) | Подзаголовки, описания     |

## Ссылка на макеты

> [!NOTE]
> Исходные изображения макета (Splash, Home, Create Account, Event, Interests, Profile) зафиксированы как референс. Рекомендуется хранить оригиналы в папке `docs/design/` или `assets/design/`.

## Компоненты UI

- **Кнопки**: Скругление `12px`, шрифт `SemiBold`.
- **Поля ввода**: Скругление `12px`, без обводки (в обычном состоянии), фон `surfaceVariant` (`#FAE8ED`).
- **Карточки**: Скругление `16px`, тень `elevation: 2`.
