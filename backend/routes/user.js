// routes/user.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');

// --- LƯU BÀI VIẾT (BOOKMARK) ---

// POST /api/user/save
// Lưu một bài viết
router.post('/save', auth, async (req, res) => {
  try {
    const { articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent } = req.body;

    // Dữ liệu cache của bài viết
    const articleEntry = {
      articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent
    };

    const user = await User.findById(req.user.id);

    // Kiểm tra xem đã lưu chưa
    const isAlreadySaved = user.savedArticles.some(article => article.articleId === articleId);
    if (isAlreadySaved) {
      return res.status(400).json({ msg: 'Bài viết đã được lưu' });
    }

    // Thêm vào đầu danh sách (dùng unshift và save)
    user.savedArticles.unshift(articleEntry);
    await user.save();

    res.json(user.savedArticles);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// POST /api/user/unsave
// Bỏ lưu một bài viết
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

// GET /api/user/saved
// Lấy danh sách tất cả bài viết đã lưu
router.get('/saved', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('savedArticles');
    res.json(user.savedArticles);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// --- LỊCH SỬ XEM ---

// POST /api/user/history
// Thêm một bài viết vào lịch sử
router.post('/history', auth, async (req, res) => {
  try {
    const { articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent } = req.body;

    // Dữ liệu cache của bài viết, thêm viewedAt
    const historyEntry = {
      articleId, isFromAdmin, title, imageUrl, sourceName, pubDate, articleUrl, adminContent,
      viewedAt: new Date() // Thêm trường này
    };

    // 1. Xóa bài viết này nếu đã có trong lịch sử (để đưa lên đầu)
    await User.findByIdAndUpdate(req.user.id, {
      $pull: { viewHistory: { articleId: articleId } }
    });

    // 2. Thêm bài viết vào đầu danh sách lịch sử
    const user = await User.findByIdAndUpdate(req.user.id, {
      $push: { viewHistory: { $each: [historyEntry], $position: 0 } } // Thêm vào vị trí 0
    }, { new: true }).select('viewHistory');

    // Cân nhắc: Giới hạn số lượng lịch sử (ví dụ: 100 bài)
    // await User.findByIdAndUpdate(req.user.id, {
    //   $push: { viewHistory: { $each: [historyEntry], $position: 0, $slice: 100 } }
    // });

    res.json(user.viewHistory);

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// GET /api/user/history
// Lấy danh sách lịch sử xem
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