const express = require('express');
const cors = require('cors');
require('dotenv').config();
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'B.U.D.D.Y backend is running!' });
});

// Image generation endpoint
app.post('/api/generate-image', async (req, res) => {
  const { prompt } = req.body;
  if (!prompt) {
    return res.status(400).json({ error: 'Prompt is required' });
  }

  try {
    // Prepare form data for Hugging Face Space API
    const FormData = require('form-data');
    const form = new FormData();
    form.append('data', prompt);

    // Call your Hugging Face Space API
    const response = await axios.post(
      'https://huggingface.co/spaces/ChiefMaybe/BUDDY-SD/api/predict/',
      form,
      { headers: form.getHeaders(), responseType: 'arraybuffer' }
    );

    // Return the image buffer as a PNG
    res.set('Content-Type', 'image/png');
    res.send(response.data);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Image generation failed' });
  }
});

app.listen(PORT, () => {
  console.log(`B.U.D.D.Y backend listening on port ${PORT}`);
}); 