import { DevTokenVerifier, encodeDevToken } from './dev-token-verifier.js';
import { TokenVerificationError } from './token-verifier.js';

describe('DevTokenVerifier', () => {
  const verifier = new DevTokenVerifier();

  it('round-trips an encoded dev identity', async () => {
    const token = encodeDevToken({ uid: 'u1', email: 'u1@example.com', provider: 'phone' });
    const identity = await verifier.verify(token);
    expect(identity).toMatchObject({
      uid: 'u1',
      email: 'u1@example.com',
      provider: 'phone',
      emailVerified: true,
    });
  });

  it('rejects anything that is not a dev token', async () => {
    await expect(verifier.verify('eyJhbGciOi...')).rejects.toBeInstanceOf(TokenVerificationError);
    await expect(verifier.verify('dev:not-base64-json')).rejects.toBeInstanceOf(
      TokenVerificationError,
    );
    await expect(
      verifier.verify('dev:' + Buffer.from(JSON.stringify({ nope: true })).toString('base64url')),
    ).rejects.toBeInstanceOf(TokenVerificationError);
  });

  it('refuses to exist in production', () => {
    const previous = process.env['NODE_ENV'];
    process.env['NODE_ENV'] = 'production';
    try {
      expect(() => new DevTokenVerifier()).toThrow(/never/);
    } finally {
      process.env['NODE_ENV'] = previous;
    }
  });
});
