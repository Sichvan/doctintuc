// backend/routes/user.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');

router.post('/save', auth, async (req, res) => {
  try {
    // SỬA: Lấy thêm "category" từ req.body
    const { articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent, category } = req.body;

    // SỬA: Thêm "category" vào object để lưu
    const articleEntry = {
      articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent, category
    };

    const user = await User.findById(req.user.id);
    const isAlreadySaved = user.savedArticles.some(article => article.articleId === articleId);
    if (isAlreadySaved) {
      return res.status(400).json({ msg: 'Bài viết đã được lưu' });
    }
    user.savedArticles.unshift(articleEntry);
    await user.save();

    res.json(user.savedArticles);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

router.post('/unsave', auth, async (req, res) => {
  try {
    const { articleId } = req.body;

    await User.findByIdAndUpdate(req.user.id, {
      $pull: { savedArticles: { articleId: articleId } }
    }, { new: true });

    res.json({ msg: 'Đã bỏ lưu bài viết' });

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

router.get('/saved', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('savedArticles');
    res.json(user.savedArticles);
  } catch (err)
    {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

router.post('/history', auth, async (req, res) => {
  try {
    // SỬA: Lấy thêm "category" từ req.body
    const { articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent, category } = req.body;

    // SỬA: Thêm "category" vào object
    const historyEntry = {
      articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent, category,
      viewedAt: new Date()
    };

    await User.findByIdAndUpdate(req.user.id, {
      $pull: { viewHistory: { articleId: articleId } }
    });

    const user = await User.findByIdAndUpdate(req.user.id, {
      $push: { viewHistory: { $each: [historyEntry], $position: 0 } }
    }, { new: true }).select('viewHistory');

    res.json(user.viewHistory);

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});


router.get('/history', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('viewHistory');
    res.json(user.viewHistory);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;