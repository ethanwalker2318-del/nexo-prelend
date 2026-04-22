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

REM Закрываем старые процессы на портах если они есть
echo 🧹 Очистка старых процессов...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001"') do (
    echo   Закрываю процесс %%a...
    taskkill /PID %%a /F >nul 2>&1
)

REM Убиваем node процессы которые уже запущены
taskkill /IM node.exe /F >nul 2>&1

echo ✅ Старые процессы закрыты
echo.

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

REM Очищаем npm кеш на всякий случай
echo 🔄 Проверка целостности npm...
npm cache clean --force >nul 2>&1

REM Даём время на освобождение портов
echo ⏳ Ожидание 2 секунды...
timeout /t 2 /nobreak >nul

REM Запускаем сервер
echo.
echo 🚀 Запуск сервера на http://localhost:3001
echo ⏳ Ожидание инициализации (5 секунд)...
echo.
echo 📊 Analytics данные сохраняются в analytics.json
echo 🔴 Нажмите Ctrl+C для остановки сервера
echo.

REM Запускаем npm start в отдельном окне
start "TrustEx Analytics Server" cmd /k "cd /d %~dp0 && npm start"

REM Даём серверу время на запуск
timeout /t 5 /nobreak >nul

REM Открываем dashboard в браузере
echo 🌐 Открываю dashboard в браузере...
start http://localhost:3001/dashboard.html

echo.
echo ✅ Готово! Смотри браузер.
echo.
pause
