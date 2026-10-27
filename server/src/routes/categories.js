const express = require('express');
const db = require('../config/db');

const router = express.Router();

router.get('/', (req, res) => {
  res.json({
    success: true,
    data: db.getCategories(),
  });
});

module.exports = router;
