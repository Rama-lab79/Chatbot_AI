const express = require('express');
const DailyLog = require('../models/DailyLog');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// Get start and end of today
function getTodayRange() {
  const start = new Date();
  start.setHours(0, 0, 0, 0);
  
  const end = new Date();
  end.setHours(23, 59, 59, 999);
  
  return { start, end };
}

// POST /checkin - Create daily check-in
router.post('/', async (req, res) => {
  try {
    const { mood, energy, sleep } = req.body;

    // Validation
    if (mood === undefined || !energy || sleep === undefined) {
      return res.status(400).json({ error: 'All fields are required (mood, energy, sleep)' });
    }

    if (mood < 1 || mood > 5) {
      return res.status(400).json({ error: 'Mood must be between 1 and 5' });
    }

    if (!['low', 'mid', 'high'].includes(energy)) {
      return res.status(400).json({ error: 'Energy must be low, mid, or high' });
    }

    // Check if already checked in today
    const { start, end } = getTodayRange();
    const existingCheckin = await DailyLog.findOne({
      user_id: req.userId,
      created_at: { $gte: start, $lte: end }
    });

    if (existingCheckin) {
      // Update existing check-in
      existingCheckin.mood = mood;
      existingCheckin.energy = energy;
      existingCheckin.sleep = sleep;
      await existingCheckin.save();

      return res.json({
        message: 'Check-in updated',
        checkin: existingCheckin
      });
    }

    // Create new check-in
    const checkin = new DailyLog({
      user_id: req.userId,
      mood,
      energy,
      sleep: Boolean(sleep)
    });
    await checkin.save();

    res.status(201).json({
      message: 'Check-in recorded',
      checkin
    });
  } catch (error) {
    console.error('Check-in error:', error);
    res.status(500).json({ error: 'Failed to record check-in' });
  }
});

// GET /checkin/last - Get last check-in
router.get('/last', async (req, res) => {
  try {
    const checkin = await DailyLog.findOne({ user_id: req.userId })
      .sort({ created_at: -1 });

    if (!checkin) {
      return res.status(404).json({ error: 'No check-in found' });
    }

    res.json({ checkin });
  } catch (error) {
    console.error('Get check-in error:', error);
    res.status(500).json({ error: 'Failed to get check-in' });
  }
});

// GET /checkin/today - Get today's check-in
router.get('/today', async (req, res) => {
  try {
    const { start, end } = getTodayRange();
    
    const checkin = await DailyLog.findOne({
      user_id: req.userId,
      created_at: { $gte: start, $lte: end }
    });

    if (!checkin) {
      return res.status(404).json({ error: 'No check-in today' });
    }

    res.json({ checkin });
  } catch (error) {
    console.error('Get today check-in error:', error);
    res.status(500).json({ error: 'Failed to get check-in' });
  }
});

module.exports = router;
