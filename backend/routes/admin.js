// routes/admin.js
const express = require('express');
const router = express.Router();
const User = require('../models/User');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');

// === HÀM MỚI: LẤY THỐNG KÊ USER ===
router.get('/user-stats', [auth, adminAuth], async (req, res) => {
  try {
    // 1. Tính ngày cách đây 3 ngày
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    threeDaysAgo.setHours(0, 0, 0, 0); // Đặt về 00:00:00

    // 2. Query song song
    const [totalUsers, newUsersLast3Days] = await Promise.all([
      // Đếm tổng số user (không phải admin)
      User.countDocuments({ role: { $ne: 'admin' } }),
      // Đếm user mới trong 3 ngày qua
      User.countDocuments({
        role: { $ne: 'admin' },
        createdAt: { $gte: threeDaysAgo },
      }),
    ]);

    // 3. Trả về kết quả
    res.json({ totalUsers, newUsersLast3Days });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// === CÁC HÀM CŨ ===
router.get('/users', [auth, adminAuth], async (req, res) => {
  try {
    const users = await User.find({ role: { $ne: 'admin' } }).select('-password');
    res.json(users);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

router.delete('/users/:id', [auth, adminAuth], async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ msg: 'Không tìm thấy người dùng' });
    }
    if (user.role === 'admin') {
      return res.status(400).json({ msg: 'Không thể xóa tài khoản Admin' });
    }

    await User.findByIdAndDelete(req.params.id);

    res.json({ msg: 'Đã xóa người dùng' });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Không tìm thấy người dùng' });
    }
    res.status(500).send('Server Error');
  }
});

module.exports = router;