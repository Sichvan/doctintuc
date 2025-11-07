const express = require('express');
const router = express.Router();
const Article = require('../models/Article');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');
const { check, validationResult } = require('express-validator');

router.get('/public', async (req, res) => {
  try {
    const { category, language } = req.query;
    const filter = {};
    if (category) {
      filter.category = category;
    }
    if (language) {
      filter.language = language;
    }

    const articles = await Article.find(filter)
      .populate('author', ['email'])
      .sort({ createdAt: -1 });

    res.json(articles);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

router.post(
  '/',
  [
    auth,
    adminAuth,
    [
      check('title', 'Tiêu đề không được để trống').not().isEmpty(),
      check('content', 'Nội dung không được để trống').not().isEmpty(),
      check('language', 'Ngôn ngữ không hợp lệ').isIn(['vi', 'en']),
      check('category', 'Thể loại không hợp lệ').not().isEmpty(),
    ],
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, content, imageUrl, language, category } = req.body;

    try {
      const newArticle = new Article({
        title,
        content,
        imageUrl,
        language,
        category,
        author: req.user.id,
      });

      const article = await newArticle.save();
      const populatedArticle = await Article.findById(article._id).populate('author', ['email']);
      res.status(201).json(populatedArticle); // Trả về bài viết đã populate

    } catch (err) {
      console.error(err.message);
      res.status(500).send('Server Error');
    }
  }
);

router.get('/', [auth, adminAuth], async (req, res) => {
  try {
    const articles = await Article.find()
      .populate('author', ['email'])
      .sort({ createdAt: -1 });
    res.json(articles);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

router.put('/:id', [auth, adminAuth], async (req, res) => {
  const { title, content, imageUrl, language, category } = req.body;

  const articleFields = {};
  if (title) articleFields.title = title;
  if (content) articleFields.content = content;
  if (imageUrl) articleFields.imageUrl = imageUrl;
  if (language) articleFields.language = language;
  if (category) articleFields.category = category;

  try {
    let article = await Article.findById(req.params.id);
    if (!article) {
      return res.status(404).json({ msg: 'Không tìm thấy bài viết' });
    }

    article = await Article.findByIdAndUpdate(
      req.params.id,
      { $set: articleFields },
      { new: true }
    ).populate('author', ['email']); // Populate cả khi update

    res.json(article);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

router.delete('/:id', [auth, adminAuth], async (req, res) => {
  try {
    let article = await Article.findById(req.params.id);
    if (!article) {
      return res.status(404).json({ msg: 'Không tìm thấy bài viết' });
    }

    await Article.findByIdAndDelete(req.params.id);

    res.json({ msg: 'Đã xóa bài viết' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;

