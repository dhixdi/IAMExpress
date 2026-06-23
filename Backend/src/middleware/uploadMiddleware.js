const multer = require('multer');
const path = require('path');
const fs = require('fs');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dest = path.join(__dirname, '..', '..', 'public', 'uploads', 'delivery');
    fs.mkdirSync(dest, { recursive: true });
    cb(null, dest);
  },
  filename: (req, file, cb) => {
    const name = `delivery_${Date.now()}_${Math.round(Math.random() * 1E6)}${path.extname(file.originalname)}`;
    cb(null, name);
  }
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Hanya file gambar (jpg, jpeg, png) yang diizinkan'), false);
  }
};

const limits = { fileSize: 5 * 1024 * 1024 };

const deliveryPhotoUpload = multer({ storage, fileFilter, limits }).single('delivery_photo');

const handleDeliveryUpload = (req, res, next) => {
  deliveryPhotoUpload(req, res, (err) => {
    if (err) {
      return res.status(400).json({ success: false, message: err.message });
    }
    next();
  });
};

module.exports = { handleDeliveryUpload };
