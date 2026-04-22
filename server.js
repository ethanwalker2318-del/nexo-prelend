const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const { execSync } = require('child_process');

const app = express();
const PORT = 3001;
const analyticsFile = path.join(__dirname, 'analytics.json');
const statsFile = path.join(__dirname, 'STATS.txt');

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Функция для сохранения в GitHub
function pushToGitHub() {
  try {
    process.chdir(__dirname);
    execSync('git add analytics.json', { stdio: 'pipe' });
    execSync('git commit -m "Auto-update analytics"', { stdio: 'pipe' });
    execSync('git push', { stdio: 'pipe' });
    console.log('✅ Данные обновлены на GitHub');
  } catch (error) {
    console.error('⚠️  Не удалось обновить GitHub (git push):', error.message);
    // Это не критичная ошибка - данные все равно сохранены локально
  }
}

// Функция для обновления текстового файла со статистикой
function updateStatsFile() {
  try {
    const data = JSON.parse(fs.readFileSync(analyticsFile, 'utf8'));
    const now = new Date().toLocaleString('ru-RU');
    
    let statsText = `═══════════════════════════════════════════════════════
                    📊 TRUSTEX ANALYTICS
═══════════════════════════════════════════════════════

📱 ПОСЕЩЕНИЯ ПРЕЛЕНДА:  ${data.pageViews}
🔘 КЛИКИ ПО КНОПКЕ:    ${data.buttonClicks}

─────────────────────────────────────────────────────
Последние 20 событий:
─────────────────────────────────────────────────────

`;

    const recentEvents = data.events.slice(-20).reverse();
    recentEvents.forEach((event, idx) => {
      const time = new Date(event.timestamp).toLocaleString('ru-RU');
      const eventName = event.type === 'page_view' ? '👁️  Посещение' : '🔘 Клик';
      statsText += `${idx + 1}. ${eventName} — ${time}\n`;
    });
    
    statsText += `\n═══════════════════════════════════════════════════════
Обновлено: ${now}
═══════════════════════════════════════════════════════`;

    fs.writeFileSync(statsFile, statsText);
  } catch (error) {
    console.error('Ошибка обновления STATS.txt:', error);
  }
}

// Инициализируем файл аналитики если его нет
if (!fs.existsSync(analyticsFile)) {
  fs.writeFileSync(analyticsFile, JSON.stringify({
    pageViews: 0,
    buttonClicks: 0,
    events: []
  }, null, 2));
  updateStatsFile();
}

// Получение текущей аналитики
app.get('/api/analytics', (req, res) => {
  const data = JSON.parse(fs.readFileSync(analyticsFile, 'utf8'));
  res.json(data);
});

// Логирование события
app.post('/api/event', (req, res) => {
  const { eventType, timestamp } = req.body;
  
  console.log(`\n📨 Получено событие: ${eventType}`);
  console.log(`   Origin: ${req.get('origin')}`);
  console.log(`   Время: ${timestamp}`);
  
  try {
    const data = JSON.parse(fs.readFileSync(analyticsFile, 'utf8'));
    
    if (eventType === 'page_view') {
      data.pageViews++;
    } else if (eventType === 'button_click') {
      data.buttonClicks++;
    }
    
    data.events.push({
      type: eventType,
      timestamp: timestamp || new Date().toISOString()
    });
    
    // Держим только последние 1000 событий
    if (data.events.length > 1000) {
      data.events = data.events.slice(-1000);
    }
    
    fs.writeFileSync(analyticsFile, JSON.stringify(data, null, 2));
    
    // Обновляем текстовый файл
    updateStatsFile();
    
    console.log(`✅ Событие сохранено | Views: ${data.pageViews} | Clicks: ${data.buttonClicks}`);
    
    // Пушим на GitHub в фоне (не блокируем ответ)
    setTimeout(() => pushToGitHub(), 100);
    
    res.json({ success: true, data });
  } catch (error) {
    console.error('❌ Ошибка обработки события:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`\n✅ Analytics server running on http://localhost:${PORT}`);
  console.log(`📊 Analytics JSON: ${analyticsFile}`);
  console.log(`📄 Stats TXT:      ${statsFile}`);
  console.log(`📤 GitHub sync:    Enabled\n`);
  updateStatsFile();
});
