<p align="center">
  <h1 align="center">AxeM_Hitbox v2.0 \ o(*￣▽￣*)ブ</h1>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Roblox-Luau-2C2D72?style=for-the-badge&logo=roblox&logoColor=white" alt="Luau">
  <img src="https://img.shields.io/badge/Optimized%20for-Rojo-E05A47?style=for-the-badge&logo=visual-studio-code&logoColor=white" alt="Rojo">
  <img src="https://img.shields.io/badge/Style-Unix%20Way-422C1A?style=for-the-badge">
</p>

---

**AxeM_Hitbox** — это высокоточная модульная система хитбоксов для Roblox. Создана для разработчиков, которые ценят предельную производительность, чистый изолированный код и гибкую настройку регистрации попаданий.

Модуль полностью оптимизирован под **Rojo** и современный рабочий процесс (Рейлинг/Инструментарий) внутри VS Code.

> 📦 **Roblox Model:** [Забрать в инвентарь](https://create.roblox.com/store/asset/131038870784326/AxeMHitboxV20)

---

### 🛠 Ключевые фичи (Key Features)

* ⚡ **High Precision** — Работает на частоте обновления до `0.01s` (настраивается через `PollRate`), позволяя фиксировать даже самые быстрые и резкие атаки.
* 🧠 **Smart Filtering** — Автоматически отсекает аксессуары персонажей, объекты окружения и уже погибших персонажей (`Humanoid.Health <= 0`).
* 🚀 **Deep Optimization** — Параметры `OverlapParams` инициализируются строго один раз при создании хитбокса. Это полностью исключает нагрузку на сборщик мусора (Garbage Collector pressure) во время циклов `Heartbeat`.
* 🎯 **3 Registration Modes** — Из коробки доступны три режима детекции под любые задачи (Single, Cooldown, Always).
* 👁 **Live Visualization** — Встроенный debug-режим для безопасного отображения и настройки геометрии хитбокса в реальном времени.

---

### ⚙️ Режимы работы (Touch Modes)

Визуальная демонстрация того, как ведут себя разные типы регистрации попаданий:

#### 1. Single (Одиночный)
Регистрирует попадание по модели только **один раз** за всё время существования или за один цикл активности хитбокса.
> ![Single Mode](Assets/Gif/Single.gif)

#### 2. Cooldown (Перезарядка)
Регистрирует повторные удары по одной и той же цели только после того, как истечет заданное время `TouchCooldown`.
> ![Cooldown Mode](Assets/Gif/Cooldown.gif)

#### 3. Always (Постоянный)
Регистрирует попадания абсолютно **каждый кадр**, пока хитбокс активен (с частотой, заданной в `PollRate`).
> ![Always Mode](Assets/Gif/Always.gif)

---

### 💻 Пример использования (Usage Example)

```lua
local AxeM_Hitbox = require(game.ReplicatedStorage.Module.AxeMHitbox.Core)

-- Создание конфигурации хитбокса
local hitbox = AxeM_Hitbox.new({                         
    AnchorPart = script.Parent,      -- К какому Part привязать центр зоны
    Size = Vector3.new(4, 6, 4),      -- Размеры хитбокса (X, Y, Z)
    Visible = true,                  -- Включить визуализацию для теста
    TouchMode = "cooldown",          -- Режим работы перезарядки
    TouchCooldown = 0.5,             -- Задержка повторного удара (сек)
    
    OnModelTouched = function(model, hb, part)
        print("Hit registered on: " .. model.Name)            
    end                                                                      
})                                                                           

-- Активация системы
hitbox:Enable()
