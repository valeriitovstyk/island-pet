# Острівний персонаж (IslandPet)

IslandPet — україномовний персонаж, який живе в Live Activity на екрані блокування та в StandBy. Його можна годувати, розважати й вкладати спати прямо з картки; кнопка дії або «Торкання ззаду» можуть запускати команду «Погладити персонажа». Стан повільно змінюється з часом без сервера й фонових завдань.

На iPhone 16e персонаж відображається на екрані блокування, **не біля камери**: ця модель має виріз без Dynamic Island. На моделях із Dynamic Island є також компактне й розгорнуте відображення.

## Важливе про безкоштовний Apple ID

Платна програма Apple Developer не потрібна. Apple обмежує Personal Team трьома встановленими застосунками на пристрої; їхні профілі діють 7 днів. IslandPet має два ідентифікатори застосунку (основний застосунок і віджет), а SideStore теж займає місце серед трьох застосунків. Щоб продовжити роботу через 7 днів, застосунок потрібно повторно підписати. [Правила Apple](https://developer.apple.com/help/account/basics/about-your-developer-account).

## Спосіб А: встановлення через Xcode

1. Установіть актуальний Xcode з Mac App Store. Відкрийте Xcode → Settings → Accounts і увійдіть у свій Apple ID. Xcode покаже **Personal Team**.
2. Клонуйте репозиторій: `git clone https://github.com/valeriitovstyk/island-pet.git`.
3. У терміналі встановіть XcodeGen: `brew install xcodegen`. У папці репозиторію виконайте `xcodegen generate`.
4. Відкрийте `IslandPet.xcodeproj`. У Build Settings змініть `BUNDLE_ID_PREFIX` з `com.example` на власний унікальний префікс, наприклад `com.myname`. Зробіть це **лише в локальному згенерованому проєкті**, який Git ігнорує.
5. У Signing & Capabilities для **IslandPet** і **IslandPetWidget** виберіть свою Personal Team та увімкніть Automatically manage signing. `DEVELOPMENT_TEAM` у `project.yml` навмисно порожній.
6. Підключіть iPhone кабелем, довірте Mac і виберіть телефон як ціль у Xcode. На iPhone увімкніть Параметри → Конфіденційність і безпека → Режим розробника.
7. Натисніть **Run**. Якщо iPhone попросить довірити розробника, відкрийте Параметри → Загальні → VPN і керування пристроями та підтвердьте довіру.
8. Через 7 днів знову підключіть iPhone і натисніть **Run**.

Якщо Personal Team не дозволяє App Group, вилучіть capability **App Groups** в обох таргетах у локальному Xcode-проєкті та спробуйте знову. Застосунок у такому разі не падає й використовує звичайний `UserDefaults`; стан між процесами може не синхронізуватися. Не комітьте локальні зміни підпису.

## Спосіб Б: встановлення через SideStore

1. Налаштуйте SideStore за [офіційною інструкцією](https://docs.sidestore.io/docs/installation/install), включно з LocalDevVPN і підписом власним Apple ID. Файли сполучення iPhone зберігайте лише локально.
2. У SideStore відкрийте пряме [посилання на IslandPet.ipa](https://github.com/valeriitovstyk/island-pet/releases/download/latest/IslandPet.ipa) або завантажте файл зі сторінки [Release latest](https://github.com/valeriitovstyk/island-pet/releases/tag/latest) та імпортуйте його. Файл у Release **непідписаний**; SideStore підпише його на пристрої.
3. У SideStore оновлюйте підпис IslandPet щонайменше раз на 7 днів (кнопка з лічильником днів на вкладці My Apps). Для оновлення версії повторно встановіть новий IPA з того самого Release. Під час встановлення й оновлення SideStore потребує LocalDevVPN. [Довідка SideStore](https://docs.sidestore.io/docs/faq).

## Налаштування iPhone

- Live Activities: Параметри → IslandPet → Live Activities. Після цього відкрийте IslandPet і натисніть «Показати на екрані блокування». Активність має обмежений час життя; коли застосунок відкривається, він відновлює її, якщо ввімкнено «Автоматично перезапускати».
- Кнопка дії iPhone 16e: Параметри → Кнопка дії → Команда → «Погладити персонажа». Ту саму команду можна призначити для «Торкання ззаду» через Параметри → Доступність → Дотик.
- Натискання картки Live Activity відкриває застосунок із розгорнутою капсулою.

## Якщо підпис не вдається

- **Bundle ID зайнятий:** виберіть інший унікальний `BUNDLE_ID_PREFIX` у локальних Build Settings і повторіть збірку.
- **App Group недоступна:** вилучіть capability App Groups у локальних налаштуваннях обох таргетів; застосунок працюватиме з запасним локальним сховищем.
- **Untrusted Developer:** підтвердьте довіру в Параметри → Загальні → VPN і керування пристроями.
- **Досягнуто ліміту App ID або застосунків:** у Personal Team є обмеження на кількість ID і встановлених застосунків. Видаліть непотрібні тестові застосунки або дочекайтеся закінчення строку їхніх ID; потім повторіть підпис. [Обмеження Apple](https://developer.apple.com/help/account/basics/about-your-developer-account).

## Розробка й безпека

Проєкт генерується з `project.yml` через XcodeGen. Ціль — iOS 18.0; код Swift збирається компілятором Xcode зі Swift 5 language mode та `SWIFT_STRICT_CONCURRENCY=minimal`, щоб обробники App Intents і ActivityKit не вимагали повної міграції на Swift 6 isolation. У застосунку немає сторонніх бібліотек, серверних push-оновлень або платних сервісів Apple. GitHub Actions збирає непідписаний IPA і публікує його в Release latest.

Репозиторій **публічний**. Ніколи не комітьте Apple ID, email, паролі, Team ID, токени, сертифікати, ключі, профілі підпису чи файли сполучення iPhone. Власний `BUNDLE_ID_PREFIX` і Personal Team змінюйте лише у згенерованому `IslandPet.xcodeproj`, який зазначений у `.gitignore`. Перед кожним комітом виконуйте `git status` і `git diff --cached` та перевіряйте вміст. Якщо редагували `project.yml` для локального підпису, поверніть його до стану репозиторію перед комітом.
