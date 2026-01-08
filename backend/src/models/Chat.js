const mongoose = require('mongoose');

const chatSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  role: {
    type: String,
    required: true,
    enum: ['user', 'ai']
  },
  message: {
    type: String,
    required: true
  },
  created_at: {
    type: Date,
    default: Date.now
  }
});

// Index for efficient querying by user and date
chatSchema.index({ user_id: 1, created_at: -1 });

module.exports = mongoose.model('Chat', chatSchema);
