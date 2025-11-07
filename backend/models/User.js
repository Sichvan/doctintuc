// models/User.js
const mongoose = require('mongoose');

// Định nghĩa schema cho một bài viết được lưu/xem
// Chúng ta cache dữ liệu này để tải danh sách nhanh hơn
const articleEntrySchema = new mongoose.Schema({
  articleId: { type: String, required: true }, // Đây là DisplayArticle.id (URL hoặc ObjectId)
  isFromAdmin: { type: Boolean, required: true },
  title: { type: String, required: true },
  imageUrl: { type: String },
  sourceName: { type: String },
  pubDate: { type: Date },
  articleUrl: { type: String }, // Cần cho API news
  adminContent: { type: String }, // Cần cho admin article
}, { _id: false }); // _id: false để không tạo ObjectId cho sub-document này

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  // THÊM 2 TRƯỜNG NÀY:
  savedArticles: {
    type: [articleEntrySchema],
    default: []
  },
  viewHistory: {
    type: [articleEntrySchema], // Sẽ lưu cả 'viewedAt'
    default: []
  }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);