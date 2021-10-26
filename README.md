# PaymentsList
 Test SwiftUI/Conbain
 
Задача:

Сделать приложение с возможностью авторизации пользователя и вывода списка его платежей после успешной авторизации. Сделанный проект надо выгрузить в репозиторий на Github. Оценивается как выполнение указанных требований, так и качество проработки отдельных деталей.

Требования к функционалу:
- если логин/пароль неправильные - выводим ошибку
- надо предусмотреть возможность logout'а
- корректный вывод списка платежей при ошибочных данных (пропущенные поля, несоответствие типу)

Требования к коду:
- язык программирования Swift
- простая архитектура и логика

API:

Базовый URL http://82.202.204.94/api-test/, в заголовках надо передавать app-key=12345 и v=1

POST /login - логин, передаем параметры в form-data (login=demo, password=12345), при корректном запросе в ответ приходит токен.

GET /payments - список платежей, для запроса передаем ранее полученный токен в формате token=...

В ходе выполнения пришлось разбираться с возвращаемым JSON, по некоторым ключам в записи отсутствовали поля, по одному ключу значения были в разных форматах (Double/String)
 
