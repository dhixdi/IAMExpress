const RATES = { standar: 10000, express: 15000, kargo: 5000 };
const KARGO_MIN_WEIGHT = 10;

function calculateShippingCost(berat, jenisLayanan) {
  if (jenisLayanan === 'kargo' && berat < KARGO_MIN_WEIGHT) {
    throw new Error(`Layanan kargo minimal ${KARGO_MIN_WEIGHT} kg`);
  }
  const rate = RATES[jenisLayanan];
  if (!rate) throw new Error('Jenis layanan tidak valid');
  return berat * rate;
}

module.exports = { calculateShippingCost };
