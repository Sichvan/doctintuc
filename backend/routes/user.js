const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');

router.post('/save', auth, async (req, res) => {
  try {
    const { articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent } = req.body;
    const articleEntry = {
      articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent
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
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});
router.post('/history', auth, async (req, res) => {
  try {
    const { articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent } = req.body;
    const historyEntry = {
      articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent,
      viewedAt: new Date()
    };

    await User.findByIdAndUpdate(req.user.id, {
      $pull: { viewHistory: { articleId: articleId } }
    });

    // 2. Thêm bài viết vào đầu danh sách lịch sử
    const user = await User.findByIdAndUpdate(req.user.id, {
      $push: { viewHistory: { $each: [historyEntry], $position: 0 } } // Thêm vào vị trí 0
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