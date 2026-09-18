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
    expect(() => new DevTokenVerifier({ appEnv: 'production', secret: 's'.repeat(32) })).toThrow(
      /never/,
    );
  });

  describe('with a shared secret (staging)', () => {
    const secret = 'staging-secret-that-is-at-least-32-chars-long';
    const signed = new DevTokenVerifier({ secret, appEnv: 'staging' });

    it('requires a secret in staging', () => {
      expect(() => new DevTokenVerifier({ appEnv: 'staging' })).toThrow(/shared secret/);
    });

    it('accepts correctly signed tokens', async () => {
      const token = encodeDevToken({ uid: 'admin-1', email: 'a@bebuapp.in' }, secret);
      await expect(signed.verify(token)).resolves.toMatchObject({ uid: 'admin-1' });
    });

    it('rejects unsigned tokens and wrong secrets', async () => {
      const unsigned = encodeDevToken({ uid: 'admin-1' });
      await expect(signed.verify(unsigned)).rejects.toThrow(/signature/);

      const wrong = encodeDevToken({ uid: 'admin-1' }, 'another-secret-that-is-also-32-chars!!');
      await expect(signed.verify(wrong)).rejects.toThrow(/signature/);
    });

    it('rejects tampered payloads', async () => {
      const token = encodeDevToken({ uid: 'user-1' }, secret);
      const sig = token.split('.', 2)[1];
      const forgedBody = Buffer.from(JSON.stringify({ uid: 'dev-super-admin' })).toString(
        'base64url',
      );
      await expect(signed.verify(`dev:${forgedBody}.${sig}`)).rejects.toThrow(/signature/);
    });
  });
});
