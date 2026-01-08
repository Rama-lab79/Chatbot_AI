const express = require('express');
const Chat = require('../models/Chat');
const DailyLog = require('../models/DailyLog');
const authMiddleware = require('../middleware/auth');
const { generateAIResponse, generateDailySummary } = require('../services/openrouter');

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

// Get yesterday's date range
function getYesterdayRange() {
  const start = new Date();
  start.setDate(start.getDate() - 1);
  start.setHours(0, 0, 0, 0);
  
  const end = new Date();
  end.setDate(end.getDate() - 1);
  end.setHours(23, 59, 59, 999);
  
  return { start, end };
}

// POST /chat - Send message and get AI response
router.post('/', async (req, res) => {
  try {
    const { message, mode = 'listening' } = req.body;

    // Validation
    if (!message || message.trim() === '') {
      return res.status(400).json({ error: 'Message is required' });
    }

    if (!['listening', 'solution'].includes(mode)) {
      return res.status(400).json({ error: 'Mode must be listening or solution' });
    }

    // Get today's chat history
    const { start, end } = getTodayRange();
    const todayChats = await Chat.find({
      user_id: req.userId,
      created_at: { $gte: start, $lte: end }
    }).sort({ created_at: 1 });

    // Get yesterday's summary for context
    const yesterdayRange = getYesterdayRange();
    const yesterdayLog = await DailyLog.findOne({
      user_id: req.userId,
      created_at: { $gte: yesterdayRange.start, $lte: yesterdayRange.end }
    });

    // Save user message
    const userChat = new Chat({
      user_id: req.userId,
      role: 'user',
      message: message.trim()
    });
    await userChat.save();

    // Generate AI response
    const aiResponseText = await generateAIResponse(
      message,
      mode,
      yesterdayLog?.summary,
      todayChats
    );

    // Save AI response
    const aiChat = new Chat({
      user_id: req.userId,
      role: 'ai',
      message: aiResponseText
    });
    await aiChat.save();

    res.json({
      userMessage: userChat,
      aiResponse: aiChat
    });
  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ error: 'Failed to process message' });
  }
});

// GET /chat/today - Get today's chat history
router.get('/today', async (req, res) => {
  try {
    const { start, end } = getTodayRange();
    
    const chats = await Chat.find({
      user_id: req.userId,
      created_at: { $gte: start, $lte: end }
    }).sort({ created_at: 1 });

    res.json({ chats });
  } catch (error) {
    console.error('Get chats error:', error);
    res.status(500).json({ error: 'Failed to get chats' });
  }
});

// DELETE /chat/today - Delete today's chat history
router.delete('/today', async (req, res) => {
  try {
    const { start, end } = getTodayRange();
    
    await Chat.deleteMany({
      user_id: req.userId,
      created_at: { $gte: start, $lte: end }
    });

    res.json({ message: 'Today\'s chat deleted' });
  } catch (error) {
    console.error('Delete chats error:', error);
    res.status(500).json({ error: 'Failed to delete chats' });
  }
});

// POST /chat/summary - Generate and save daily summary
router.post('/summary', async (req, res) => {
  try {
    const { start, end } = getTodayRange();
    
    // Get today's chats
    const chats = await Chat.find({
      user_id: req.userId,
      created_at: { $gte: start, $lte: end }
    }).sort({ created_at: 1 });

    // Get today's check-in
    const checkin = await DailyLog.findOne({
      user_id: req.userId,
      created_at: { $gte: start, $lte: end }
    });

    if (!checkin) {
      return res.status(404).json({ error: 'No check-in found for today' });
    }

    // Generate summary
    const summary = await generateDailySummary(chats, checkin);

    // Update the daily log with summary
    checkin.summary = summary;
    await checkin.save();

    res.json({
      message: 'Summary generated',
      summary
    });
  } catch (error) {
    console.error('Summary error:', error);
    res.status(500).json({ error: 'Failed to generate summary' });
  }
});

module.exports = router;
