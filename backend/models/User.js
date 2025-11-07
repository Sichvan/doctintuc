const mongoose = require('mongoose');
const articleEntrySchema = new mongoose.Schema({
  articleId: { type: String, required: true },
  isFromAdmin: { type: Boolean, required: true },
  title: { type: String, required: true },
  imageUrl: { type: String },
  sourceName: { type: String },
  pubDate: { type: Date },
  articleUrl: { type: String },
  adminContent: { type: String },
}, { _id: false });

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  savedArticles: {
    type: [articleEntrySchema],
    default: []
  },
  viewHistory: {
    type: [articleEntrySchema],
    default: []
  }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);