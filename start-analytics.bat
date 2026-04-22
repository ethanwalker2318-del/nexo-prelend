@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════╗
echo ║   TrustEx Analytics - Real-time Dashboard  ║
echo ╚════════════════════════════════════════════╝
echo.

REM Проверяем есть ли Node.js
where node >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js не найден в PATH!
    echo.
    echo 📥 Действия:
    echo 1. Скачайте Node.js с https://nodejs.org/
    echo 2. Установите его
    echo 3. Перезагрузите компьютер
    echo 4. Запустите батник снова
    echo.
    pause
    exit /b 1
)

echo ✅ Node.js найден:
node --version
echo.

REM Переходим в папку проекта
cd /d "%~dp0"
echo 📁 Рабочая папка: %CD%
echo.

REM Скачиваем последние данные с GitHub
echo 📥 Загрузка последних данных с GitHub...
git pull origin main >nul 2>&1
echo ✅ Данные загружены
echo.

REM Проверяем есть ли node_modules
if not exist "node_modules" (
    echo 📦 Установка npm зависимостей...
    call npm install
    if errorlevel 1 (
        echo ❌ Ошибка при установке!
        echo.
        echo Попробуйте вручную запустить:
        echo   npm install
        echo.
        pause
        exit /b 1
    )
    echo ✅ Зависимости установлены
    echo.
)

REM Закрываем старые Node процессы
echo 🧹 Закрытие старых процессов Node.js...
taskkill /IM node.exe /F >nul 2>&1

REM Небольшая задержка
timeout /t 2 /nobreak >nul

REM Запускаем сервер
echo 🚀 Запуск сервера...
echo.

REM Запускаем в отдельном окне
start "TrustEx Server" cmd /k "cd /d %~dp0 && node server.js"

REM Ждем инициализации
timeout /t 4 /nobreak >nul

REM Открываем браузер
echo 🌐 Открытие браузера...
echo 📱 Prelend page: http://localhost:3001/index.html
echo 📊 Analytics:   http://localhost:3001/dashboard.html
echo.
start http://localhost:3001/index.html

REM Также открываем дашборд в новой табе
timeout /t 1 /nobreak >nul
start http://localhost:3001/dashboard.html

echo.
echo ✅ Сервер запущен на http://localhost:3001
echo 📊 Дашборд откроется в браузере
echo.
pause
