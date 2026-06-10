const axios = require('axios');

const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;
let lastRequestTime = 0;

async function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function geocodeAddress(address) {
  try {
    // Google tidak perlu rate limit seketat Nominatim,
    // tapi tetap kasih jeda kecil biar aman
    const now = Date.now();
    const elapsed = now - lastRequestTime;
    if (elapsed < 200) await delay(200 - elapsed);
    lastRequestTime = Date.now();

    const response = await axios.get(
      'https://maps.googleapis.com/maps/api/geocode/json',
      {
        params: {
          address: address,
          key: GOOGLE_MAPS_API_KEY,
          region: 'id',        // bias ke Indonesia
          language: 'id',
        }
      }
    );

    if (
      response.data.status === 'OK' &&
      response.data.results.length > 0
    ) {
      const loc = response.data.results[0].geometry.location;
      return {
        lat: loc.lat,
        lng: loc.lng
      };
    }

    console.warn('Geocode tidak menemukan hasil untuk:', address, '| Status:', response.data.status);
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