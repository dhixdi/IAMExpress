const axios = require('axios');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent`;

async function chatWithGemini(message, context = {}) {
  try {
    if (!GEMINI_API_KEY) {
      return 'Gemini API key belum dikonfigurasi. Silakan hubungi administrator.';
    }

    const systemInstruction = `Kamu adalah asisten logistik IAMExpress yang membantu pengguna dengan pertanyaan seputar pengiriman paket, tracking, dan manajemen gudang. Jawab dengan bahasa Indonesia yang ramah dan profesional.

Konteks pengguna saat ini:
- Role: ${context.role || 'Unknown'}
- Warehouse: ${context.warehouse_name || 'Tidak ada'}
- Warehouse ID: ${context.warehouse_id || 'Tidak ada'}`;

    const requestBody = {
      system_instruction: {
        parts: [{ text: systemInstruction }]
      },
      contents: [
        {
          parts: [{ text: message }]
        }
      ]
    };

    const response = await axios.post(
      `${GEMINI_URL}?key=${GEMINI_API_KEY}`,
      requestBody,
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    if (
      response.data &&
      response.data.candidates &&
      response.data.candidates[0] &&
      response.data.candidates[0].content &&
      response.data.candidates[0].content.parts &&
      response.data.candidates[0].content.parts[0]
    ) {
      return response.data.candidates[0].content.parts[0].text;
    }

    return 'Maaf, tidak dapat memproses permintaan saat ini. Silakan coba lagi.';
  } catch (error) {
    console.error('Gemini API error:', error.message);
    return 'Maaf, terjadi kesalahan saat menghubungi AI. Silakan coba lagi nanti.';
  }
}

module.exports = { chatWithGemini };
