const express = require('express');
const router = express.Router();
const User = require('../models/User'); // CHỈ KHAI BÁO 1 LẦN Ở ĐÂY
const auth = require('../middleware/auth'); // CHỈ KHAI BÁO 1 LẦN Ở ĐÂY
const adminAuth = require('../middleware/adminAuth'); // CHỈ KHAI BÁO 1 LẦN Ở ĐÂY
const mongoose = require('mongoose'); // <-- THÊM DÒNG NÀY

// === Route: LẤY THỐNG KÊ USER ===
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

// === Route: LẤY TẤT CẢ USERS ===
router.get('/users', [auth, adminAuth], async (req, res) => {
  try {
    const users = await User.find({ role: { $ne: 'admin' } }).select('-password');
    res.json(users);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// === Route: XÓA USER ===
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

// === Route: LẤY THỐNG KÊ THỂ LOẠI (TOÀN ỨNG DỤNG) ===
// SỬA: Thêm { $match: { role: { $ne: 'admin' } } } để loại trừ Admin
router.get('/category-stats', [auth, adminAuth], async (req, res) => {
  try {
    // 1. Thống kê Lượt xem (viewHistory)
    const viewStats = await User.aggregate([
      { $match: { role: { $ne: 'admin' } } }, // <-- SỬA: LỌC BỎ ADMIN
      { $unwind: '$viewHistory' }, // Tách mảng viewHistory
      { $match: { 'viewHistory.category': { $ne: null } } }, // Bỏ qua nếu category bị null
      { $group: { _id: '$viewHistory.category', count: { $sum: 1 } } }, // Nhóm theo category
      { $project: { category: '$_id', count: 1, _id: 0 } }, // Định dạng lại output
      { $sort: { count: -1 } }, // Sắp xếp
    ]);

    // 2. Thống kê Lượt lưu (savedArticles)
    const saveStats = await User.aggregate([
      { $match: { role: { $ne: 'admin' } } }, // <-- SỬA: LỌC BỎ ADMIN
      { $unwind: '$savedArticles' }, // Tách mảng savedArticles
      { $match: { 'savedArticles.category': { $ne: null } } },
      { $group: { _id: '$savedArticles.category', count: { $sum: 1 } } },
      { $project: { category: '$_id', count: 1, _id: 0 } },
      { $sort: { count: -1 } },
    ]);

    res.json({ viewStats, saveStats });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// === ROUTE MỚI: LẤY THỐNG KÊ THỂ LOẠI CỦA 1 USER ===
router.get('/user-category-stats/:id', [auth, adminAuth], async (req, res) => {
  try {
    const userId = req.params.id;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ msg: 'ID người dùng không hợp lệ' });
    }

    // 1. Thống kê Lượt xem (viewHistory) của user này
    const viewStats = await User.aggregate([
      { $match: { _id: new mongoose.Types.ObjectId(userId) } }, // <-- Match user ID
      { $unwind: '$viewHistory' },
      { $match: { 'viewHistory.category': { $ne: null } } },
      { $group: { _id: '$viewHistory.category', count: { $sum: 1 } } },
      { $project: { category: '$_id', count: 1, _id: 0 } },
      { $sort: { count: -1 } },
    ]);

    // 2. Thống kê Lượt lưu (savedArticles) của user này
    const saveStats = await User.aggregate([
      { $match: { _id: new mongoose.Types.ObjectId(userId) } }, // <-- Match user ID
      { $unwind: '$savedArticles' },
      { $match: { 'savedArticles.category': { $ne: null } } },
      { $group: { _id: '$savedArticles.category', count: { $sum: 1 } } },
      { $project: { category: '$_id', count: 1, _id: 0 } },
      { $sort: { count: -1 } },
    ]);

    res.json({ viewStats, saveStats });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;