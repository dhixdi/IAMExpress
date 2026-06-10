function generateResi(packageId) {
  return 'IAM' + String(packageId).padStart(6, '0');
}

async function updateResi(pool, packageId) {
  const resi = generateResi(packageId);
  await pool.query('UPDATE packages SET resi = ? WHERE package_id = ?', [resi, packageId]);
  return resi;
}

module.exports = { generateResi, updateResi };
