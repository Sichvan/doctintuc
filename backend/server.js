require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const newsRoutes = require('./routes/news');
const authRoutes = require('./routes/auth');
const adminRoutes = require('./routes/admin');
const articleRoutes = require('./routes/articles');
const userRoutes = require('./routes/user');

const app = express();
const PORT = process.env.PORT || 5000;

mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ MongoDB Connected'))
  .catch(err => {
    console.error('❌ MongoDB Connection Error:', err.message);
    process.exit(1);
  });
app.use(cors());
app.use(express.json());
app.use('/api/news', newsRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/articles', articleRoutes);
app.use('/api/user', userRoutes);

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'Server OK', message: 'Backend News App running!' });
});
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
