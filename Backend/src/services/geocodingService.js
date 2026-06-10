const axios = require('axios');

const NOMINATIM_URL = process.env.GEOCODING_API_URL || 'https://nominatim.openstreetmap.org';
let lastRequestTime = 0;

async function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function geocodeAddress(address) {
  try {
    // Enforce 1 second delay between requests (Nominatim rate limit)
    const now = Date.now();
    const elapsed = now - lastRequestTime;
    if (elapsed < 1000) {
      await delay(1000 - elapsed);
    }
    lastRequestTime = Date.now();

    const response = await axios.get(`${NOMINATIM_URL}/search`, {
      params: {
        q: address,
        format: 'json',
        limit: 1
      },
      headers: {
        'User-Agent': 'IAMExpress/1.0'
      }
    });

    if (response.data && response.data.length > 0) {
      return {
        lat: parseFloat(response.data[0].lat),
        lng: parseFloat(response.data[0].lon)
      };
    }
    return null;
  } catch (error) {
    console.error('Geocoding error:', error.message);
    return null;
  }
}

async function geocodePackageAddresses(pool, packageId, alamatPengirim, alamatTujuan) {
  try {
    const senderCoords = await geocodeAddress(alamatPengirim);
    const receiverCoords = await geocodeAddress(alamatTujuan);

    const updates = [];
    const values = [];

    if (senderCoords) {
      updates.push('sender_lat = ?', 'sender_lng = ?');
      values.push(senderCoords.lat, senderCoords.lng);
    }

    if (receiverCoords) {
      updates.push('receiver_lat = ?', 'receiver_lng = ?');
      values.push(receiverCoords.lat, receiverCoords.lng);
    }

    if (updates.length > 0) {
      values.push(packageId);
      await pool.query(
        `UPDATE packages SET ${updates.join(', ')} WHERE package_id = ?`,
        values
      );
    }
  } catch (error) {
    console.error('Geocode package addresses error:', error.message);
  }
}

module.exports = { geocodeAddress, geocodePackageAddresses };
