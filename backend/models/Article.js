const mongoose = require('mongoose');
const categoryKeys = [
  'top', 'politics', 'world', 'business', 'science', 'entertainment',
  'sports', 'crime', 'education', 'health', 'other', 'technology'
];

const articleSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true },
  imageUrl: { type: String },
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  language: {
    type: String,
    enum: ['vi', 'en'],
    required: true,
  },
  category: {
    type: String,
    enum: categoryKeys,
    required: true,
  },
  sourceName: {
    type: String,
    default: 'Tin tức Admin'
  }
}, { timestamps: true });

module.exports = mongoose.model('Article', articleSchema);
