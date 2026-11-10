
const admin = require('firebase-admin');
const crypto = require('crypto');

// Safety check: never allow this script to write to production.
if (process.env.FIRESTORE_EMULATOR_HOST !== '127.0.0.1:8080') {
  throw new Error(
    'SAFETY STOP: Firestore Emulator is not configured. No data written.'
  );
}

admin.initializeApp({
  projectId: 'alertxband',
});

const db = admin.firestore();

async function seedEmulator() {
  const deviceId = 'AXB-000001';

  // Generate a separate random activation code for local testing.
  const activationCode =
    'AXB-LOCAL-' + crypto.randomBytes(6).toString('hex').toUpperCase();

  // The Cloud Function removes spaces and hyphens before hashing.
  const normalizedCode = activationCode
    .trim()
    .toUpperCase()
    .replace(/[\s-]/g, '');

  const activationCodeHash = crypto
    .createHash('sha256')
    .update(normalizedCode)
    .digest('hex');

  const expiry = admin.firestore.Timestamp.fromDate(
    new Date('2027-12-31T23:59:00Z')
  );

  // Create the local test device.
  await db.collection('devices').doc(deviceId).set({
    deviceId: deviceId,
    deviceName: 'AlertXBand Prototype 001',
    deviceType: 'Wearable Safety Device',
    firmwareVersion: '0.1.0',
    registeredAt: admin.firestore.FieldValue.serverTimestamp(),
    status: 'active',
    ownerUid: null,
  });

  // Store only the activation-code hash.
  await db.collection('deviceSecrets').doc(deviceId).set({
    activationCodeHash: activationCodeHash,
    expiresAt: expiry,
    isUsed: false,
  });

  console.log('\n====================================');
  console.log('ALERTXBAND LOCAL TEST DEVICE CREATED');
  console.log('====================================');
  console.log('Device ID:', deviceId);
  console.log('Test Activation Code:', activationCode);
  console.log('Expiry:', expiry.toDate().toISOString());
  console.log('====================================\n');
}

seedEmulator()
  .then(() => {
    console.log('Local Firestore seeding completed.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Seeding failed:', error);
    process.exit(1);
  });
