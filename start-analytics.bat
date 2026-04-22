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
echo.

REM Переходим в папку проекта
cd /d "%~dp0"

REM Проверяем есть ли node_modules
if not exist "node_modules\" (
    echo 📦 Установка зависимостей...
    call npm install
    if errorlevel 1 (
        echo ❌ Ошибка при установке зависимостей
        pause
        exit /b 1
    )
    echo ✅ Зависимости установлены
    echo.
)

REM Открываем dashboard в браузере
echo 🌐 Открываю dashboard в браузере...
timeout /t 2 /nobreak >nul
start http://localhost:3000/dashboard.html

REM Запускаем сервер
echo.
echo 🚀 Запуск сервера на http://localhost:3000
echo.
echo 📊 Analytics данные сохраняются в analytics.json
echo 🔴 Нажмите Ctrl+C для остановки сервера
echo.

call npm start
