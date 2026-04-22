const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 3001;
const analyticsFile = path.join(__dirname, 'analytics.json');

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Инициализируем файл аналитики если его нет
if (!fs.existsSync(analyticsFile)) {
  fs.writeFileSync(analyticsFile, JSON.stringify({
    pageViews: 0,
    buttonClicks: 0,
    events: []
  }, null, 2));
}

// Получение текущей аналитики
app.get('/api/analytics', (req, res) => {
  const data = JSON.parse(fs.readFileSync(analyticsFile, 'utf8'));
  res.json(data);
});

// Логирование события
app.post('/api/event', (req, res) => {
  const { eventType, timestamp } = req.body;
  
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
  
  console.log(`[${new Date().toISOString()}] Event: ${eventType} | Views: ${data.pageViews} | Clicks: ${data.buttonClicks}`);
  
  res.json({ success: true, data });
});

app.listen(PORT, () => {
  console.log(`\n✅ Analytics server running on http://localhost:${PORT}`);
  console.log(`📊 Analytics file: ${analyticsFile}\n`);
});
