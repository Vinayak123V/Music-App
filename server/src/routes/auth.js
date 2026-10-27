const express = require('express');
const fs = require('fs');
const path = require('path');

const router = express.Router();
const usersFilePath = path.join(__dirname, '../data/users.json');

// Ensure users.json exists
function loadUsers() {
  try {
    if (!fs.existsSync(usersFilePath)) {
      fs.writeFileSync(usersFilePath, JSON.stringify([], null, 2), 'utf8');
      return [];
    }
    const data = fs.readFileSync(usersFilePath, 'utf8');
    return JSON.parse(data || '[]');
  } catch (err) {
    console.error('Error reading users.json:', err);
    return [];
  }
}

function saveUsers(users) {
  try {
    fs.writeFileSync(usersFilePath, JSON.stringify(users, null, 2), 'utf8');
  } catch (err) {
    console.error('Error saving users.json:', err);
  }
}

// POST /api/auth/register
router.post('/register', (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ success: false, error: 'Name, email, and password are required' });
  }

  const users = loadUsers();
  const cleanEmail = email.trim().toLowerCase();

  const existing = users.find(u => u.email === cleanEmail);
  if (existing) {
    return res.status(409).json({ success: false, error: 'An account with this email already exists' });
  }

  const newUser = {
    id: `user_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
    name: name.trim(),
    email: cleanEmail,
    password: password, // In production this would be hashed with bcrypt
    isGuest: false,
    createdAt: new Date().toISOString()
  };

  users.push(newUser);
  saveUsers(users);

  const { password: _, ...userSafe } = newUser;
  res.status(201).json({
    success: true,
    message: 'Devotee account registered successfully',
    user: userSafe
  });
});

// POST /api/auth/login
router.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, error: 'Email and password are required' });
  }

  const users = loadUsers();
  const cleanEmail = email.trim().toLowerCase();

  const user = users.find(u => u.email === cleanEmail && u.password === password);
  if (!user) {
    return res.status(401).json({ success: false, error: 'Invalid email or password' });
  }

  const { password: _, ...userSafe } = user;
  res.json({
    success: true,
    message: 'Welcome back!',
    user: userSafe
  });
});

// POST /api/auth/guest
router.post('/guest', (req, res) => {
  const guestUser = {
    id: `guest_${Date.now()}`,
    name: 'Guest Devotee',
    email: null,
    isGuest: true,
    createdAt: new Date().toISOString()
  };

  res.json({
    success: true,
    message: 'Entered as Guest Devotee',
    user: guestUser
  });
});

module.exports = router;
