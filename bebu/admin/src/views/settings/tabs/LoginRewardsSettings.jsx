'use client'

import React, { useEffect, useMemo, useState } from 'react'

import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  Divider,
  FormControlLabel,
  Grid,
  IconButton,
  MenuItem,
  Select,
  Switch,
  TextField,
  Tooltip,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import { fetchLoginRewards, updateLoginRewards } from '@/redux-store/slices/loginRewards'

const METHODS = [
  { id: 'google', label: 'Google', hint: 'One tap with the Google account on the phone. Verified email for free.', glyph: 'G' },
  { id: 'phone', label: 'Phone OTP', hint: 'Firebase SMS code. Best when you need one account per person.', glyph: '☏' },
  { id: 'quick', label: 'One-tap guest', hint: 'Anonymous account tied to the device. Zero friction, no identity.', glyph: '⚡' },
  { id: 'email', label: 'Email + password', hint: 'Classic form with register / forgot-password screens.', glyph: '@' }
]

const DEFAULT_REWARDS = {
  profile: { enabled: true, coins: 25 },
  referral: { enabled: true, inviterCoins: 20, inviteeCoins: 0, purchaseSharePercent: 40, firstPurchaseOnly: true, codeWindowDays: 7 },
  avatarBonus: { enabled: true, percent: 5, minCoins: 4, maxCoins: 10 }
}

const bonusFor = (price, a) => (!a.enabled || price <= 0 ? 0 : Math.min(a.maxCoins, Math.max(a.minCoins, Math.round((price * a.percent) / 100))))

const TIMEZONES = ['Asia/Kolkata', 'Asia/Dubai', 'Asia/Singapore', 'Europe/London', 'America/New_York', 'UTC']

const Section = ({ title, subtitle, children, action }) => (
  <Card variant='outlined' sx={{ mb: 4 }}>
    <CardContent>
      <Box sx={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 2, mb: 3 }}>
        <Box>
          <Typography variant='h6'>{title}</Typography>
          {subtitle && (
            <Typography variant='body2' color='text.secondary'>
              {subtitle}
            </Typography>
          )}
        </Box>
        {action}
      </Box>
      {children}
    </CardContent>
  </Card>
)

const OptionCard = ({ selected, onClick, children, sx }) => (
  <Box
    onClick={onClick}
    role='button'
    tabIndex={0}
    onKeyDown={e => (e.key === 'Enter' || e.key === ' ') && onClick()}
    sx={{
      cursor: 'pointer',
      borderRadius: 2,
      p: 2,
      height: '100%',
      border: theme => `2px solid ${selected ? theme.palette.primary.main : theme.palette.divider}`,
      background: theme => (selected ? `${theme.palette.primary.main}0f` : 'transparent'),
      transition: 'all .15s ease',
      '&:hover': { borderColor: theme => theme.palette.primary.light },
      ...sx
    }}
  >
    {children}
  </Box>
)

const Stat = ({ label, value, hint }) => (
  <Box sx={{ p: 2, borderRadius: 2, border: theme => `1px solid ${theme.palette.divider}`, minWidth: 150, flex: 1 }}>
    <Typography variant='caption' color='text.secondary'>
      {label}
    </Typography>
    <Typography variant='h5' fontWeight={800}>
      {value}
    </Typography>
    {hint && (
      <Typography variant='caption' color='text.secondary'>
        {hint}
      </Typography>
    )}
  </Box>
)

/** Phone mock of the sign-in screen so the admin sees the button stack before saving. */
const SignInPreview = ({ login, welcomeCoins, dayOne }) => {
  const order = [login.primary, ...METHODS.map(m => m.id).filter(id => id !== login.primary)].filter(id => login[id])
  const names = { google: 'Continue with Google', phone: 'Continue with phone', quick: 'Try it now, no sign-up', email: 'Continue with email' }

  return (
    <Box
      sx={{
        width: 236,
        height: 470,
        borderRadius: '34px',
        p: '10px',
        background: 'linear-gradient(160deg,#2a2a31,#0b0b0d)',
        boxShadow: '0 30px 60px rgba(0,0,0,.35), inset 0 0 0 1px rgba(255,255,255,.08)',
        flexShrink: 0
      }}
    >
      <Box
        sx={{
          position: 'relative',
          overflow: 'hidden',
          height: '100%',
          borderRadius: '26px',
          background: '#0E0E10',
          color: '#F7F7F8',
          fontFamily: 'Inter, system-ui, sans-serif',
          display: 'flex',
          flexDirection: 'column'
        }}
      >
        <Box sx={{ position: 'absolute', top: -70, right: -60, width: 200, height: 200, borderRadius: '50%', background: 'radial-gradient(rgba(139,92,246,.4), transparent 70%)' }} />
        <Box sx={{ position: 'absolute', top: 120, left: -80, width: 200, height: 200, borderRadius: '50%', background: 'radial-gradient(rgba(255,61,138,.3), transparent 70%)' }} />

        <Box sx={{ position: 'relative', px: '16px', pt: '26px' }}>
          <Box sx={{ width: 34, height: 34, borderRadius: '10px', background: 'linear-gradient(135deg,#ff5fa2,#8b5cf6)', display: 'grid', placeItems: 'center', fontWeight: 900, fontSize: 18 }}>b</Box>
          <Typography sx={{ mt: '16px', fontSize: 19, fontWeight: 800, letterSpacing: -0.5, lineHeight: 1.1, color: '#F7F7F8' }}>
            {login.headline || 'Real people. Real talk.'}
          </Typography>
          <Typography sx={{ mt: '5px', fontSize: 9.5, color: 'rgba(247,247,248,.6)' }}>Voice & video calls with hosts who actually listen.</Typography>
          {login.showWelcomeBonus && (welcomeCoins > 0 || dayOne > 0) && (
            <Box sx={{ mt: '10px', display: 'inline-flex', alignItems: 'center', gap: '5px', px: '8px', py: '4px', borderRadius: '999px', background: 'rgba(255,176,32,.14)', border: '1px solid rgba(255,176,32,.4)', fontSize: 8.5, fontWeight: 800, color: '#FFB020' }}>
              <Box component='span' sx={{ width: 9, height: 9, borderRadius: '50%', background: 'radial-gradient(circle at 35% 35%, #ffe08a, #f4a300 70%)' }} />
              {welcomeCoins > 0 ? `${welcomeCoins.toLocaleString()} free coins on sign-up` : `${dayOne} coins daily gift`}
            </Box>
          )}
        </Box>

        <Box sx={{ flex: 1 }} />

        <Box sx={{ position: 'relative', px: '14px', pb: '14px', display: 'flex', flexDirection: 'column', gap: '7px' }}>
          {order.map((id, i) => (
            <Box
              key={id}
              sx={{
                height: i === 0 ? 38 : 34,
                borderRadius: '999px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '6px',
                fontSize: i === 0 ? 10.5 : 9.5,
                fontWeight: 700,
                background: i === 0 ? 'linear-gradient(120deg,#ff5fa2,#ff3d8a 45%,#8b5cf6)' : 'rgba(255,255,255,.06)',
                border: i === 0 ? 'none' : '1px solid rgba(255,255,255,.12)',
                boxShadow: i === 0 ? '0 10px 22px rgba(255,61,138,.35)' : 'none',
                color: '#F7F7F8'
              }}
            >
              <Box component='span' sx={{ fontSize: 10, opacity: 0.9 }}>{METHODS.find(m => m.id === id)?.glyph}</Box>
              {names[id]}
            </Box>
          ))}
          <Typography sx={{ mt: '4px', fontSize: 7.5, textAlign: 'center', color: 'rgba(247,247,248,.45)' }}>
            {login.requireConsentCheckbox ? '☐ I agree to the Terms & Privacy Policy' : 'By continuing you agree to our Terms & Privacy Policy'}
          </Typography>
        </Box>
      </Box>
    </Box>
  )
}

const StreakPreview = ({ coins }) => (
  <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
    {coins.map((c, i) => (
      <Box
        key={i}
        sx={{
          width: 64,
          p: 1,
          borderRadius: 1.5,
          textAlign: 'center',
          border: theme => `1px solid ${i === coins.length - 1 ? '#FFB020' : theme.palette.divider}`,
          background: i === coins.length - 1 ? 'rgba(255,176,32,.08)' : 'transparent'
        }}
      >
        <Typography variant='caption' color='text.secondary'>
          Day {i + 1}
        </Typography>
        <Typography fontWeight={800}>{c}</Typography>
      </Box>
    ))}
  </Box>
)

const LoginRewardsSettings = () => {
  const dispatch = useDispatch()
  const { loading, saving, error, login, preset, dailyReward, rewards, welcomeCoins, options, stats } = useSelector(s => s.loginRewards)
  const [draft, setDraft] = useState(null)

  useEffect(() => {
    dispatch(fetchLoginRewards())
  }, [dispatch])

  useEffect(() => {
    if (login && dailyReward) setDraft({ login, dailyReward, rewards: rewards || DEFAULT_REWARDS, welcomeCoins })
  }, [login, dailyReward, rewards, welcomeCoins])

  const server = useMemo(() => ({ login, dailyReward, rewards: rewards || DEFAULT_REWARDS, welcomeCoins }), [login, dailyReward, rewards, welcomeCoins])
  const dirty = useMemo(() => JSON.stringify(draft) !== JSON.stringify(server), [draft, server])

  const presets = useMemo(() => options?.presets || [], [options?.presets])

  const currentPreset = useMemo(() => {
    if (!draft) return 'custom'
    const hit = presets.find(p => ['google', 'phone', 'quick', 'email'].every(m => p.login[m] === draft.login[m]) && p.login.primary === draft.login.primary)

    return hit ? hit.id : 'custom'
  }, [draft, presets])

  const setLogin = patch => setDraft(d => ({ ...d, login: { ...d.login, ...patch } }))
  const setReward = patch => setDraft(d => ({ ...d, dailyReward: { ...d.dailyReward, ...patch } }))
  const setExtra = (block, patch) => setDraft(d => ({ ...d, rewards: { ...d.rewards, [block]: { ...d.rewards[block], ...patch } } }))
  const num = (v, lo = 0, hi = 1000000) => Math.min(hi, Math.max(lo, Math.round(Number(v) || 0)))

  const applyPreset = p => setLogin(p.login)

  const toggleMethod = id => {
    const next = { ...draft.login, [id]: !draft.login[id] }
    const enabled = ['google', 'phone', 'quick', 'email'].filter(m => next[m])

    if (enabled.length === 0) return
    if (!next[next.primary]) next.primary = enabled[0]
    setLogin(next)
  }

  const setCoin = (i, v) => {
    const coins = [...draft.dailyReward.coins]

    coins[i] = Math.max(0, Math.round(Number(v) || 0))
    setReward({ coins })
  }

  const addDay = () => {
    if (draft.dailyReward.coins.length >= 14) return
    const coins = draft.dailyReward.coins
    const last = coins[coins.length - 1] || 10

    setReward({ coins: [...coins, Math.round(last * 1.3)] })
  }

  const removeDay = i => {
    if (draft.dailyReward.coins.length <= 1) return
    setReward({ coins: draft.dailyReward.coins.filter((_, idx) => idx !== i) })
  }

  const save = () =>
    dispatch(
      updateLoginRewards({
        login: draft.login,
        dailyReward: draft.dailyReward,
        rewards: draft.rewards,
        welcomeCoins: draft.welcomeCoins
      })
    )

  const reset = () => setDraft(server)

  if (loading && !draft) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error && !draft) return <Alert severity='error'>{error}</Alert>
  if (!draft) return null

  const enabledCount = METHODS.filter(m => draft.login[m.id]).length
  const weekTotal = draft.dailyReward.coins.reduce((a, b) => a + b, 0)

  return (
    <Grid container spacing={6}>
      <Grid item size={{ xs: 12, lg: 8 }}>
        <Alert severity='info' sx={{ mb: 4 }}>
          The sign-in screen reads these settings before anyone logs in, so changes reach new installs immediately and existing users on their
          next launch. The hero (primary) button is the one users see first; everything else stacks underneath as quiet options.
        </Alert>

        {stats && (
          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', mb: 4 }}>
            <Stat label='Claimed today' value={stats.claimedToday} hint='users who collected the daily gift' />
            <Stat label='Active streaks' value={stats.activeStreaks} hint='3+ days and still going' />
            <Stat label='Claims · 7 days' value={stats.weekClaims} />
            <Stat label='Coins given · 7 days' value={stats.weekCoins.toLocaleString()} />
          </Box>
        )}
        {stats && stats.profileClaims !== undefined && (
          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', mb: 4 }}>
            <Stat label='Profiles completed' value={stats.profileClaims} hint={`${(stats.profileCoins || 0).toLocaleString()} coins paid`} />
            <Stat label='Invited users' value={stats.referredUsers} hint={`${stats.referralPurchases || 0} went on to buy coins`} />
            <Stat label='Invite coins paid' value={(stats.referralCoins || 0).toLocaleString()} hint='sign-ups + purchase shares' />
            <Stat label='Avatar bonuses' value={stats.avatarBonusUnlocks} hint={`${(stats.avatarBonusCoins || 0).toLocaleString()} coins paid back`} />
          </Box>
        )}

        <Section
          title='Sign-in methods'
          subtitle='Pick a preset, or fine-tune the methods and choose the hero button.'
          action={<Chip size='small' color='primary' variant='outlined' label={currentPreset === 'custom' ? 'Custom mix' : presets.find(p => p.id === currentPreset)?.label} />}
        >
          <Grid container spacing={2} sx={{ mb: 3 }}>
            {presets.map(p => (
              <Grid item size={{ xs: 12, sm: 6, md: 4 }} key={p.id}>
                <OptionCard selected={currentPreset === p.id} onClick={() => applyPreset(p)}>
                  <Typography fontWeight={700}>{p.label}</Typography>
                  <Typography variant='caption' color='text.secondary'>
                    {p.hint}
                  </Typography>
                </OptionCard>
              </Grid>
            ))}
          </Grid>

          <Divider sx={{ my: 3 }} />

          <Grid container spacing={2}>
            {METHODS.map(m => {
              const on = draft.login[m.id]
              const isPrimary = draft.login.primary === m.id

              return (
                <Grid item size={{ xs: 12, md: 6 }} key={m.id}>
                  <Box
                    sx={{
                      p: 2,
                      borderRadius: 2,
                      border: theme => `1px solid ${isPrimary ? theme.palette.primary.main : theme.palette.divider}`,
                      display: 'flex',
                      alignItems: 'flex-start',
                      gap: 2,
                      opacity: on ? 1 : 0.6
                    }}
                  >
                    <Box sx={{ width: 40, height: 40, borderRadius: '12px', display: 'grid', placeItems: 'center', fontWeight: 800, fontSize: 18, background: theme => theme.palette.action.hover, flexShrink: 0 }}>
                      {m.glyph}
                    </Box>
                    <Box sx={{ flex: 1 }}>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Typography fontWeight={700}>{m.label}</Typography>
                        {isPrimary && <Chip size='small' color='primary' label='Hero button' />}
                      </Box>
                      <Typography variant='caption' color='text.secondary'>
                        {m.hint}
                      </Typography>
                      <Box sx={{ mt: 1, display: 'flex', gap: 1, alignItems: 'center' }}>
                        <Switch size='small' checked={on} disabled={on && enabledCount === 1} onChange={() => toggleMethod(m.id)} />
                        <Typography variant='caption'>{on ? 'Shown' : 'Hidden'}</Typography>
                        {on && !isPrimary && (
                          <Button size='small' variant='text' onClick={() => setLogin({ primary: m.id })}>
                            Make hero
                          </Button>
                        )}
                      </Box>
                    </Box>
                  </Box>
                </Grid>
              )
            })}
          </Grid>

          <Divider sx={{ my: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={{ xs: 12, md: 6 }}>
              <TextField
                fullWidth
                size='small'
                label='Headline (optional)'
                placeholder='Real people. Real talk.'
                value={draft.login.headline}
                inputProps={{ maxLength: 80 }}
                onChange={e => setLogin({ headline: e.target.value })}
                helperText='Shown above the buttons. Leave empty for the default.'
              />
            </Grid>
            <Grid item size={{ xs: 12, md: 6 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='Welcome bonus (coins on first sign-up)'
                value={draft.welcomeCoins}
                onChange={e => setDraft(d => ({ ...d, welcomeCoins: Math.max(0, Math.round(Number(e.target.value) || 0)) }))}
                helperText='Credited once when the account is created. 0 disables it.'
              />
            </Grid>
            <Grid item size={{ xs: 12, md: 6 }}>
              <FormControlLabel
                control={<Switch checked={draft.login.showWelcomeBonus} onChange={e => setLogin({ showWelcomeBonus: e.target.checked })} />}
                label={
                  <Box>
                    <Typography>Tease the bonus on the sign-in screen</Typography>
                    <Typography variant='caption' color='text.secondary'>
                      “5,000 free coins on sign-up” pill under the headline. Strong nudge to finish sign-in.
                    </Typography>
                  </Box>
                }
              />
            </Grid>
            <Grid item size={{ xs: 12, md: 6 }}>
              <FormControlLabel
                control={<Switch checked={draft.login.requireConsentCheckbox} onChange={e => setLogin({ requireConsentCheckbox: e.target.checked })} />}
                label={
                  <Box>
                    <Typography>Require an explicit consent checkbox</Typography>
                    <Typography variant='caption' color='text.secondary'>
                      Off = “By continuing you agree…” (fewer taps). Turn on if your legal team needs an explicit tick.
                    </Typography>
                  </Box>
                }
              />
            </Grid>
          </Grid>
        </Section>

        <Section
          title='Daily streak reward'
          subtitle='A gift the user can collect once a day. Rewards grow along the streak and loop after the last day.'
          action={<Chip size='small' color={draft.dailyReward.enabled ? 'success' : 'default'} label={draft.dailyReward.enabled ? 'On' : 'Off'} />}
        >
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 4, mb: 3 }}>
            <FormControlLabel
              control={<Switch checked={draft.dailyReward.enabled} onChange={e => setReward({ enabled: e.target.checked })} />}
              label={
                <Box>
                  <Typography>Enable daily rewards</Typography>
                  <Typography variant='caption' color='text.secondary'>
                    Shows the gift button on Home and the claim sheet.
                  </Typography>
                </Box>
              }
            />
            <FormControlLabel
              control={<Switch checked={draft.dailyReward.autoOpen} disabled={!draft.dailyReward.enabled} onChange={e => setReward({ autoOpen: e.target.checked })} />}
              label={
                <Box>
                  <Typography>Open automatically</Typography>
                  <Typography variant='caption' color='text.secondary'>
                    Pop the sheet on Home when a reward is waiting (once per day).
                  </Typography>
                </Box>
              }
            />
            <FormControlLabel
              control={<Switch checked={draft.dailyReward.resetStreakOnMiss} disabled={!draft.dailyReward.enabled} onChange={e => setReward({ resetStreakOnMiss: e.target.checked })} />}
              label={
                <Box>
                  <Typography>Reset streak on a missed day</Typography>
                  <Typography variant='caption' color='text.secondary'>
                    Loss aversion: skip a day, start from Day 1. Off = streak only ever grows.
                  </Typography>
                </Box>
              }
            />
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 2, mb: 1.5 }}>
            <Typography fontWeight={700}>Coins per day</Typography>
            <Typography variant='caption' color='text.secondary'>
              {draft.dailyReward.coins.length}-day cycle · {weekTotal.toLocaleString()} coins per full cycle
            </Typography>
          </Box>
          <Grid container spacing={1.5} sx={{ mb: 2 }}>
            {draft.dailyReward.coins.map((c, i) => (
              <Grid item size={{ xs: 6, sm: 4, md: 3 }} key={i}>
                <TextField
                  fullWidth
                  size='small'
                  type='number'
                  label={`Day ${i + 1}`}
                  value={c}
                  disabled={!draft.dailyReward.enabled}
                  onChange={e => setCoin(i, e.target.value)}
                  InputProps={{
                    endAdornment: (
                      <Tooltip title='Remove day'>
                        <IconButton size='small' onClick={() => removeDay(i)} disabled={draft.dailyReward.coins.length <= 1 || !draft.dailyReward.enabled} edge='end'>
                          <i className='tabler-x' style={{ fontSize: 14 }} />
                        </IconButton>
                      </Tooltip>
                    )
                  }}
                />
              </Grid>
            ))}
            <Grid item size={{ xs: 6, sm: 4, md: 3 }}>
              <Button fullWidth variant='outlined' sx={{ height: 40 }} onClick={addDay} disabled={draft.dailyReward.coins.length >= 14 || !draft.dailyReward.enabled}>
                + Add day
              </Button>
            </Grid>
          </Grid>

          <StreakPreview coins={draft.dailyReward.coins} />

          <Divider sx={{ my: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={{ xs: 12, md: 6 }}>
              <Typography variant='body2' sx={{ mb: 1 }}>
                Day boundary timezone
              </Typography>
              <Select
                fullWidth
                size='small'
                value={TIMEZONES.includes(draft.dailyReward.timezone) ? draft.dailyReward.timezone : 'Asia/Kolkata'}
                onChange={e => setReward({ timezone: e.target.value })}
              >
                {TIMEZONES.map(tz => (
                  <MenuItem key={tz} value={tz}>
                    {tz}
                  </MenuItem>
                ))}
              </Select>
              <Typography variant='caption' color='text.secondary'>
                A new reward unlocks at midnight in this timezone. The app shows a live countdown to it.
              </Typography>
            </Grid>
          </Grid>
        </Section>

        <Section
          title='Complete your profile'
          subtitle='One-time reward when name, photo, gender, birthday, country and a short bio are all filled. Granted automatically on save, or from the Earn coins screen.'
          action={<Chip size='small' color={draft.rewards.profile.enabled ? 'success' : 'default'} label={draft.rewards.profile.enabled ? 'On' : 'Off'} />}
        >
          <Grid container spacing={3} alignItems='center'>
            <Grid item size={{ xs: 12, md: 6 }}>
              <FormControlLabel
                control={<Switch checked={draft.rewards.profile.enabled} onChange={e => setExtra('profile', { enabled: e.target.checked })} />}
                label={
                  <Box>
                    <Typography>Reward profile completion</Typography>
                    <Typography variant='caption' color='text.secondary'>
                      Off hides the card in the app. Users who already claimed keep their coins.
                    </Typography>
                  </Box>
                }
              />
            </Grid>
            <Grid item size={{ xs: 12, sm: 6, md: 3 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='Coins'
                value={draft.rewards.profile.coins}
                disabled={!draft.rewards.profile.enabled}
                onChange={e => setExtra('profile', { coins: num(e.target.value) })}
              />
            </Grid>
          </Grid>
        </Section>

        <Section
          title='Invite friends'
          subtitle='Every user gets a 6-character invite code (Earn coins → Invite friends). The inviter is paid when the friend signs up with it and again when that friend buys coins.'
          action={<Chip size='small' color={draft.rewards.referral.enabled ? 'success' : 'default'} label={draft.rewards.referral.enabled ? 'On' : 'Off'} />}
        >
          <FormControlLabel
            sx={{ mb: 2 }}
            control={<Switch checked={draft.rewards.referral.enabled} onChange={e => setExtra('referral', { enabled: e.target.checked })} />}
            label={
              <Box>
                <Typography>Enable invite rewards</Typography>
                <Typography variant='caption' color='text.secondary'>
                  Off hides codes, sharing and payouts. Existing links between users are kept.
                </Typography>
              </Box>
            }
          />
          <Grid container spacing={3}>
            <Grid item size={{ xs: 12, sm: 6, md: 3 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='Inviter gets per sign-up'
                helperText='Coins when a new user enters the code'
                value={draft.rewards.referral.inviterCoins}
                disabled={!draft.rewards.referral.enabled}
                onChange={e => setExtra('referral', { inviterCoins: num(e.target.value) })}
              />
            </Grid>
            <Grid item size={{ xs: 12, sm: 6, md: 3 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='New user gets'
                helperText='Optional welcome coins for entering a code'
                value={draft.rewards.referral.inviteeCoins}
                disabled={!draft.rewards.referral.enabled}
                onChange={e => setExtra('referral', { inviteeCoins: num(e.target.value) })}
              />
            </Grid>
            <Grid item size={{ xs: 12, sm: 6, md: 3 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='Purchase share %'
                helperText='% of the coins an invited user buys, paid to the inviter'
                value={draft.rewards.referral.purchaseSharePercent}
                disabled={!draft.rewards.referral.enabled}
                onChange={e => setExtra('referral', { purchaseSharePercent: num(e.target.value, 0, 100) })}
              />
            </Grid>
            <Grid item size={{ xs: 12, sm: 6, md: 3 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='Code entry window (days)'
                helperText='How long after joining a code can be entered'
                value={draft.rewards.referral.codeWindowDays}
                disabled={!draft.rewards.referral.enabled}
                onChange={e => setExtra('referral', { codeWindowDays: num(e.target.value, 1, 365) })}
              />
            </Grid>
          </Grid>
          <FormControlLabel
            sx={{ mt: 1 }}
            control={<Switch checked={draft.rewards.referral.firstPurchaseOnly} disabled={!draft.rewards.referral.enabled} onChange={e => setExtra('referral', { firstPurchaseOnly: e.target.checked })} />}
            label={
              <Box>
                <Typography>First purchase only</Typography>
                <Typography variant='caption' color='text.secondary'>
                  On = the share is paid once, on the friend&apos;s first coin pack. Off = on every purchase they ever make.
                </Typography>
              </Box>
            }
          />
          <Alert severity='info' icon={false} sx={{ mt: 2 }}>
            Example: a friend joins with a code → inviter gets <b>{draft.rewards.referral.inviterCoins}</b> coins. The friend buys a 500-coin pack → inviter gets{' '}
            <b>{Math.round((500 * draft.rewards.referral.purchaseSharePercent) / 100)}</b> more. Codes cannot be used by users who already bought coins.
          </Alert>
        </Section>

        <Section
          title='Premium avatar bonus'
          subtitle='Coins paid straight back when a user unlocks a paid Avatar Studio item, scaled by the item price: bonus = price × percent, clamped to the range.'
          action={<Chip size='small' color={draft.rewards.avatarBonus.enabled ? 'success' : 'default'} label={draft.rewards.avatarBonus.enabled ? 'On' : 'Off'} />}
        >
          <FormControlLabel
            sx={{ mb: 2 }}
            control={<Switch checked={draft.rewards.avatarBonus.enabled} onChange={e => setExtra('avatarBonus', { enabled: e.target.checked })} />}
            label={
              <Box>
                <Typography>Enable unlock bonus</Typography>
                <Typography variant='caption' color='text.secondary'>
                  Shows &quot;+N back&quot; on studio tiles and a bonus chip in the unlock celebration.
                </Typography>
              </Box>
            }
          />
          <Grid container spacing={3}>
            <Grid item size={{ xs: 12, sm: 4 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='Percent of price'
                value={draft.rewards.avatarBonus.percent}
                disabled={!draft.rewards.avatarBonus.enabled}
                onChange={e => setExtra('avatarBonus', { percent: num(e.target.value, 0, 100) })}
              />
            </Grid>
            <Grid item size={{ xs: 12, sm: 4 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='Minimum coins'
                value={draft.rewards.avatarBonus.minCoins}
                disabled={!draft.rewards.avatarBonus.enabled}
                onChange={e => setExtra('avatarBonus', { minCoins: num(e.target.value) })}
              />
            </Grid>
            <Grid item size={{ xs: 12, sm: 4 }}>
              <TextField
                fullWidth
                size='small'
                type='number'
                label='Maximum coins'
                value={draft.rewards.avatarBonus.maxCoins}
                disabled={!draft.rewards.avatarBonus.enabled}
                onChange={e => setExtra('avatarBonus', { maxCoins: num(e.target.value) })}
              />
            </Grid>
          </Grid>
          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mt: 2 }}>
            {[40, 80, 120, 200, 350].map(price => (
              <Chip key={price} size='small' variant='outlined' label={`${price}-coin item → +${bonusFor(price, draft.rewards.avatarBonus)} back`} />
            ))}
          </Box>
        </Section>

        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
          <Button variant='outlined' color='secondary' disabled={!dirty || saving} onClick={reset}>
            Discard
          </Button>
          <Button variant='contained' disabled={!dirty || saving} onClick={save} startIcon={saving ? <CircularProgress size={16} color='inherit' /> : null}>
            {saving ? 'Saving…' : 'Save login & rewards'}
          </Button>
        </Box>
      </Grid>

      <Grid item size={{ xs: 12, lg: 4 }}>
        <Box sx={{ position: { lg: 'sticky' }, top: 96, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}>
          <Typography variant='subtitle2' color='text.secondary'>
            Sign-in screen preview
          </Typography>
          <SignInPreview login={draft.login} welcomeCoins={draft.welcomeCoins} dayOne={draft.dailyReward.enabled ? draft.dailyReward.coins[0] : 0} />
          <Typography variant='caption' color='text.secondary' textAlign='center' sx={{ maxWidth: 260 }}>
            Order follows the hero button first, then Google, phone, guest, email. Saved preset: <b>{preset}</b>.
          </Typography>
        </Box>
      </Grid>
    </Grid>
  )
}

export default LoginRewardsSettings
