'use client'

// Left half of the sign-in / registration screens: the bebu brand, a couple of
// product lines and two app screens in phone frames. Pure CSS so it stays crisp
// on any display and needs no vendor artwork.

import { styled } from '@mui/material/styles'

const Panel = styled('div')({
  position: 'relative',
  width: '100%',
  minHeight: '100dvh',
  overflow: 'hidden',
  display: 'flex',
  flexDirection: 'column',
  padding: '48px 56px 72px',
  color: '#fff',
  background:
    'radial-gradient(120% 90% at 0% 0%, #5B2A86 0%, rgba(91,42,134,0) 55%), radial-gradient(90% 70% at 100% 100%, #FF4D6D 0%, rgba(255,77,109,0) 60%), linear-gradient(160deg, #1B0F2E 0%, #2A1443 50%, #3B0F2E 100%)',
  '&::after': {
    content: '""',
    position: 'absolute',
    inset: 0,
    pointerEvents: 'none',
    backgroundImage:
      'radial-gradient(circle at 20% 30%, rgba(255,255,255,0.08) 0 1px, transparent 2px), radial-gradient(circle at 70% 60%, rgba(255,255,255,0.06) 0 1px, transparent 2px), radial-gradient(circle at 40% 85%, rgba(255,255,255,0.05) 0 1px, transparent 2px)',
    backgroundSize: '220px 220px, 340px 340px, 280px 280px'
  }
})

const Wordmark = styled('div')({
  display: 'flex',
  alignItems: 'center',
  gap: 12,
  fontWeight: 800,
  fontSize: 26,
  letterSpacing: '-0.02em',
  '& img': { width: 44, height: 44, borderRadius: 12, boxShadow: '0 8px 24px rgba(255,77,109,0.35)' }
})

const Copy = styled('div')({
  position: 'relative',
  zIndex: 1,
  maxWidth: 'min(440px, 62%)',
  marginTop: 'clamp(40px, 9vh, 96px)',
  '& h1': {
    margin: 0,
    fontSize: 'clamp(30px, 3.2vw, 44px)',
    lineHeight: 1.08,
    fontWeight: 800,
    letterSpacing: '-0.025em'
  },
  '& p': { margin: '16px 0 0', fontSize: 16, lineHeight: 1.55, color: 'rgba(255,255,255,0.78)' }
})

const Chips = styled('div')({
  display: 'flex',
  flexWrap: 'wrap',
  gap: 8,
  marginTop: 22,
  '& span': {
    padding: '7px 12px',
    borderRadius: 999,
    fontSize: 13,
    fontWeight: 600,
    background: 'rgba(255,255,255,0.10)',
    border: '1px solid rgba(255,255,255,0.14)',
    backdropFilter: 'blur(6px)'
  }
})

const Phones = styled('div')({
  position: 'absolute',
  right: -24,
  bottom: -110,
  display: 'flex',
  alignItems: 'flex-end',
  gap: 20,
  transform: 'rotate(-8deg)',
  transformOrigin: 'bottom right',
  zIndex: 0,
  '@media (max-width: 1280px)': { transform: 'rotate(-8deg) scale(0.8)' }
})

const Phone = styled('div', { shouldForwardProp: p => p !== 'tall' })(({ tall }) => ({
  width: tall ? 210 : 180,
  aspectRatio: '780 / 1688',
  borderRadius: 40,
  padding: 10,
  background: 'linear-gradient(180deg, #2B2B33, #0E0E12)',
  boxShadow: '0 40px 80px rgba(0,0,0,0.5), inset 0 0 0 1px rgba(255,255,255,0.08)',
  '& img': { width: '100%', height: '100%', objectFit: 'cover', borderRadius: 32, display: 'block' }
}))

const Foot = styled('div')({
  position: 'absolute',
  left: 56,
  bottom: 40,
  zIndex: 2,
  padding: '8px 14px',
  borderRadius: 999,
  background: 'rgba(20,10,35,0.55)',
  backdropFilter: 'blur(8px)',
  display: 'flex',
  alignItems: 'center',
  gap: 10,
  fontSize: 13,
  color: 'rgba(255,255,255,0.62)',
  '& b': { color: 'rgba(255,255,255,0.9)', fontWeight: 600 }
})

const BrandPanel = ({ title = 'Real people. Real conversations.', subtitle }) => (
  <Panel>
    <Wordmark>
      <img src='/images/logo/bebu-logo.png' alt='bebu' />
      bebu
    </Wordmark>

    <Copy>
      <h1>{title}</h1>
      <p>
        {subtitle ??
          'Run the bebu marketplace from one place: hosts, coins, gifts, rewards, payouts and the AI that keeps every chat alive.'}
      </p>
      <Chips>
        <span>1-to-1 voice & video</span>
        <span>Coin wallet</span>
        <span>Gifts & rewards</span>
        <span>AI hosts</span>
      </Chips>
    </Copy>

    <Phones aria-hidden>
      <Phone>
        <img src='/images/brand/app-chat.webp' alt='' />
      </Phone>
      <Phone tall>
        <img src='/images/brand/app-home.webp' alt='' />
      </Phone>
    </Phones>

    <Foot>
      <b>bebu</b> · a product of Elevanza Ltd · bebuapp.in
    </Foot>
  </Panel>
)

export default BrandPanel
