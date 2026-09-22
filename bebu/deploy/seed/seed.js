// Initial content for a fresh database. Idempotent: only inserts into empty
// collections. Run with:
//   docker compose exec -T mongo mongosh bebu < seed/seed.js
const now = new Date();
const stamp = (doc) => ({ ...doc, createdAt: now, updatedAt: now });

function seed(collection, docs) {
  const c = db.getCollection(collection);
  if (c.countDocuments() > 0) {
    print(`${collection}: already has ${c.countDocuments()} documents, skipped`);
    return;
  }
  c.insertMany(docs.map(stamp));
  print(`${collection}: inserted ${docs.length}`);
}

seed('currencies', [
  { name: 'Rupee', symbol: '₹', countryCode: 'IN', currencyCode: 'INR', isDefault: true },
  { name: 'US Dollar', symbol: '$', countryCode: 'US', currencyCode: 'USD', isDefault: false },
]);

seed('talktopics', [
  'Friendship', 'Relationships', 'Loneliness', 'Career', 'Study stress',
  'Motivation', 'Movies & music', 'Travel', 'Fitness', 'Late-night talk',
  'Language practice', 'Life advice',
].map((name) => ({ name })));

seed('identityproofs', [
  { title: 'Aadhaar card' },
  { title: 'PAN card' },
  { title: 'Passport' },
  { title: "Driver's licence" },
]);

seed('coinplans', [
  { coins: 100, price: 49, productId: 'bebu_coins_100', isPopular: false, isActive: true },
  { coins: 250, price: 99, productId: 'bebu_coins_250', isPopular: false, isActive: true },
  { coins: 600, price: 199, productId: 'bebu_coins_600', isPopular: true, isActive: true },
  { coins: 1600, price: 499, productId: 'bebu_coins_1600', isPopular: false, isActive: true },
  { coins: 3500, price: 999, productId: 'bebu_coins_3500', isPopular: false, isActive: true },
]);

seed('faqs', [
  { category: 'User', question: 'How do coins work?', answer: 'Coins are deducted per minute while you are on a call. The rate is shown on every caller profile before you connect.' },
  { category: 'User', question: 'Is my number or identity shared?', answer: 'No. Callers only see your display name. Your phone number and payment details are never shared.' },
  { category: 'User', question: 'What happens if a call drops?', answer: 'You are only charged for completed minutes. Reconnect from the caller profile to continue.' },
  { category: 'User', question: 'How do I get a refund?', answer: 'Contact support from the Help Center with the call time and we will review it within 24 hours.' },
  { category: 'Listener', question: 'How do I become a caller?', answer: 'Open Become a host, upload an identity proof and a short audio intro. Approval usually takes under 24 hours.' },
  { category: 'Listener', question: 'When do I get paid?', answer: 'Request a payout from your wallet once you reach the minimum balance. Payouts are processed weekly.' },
  { category: 'Listener', question: 'Can I go offline?', answer: 'Yes. Toggle your availability from the home screen any time; you will not receive calls while offline.' },
]);
