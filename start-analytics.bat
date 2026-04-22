@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════╗
echo ║   TrustEx Analytics - Real-time Dashboard  ║
echo ╚════════════════════════════════════════════╝
echo.

REM Проверяем есть ли Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js не установлен!
    echo 📥 Скачайте: https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ Node.js найден
node --version
echo.

REM Переходим в папку проекта
cd /d "%~dp0"

REM Проверяем есть ли node_modules
if not exist "node_modules\" (
    echo 📦 Установка зависимостей...
    call npm install --legacy-peer-deps
    if errorlevel 1 (
        echo ❌ Ошибка при установке зависимостей
        echo Попробуйте запустить в PowerShell:
        echo npm install --legacy-peer-deps
        pause
        exit /b 1
    )
    echo ✅ Зависимости установлены
    echo.
)

REM Проверяем порт 3001
echo 🔍 Проверяю порт 3001...
netstat -ano | findstr ":3001" >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  Порт 3001 уже занят!
    echo Закройте приложение на этом порту и запустите батник снова
    pause
    exit /b 1
)

REM Запускаем сервер
echo 🚀 Запуск сервера на http://localhost:3001
echo ⏳ Ожидание инициализации (5 секунд)...
echo.
echo 📊 Analytics данные сохраняются в analytics.json
echo 🔴 Нажмите Ctrl+C для остановки сервера
echo.

REM Запускаем npm start в фоне и даём время на инициализацию
start cmd /k "npm start"
timeout /t 5 /nobreak

REM Открываем dashboard в браузере
echo 🌐 Открываю dashboard в браузере...
start http://localhost:3001/dashboard.html

echo ✅ Готово! Смотри браузер.
echo.
pause
