const mongoose = require('mongoose');

const dailyLogSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  mood: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  energy: {
    type: String,
    required: true,
    enum: ['low', 'mid', 'high']
  },
  sleep: {
    type: Boolean,
    required: true
  },
  summary: {
    type: String,
    default: null
  },
  created_at: {
    type: Date,
    default: Date.now
  }
});

// Index for efficient querying by user and date
dailyLogSchema.index({ user_id: 1, created_at: -1 });

module.exports = mongoose.model('DailyLog', dailyLogSchema);
