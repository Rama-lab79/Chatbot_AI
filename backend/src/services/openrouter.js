const OPENROUTER_BASE_URL = process.env.OPENROUTER_BASE_URL || 'https://openrouter.ai/api/v1';

/**
 * Generate AI response using OpenRouter API
 * @param {string} userMessage - User's message
 * @param {string} mode - Chat mode: 'listening' or 'solution'
 * @param {string|null} yesterdaySummary - Previous day's summary for context
 * @param {Array} chatHistory - Today's chat history
 * @returns {Promise<string>} AI response
 */
async function generateAIResponse(userMessage, mode, yesterdaySummary, chatHistory = []) {
  const systemPrompt = buildSystemPrompt(mode, yesterdaySummary);
  
  const messages = [
    { role: 'system', content: systemPrompt },
    ...chatHistory.map(chat => ({
      role: chat.role === 'ai' ? 'assistant' : 'user',
      content: chat.message
    })),
    { role: 'user', content: userMessage }
  ];

  try {
    const response = await fetch(`${OPENROUTER_BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'http://localhost:3000',
        'X-Title': 'Mental Health Assistant'
      },
      body: JSON.stringify({
        model: 'openai/gpt-3.5-turbo',
        messages: messages,
        max_tokens: 200,
        temperature: 0.7
      })
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenRouter API error: ${error}`);
    }

    const data = await response.json();
    return data.choices[0].message.content;
  } catch (error) {
    console.error('OpenRouter API error:', error);
    throw error;
  }
}

/**
 * Build system prompt based on mode
 */
function buildSystemPrompt(mode, yesterdaySummary) {
  let basePrompt = `You are a compassionate mental health companion. You are NOT a therapist or doctor. Never diagnose conditions or prescribe treatments.

IMPORTANT DISCLAIMER: This is for emotional support only, not professional mental health advice. If the user is in crisis, encourage them to contact emergency services or a crisis helpline.

Keep responses short (2-3 sentences max). Be warm, empathetic, and supportive.`;

  if (mode === 'listening') {
    basePrompt += `

MODE: LISTENING
- Only listen and validate feelings
- Do NOT give advice or solutions
- Reflect back what the user is feeling
- Use phrases like "I hear you", "That sounds difficult", "It's okay to feel this way"`;
  } else if (mode === 'solution') {
    basePrompt += `

MODE: SOLUTION
- After acknowledging feelings, suggest ONE small, actionable step
- Keep the suggestion simple and achievable
- Example: "Have you tried taking 3 deep breaths?" or "Maybe a 5-minute walk could help"`;
  }

  if (yesterdaySummary) {
    basePrompt += `

CONTEXT FROM YESTERDAY:
${yesterdaySummary}`;
  }

  return basePrompt;
}

/**
 * Generate daily summary from chat history
 * @param {Array} chats - Today's chat messages
 * @param {Object} checkin - Today's check-in data
 * @returns {Promise<string>} Summary text
 */
async function generateDailySummary(chats, checkin) {
  const chatContent = chats.map(c => `${c.role}: ${c.message}`).join('\n');
  
  const prompt = `Summarize this user's day in 2-3 sentences. Focus on their emotional state and any key concerns.

Check-in data:
- Mood: ${checkin?.mood || 'not recorded'}/5
- Energy: ${checkin?.energy || 'not recorded'}
- Slept well: ${checkin?.sleep ? 'yes' : 'no'}

Chat history:
${chatContent || 'No chats today'}

Write a brief, third-person summary:`;

  try {
    const response = await fetch(`${OPENROUTER_BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'http://localhost:3000',
        'X-Title': 'Mental Health Assistant'
      },
      body: JSON.stringify({
        model: 'openai/gpt-3.5-turbo',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 150,
        temperature: 0.5
      })
    });

    if (!response.ok) {
      throw new Error('Failed to generate summary');
    }

    const data = await response.json();
    return data.choices[0].message.content;
  } catch (error) {
    console.error('Summary generation error:', error);
    return null;
  }
}

module.exports = {
  generateAIResponse,
  generateDailySummary
};
