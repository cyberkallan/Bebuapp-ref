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
  MenuItem,
  Select,
  Switch,
  Tooltip,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import { fetchAppearance, updateAppearance } from '@/redux-store/slices/appearance'

const THEME_CARDS = [
  { id: 'dark', label: 'Dark', hint: 'Deep charcoal, photo-first. The bebu default.' },
  { id: 'light', label: 'Light', hint: 'Soft lavender-white surfaces, dark text.' },
  { id: 'system', label: 'System', hint: 'Follows the phone’s dark-mode setting.' }
]

const MOTION = [
  { id: 'full', label: 'Full', hint: 'Coin flip, ringing buttons, card transitions' },
  { id: 'reduced', label: 'Reduced', hint: 'Near-instant transitions, no looping animations' }
]

const CORNERS = [
  { id: 'rounded', label: 'Rounded', radius: 22 },
  { id: 'soft', label: 'Soft', radius: 15 },
  { id: 'sharp', label: 'Sharp', radius: 9 }
]

const PALETTE = {
  dark: { bg: '#0E0E10', surface: '#1A1A1E', surface2: '#242429', text: '#F7F7F8', muted: 'rgba(247,247,248,.7)', border: 'rgba(255,255,255,.12)' },
  light: { bg: '#F6F5FA', surface: '#FFFFFF', surface2: '#F0EEF6', text: '#17151E', muted: 'rgba(23,21,30,.7)', border: 'rgba(0,0,0,.08)' }
}

/** Small phone mock that reflects the current draft so admins can see the effect before saving. */
const PhonePreview = ({ draft, accent, mode }) => {
  const p = PALETTE[mode === 'light' ? 'light' : 'dark']
  const r = CORNERS.find(c => c.id === draft.cornerStyle)?.radius ?? 22
  const glow = draft.ambientGlow

  const sheet = draft.motion === 'full' ? `
    @keyframes bebuFlip { 0%,18%{transform:rotateY(0)} 9%{transform:rotateY(180deg)} 18%,100%{transform:rotateY(360deg)} }
    @keyframes bebuRing { 0%{transform:scale(1);opacity:.6} 100%{transform:scale(1.9);opacity:0} }
  ` : ''

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
      <style>{sheet}</style>
      <Box
        sx={{
          position: 'relative',
          overflow: 'hidden',
          height: '100%',
          borderRadius: '26px',
          background: p.bg,
          color: p.text,
          fontFamily: 'Inter, system-ui, sans-serif'
        }}
      >
        {glow && (
          <>
            <Box sx={{ position: 'absolute', top: -70, right: -60, width: 190, height: 190, borderRadius: '50%', background: `radial-gradient(${mode === 'light' ? 'rgba(139,92,246,.22)' : 'rgba(139,92,246,.32)'}, transparent 70%)` }} />
            <Box sx={{ position: 'absolute', bottom: 40, left: -70, width: 180, height: 180, borderRadius: '50%', background: `radial-gradient(${accent.primary}${mode === 'light' ? '22' : '2e'}, transparent 70%)` }} />
          </>
        )}

        {/* header */}
        <Box sx={{ position: 'relative', display: 'flex', alignItems: 'center', gap: '6px', p: '14px 12px 8px' }}>
          <Box sx={{ width: 24, height: 24, borderRadius: '50%', background: p.surface2, border: `1px solid ${p.border}` }} />
          <Box sx={{ flex: 1, height: 24, borderRadius: '999px', background: p.surface, border: `1px solid ${p.border}`, display: 'flex', alignItems: 'center', p: '2px', gap: '2px' }}>
            <Box sx={{ flex: 1, height: '100%', borderRadius: '999px', background: p.surface2, fontSize: 8, fontWeight: 700, display: 'grid', placeItems: 'center' }}>
              <span style={{ color: accent.primary }}>●</span>&nbsp;For You
            </Box>
            <Box sx={{ flex: 1, fontSize: 8, color: p.muted, textAlign: 'center' }}>Live</Box>
          </Box>
          <Box sx={{ height: 24, px: '6px', borderRadius: '999px', display: 'flex', alignItems: 'center', gap: '4px', background: `linear-gradient(90deg, rgba(255,176,32,.18), ${p.surface})`, border: '1px solid rgba(255,176,32,.35)', fontSize: 8.5, fontWeight: 800, color: '#FFB020' }}>
            <Box component='span' sx={{ display: 'inline-block', width: 10, height: 10, borderRadius: '50%', background: 'radial-gradient(circle at 35% 35%, #ffe08a, #f4a300 70%)', animation: draft.coinAnimation && draft.motion === 'full' ? 'bebuFlip 4.2s linear infinite' : 'none' }} />
            1,240
          </Box>
        </Box>

        {/* deck */}
        <Box sx={{ position: 'relative', mx: '14px', mt: '18px', height: 268 }}>
          <Box sx={{ position: 'absolute', inset: '-12px 14px auto 14px', height: 40, borderRadius: `${r}px`, background: p.surface2, opacity: .5 }} />
          <Box sx={{ position: 'absolute', inset: '-6px 7px auto 7px', height: 40, borderRadius: `${r}px`, background: p.surface2, opacity: .8 }} />
          <Box
            sx={{
              position: 'absolute',
              inset: 0,
              borderRadius: `${r}px`,
              overflow: 'hidden',
              background: 'linear-gradient(180deg,#6b4a3a 0%,#3b2a24 55%,#151013 100%)',
              boxShadow: '0 18px 30px rgba(0,0,0,.35)'
            }}
          >
            <Box sx={{ position: 'absolute', left: 12, right: 12, bottom: 12, color: '#F7F7F8' }}>
              <Box sx={{ display: 'flex', gap: '4px', mb: '6px' }}>
                {['Late-night talk', 'Movies'].map(t => (
                  <Box key={t} sx={{ fontSize: 7, px: '6px', py: '2px', borderRadius: '999px', background: 'rgba(255,255,255,.2)' }}>{t}</Box>
                ))}
              </Box>
              <Typography sx={{ fontSize: 15, fontWeight: 800, letterSpacing: -0.4, lineHeight: 1.1, color: '#F7F7F8' }}>Anjali Menon, 23</Typography>
              <Box sx={{ mt: '5px', display: 'inline-flex', alignItems: 'center', gap: '4px', fontSize: 7.5, px: '6px', py: '2px', borderRadius: '999px', background: 'rgba(0,0,0,.35)' }}>
                <Box component='span' sx={{ width: 5, height: 5, borderRadius: '50%', background: '#34D399' }} /> In real time
              </Box>
            </Box>
          </Box>
        </Box>

        {/* actions */}
        <Box sx={{ position: 'relative', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '12px', mt: '18px' }}>
          <Box sx={{ width: 30, height: 30, borderRadius: '50%', background: p.surface2, border: `1px solid ${p.border}` }} />
          <Box sx={{ position: 'relative', width: 42, height: 42 }}>
            {draft.liveRings && draft.motion === 'full' && (
              <>
                <Box sx={{ position: 'absolute', inset: 0, borderRadius: '50%', border: `1.5px solid ${accent.primary}`, animation: 'bebuRing 1.6s ease-out infinite' }} />
                <Box sx={{ position: 'absolute', inset: 0, borderRadius: '50%', border: `1.5px solid ${accent.primary}`, animation: 'bebuRing 1.6s ease-out .4s infinite' }} />
              </>
            )}
            <Box sx={{ position: 'absolute', inset: 0, borderRadius: '50%', background: `linear-gradient(135deg, ${accent.light}, ${accent.deep})`, boxShadow: `0 10px 22px ${accent.primary}66`, display: 'grid', placeItems: 'center', color: '#fff', fontSize: 14 }}>✆</Box>
          </Box>
          <Box sx={{ width: 30, height: 30, borderRadius: '50%', background: p.surface2, border: `1px solid ${p.border}` }} />
        </Box>

        {/* nav */}
        <Box sx={{ position: 'absolute', left: 16, right: 16, bottom: 12, height: 34, borderRadius: '999px', background: p.surface, border: `1px solid ${p.border}`, display: 'flex', alignItems: 'center', justifyContent: 'space-around', px: '6px' }}>
          {[0, 1, 2, 3, 4].map(i => (
            <Box key={i} sx={{ width: i === 0 ? 24 : 6, height: i === 0 ? 24 : 6, borderRadius: '50%', background: i === 0 ? p.text : p.muted, opacity: i === 0 ? 1 : .5 }} />
          ))}
        </Box>
      </Box>
    </Box>
  )
}

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

const ThemeSwatch = ({ id }) => {
  const p = PALETTE[id === 'light' ? 'light' : 'dark']
  const split = id === 'system'

  return (
    <Box sx={{ position: 'relative', height: 64, borderRadius: 1.5, overflow: 'hidden', border: `1px solid ${p.border}`, background: p.bg, mb: 1.5 }}>
      {split && <Box sx={{ position: 'absolute', inset: '0 0 0 50%', background: PALETTE.light.bg }} />}
      <Box sx={{ position: 'absolute', left: 8, top: 8, width: 46, height: 8, borderRadius: '999px', background: p.surface2 }} />
      <Box sx={{ position: 'absolute', left: 8, top: 22, right: split ? '52%' : 8, bottom: 8, borderRadius: 1, background: p.surface, border: `1px solid ${p.border}` }} />
      {split && <Box sx={{ position: 'absolute', left: '52%', top: 22, right: 8, bottom: 8, borderRadius: 1, background: PALETTE.light.surface, border: `1px solid ${PALETTE.light.border}` }} />}
    </Box>
  )
}

const AppearanceSettings = () => {
  const dispatch = useDispatch()
  const { loading, saving, error, appearance, options } = useSelector(s => s.appearance)
  const [draft, setDraft] = useState(null)

  useEffect(() => {
    dispatch(fetchAppearance())
  }, [dispatch])

  useEffect(() => {
    if (appearance) setDraft(appearance)
  }, [appearance])

  const dirty = useMemo(() => JSON.stringify(draft) !== JSON.stringify(appearance), [draft, appearance])
  const accents = options?.accents?.length ? options.accents : []
  const accent = accents.find(a => a.id === draft?.accent) || accents[0] || { primary: '#FF3D8A', deep: '#E11D74', light: '#FF5FA2' }

  const set = patch => setDraft(d => ({ ...d, ...patch }))

  const save = () => dispatch(updateAppearance(draft))
  const reset = () => setDraft(appearance)

  if (loading && !draft) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error && !draft) return <Alert severity='error'>{error}</Alert>
  if (!draft) return null

  const previewMode = draft.defaultTheme === 'system' ? 'dark' : draft.defaultTheme

  return (
    <Grid container spacing={6}>
      <Grid item size={{ xs: 12, lg: 8 }}>
        <Alert severity='info' sx={{ mb: 4 }}>
          Changes apply to every user the next time the app launches (settings are fetched on the splash screen). A user’s own theme pick
          is kept on their phone and wins only while <strong>Let users choose</strong> is on.
        </Alert>

        <Section
          title='Theme'
          subtitle='Default look for everyone, and whether users may override it.'
          action={
            <Chip
              size='small'
              color={draft.allowUserThemeChoice ? 'success' : 'default'}
              label={draft.allowUserThemeChoice ? 'Users can switch' : 'Locked to default'}
            />
          }
        >
          <Grid container spacing={3}>
            {THEME_CARDS.map(t => (
              <Grid item size={{ xs: 12, sm: 4 }} key={t.id}>
                <OptionCard selected={draft.defaultTheme === t.id} onClick={() => set({ defaultTheme: t.id })}>
                  <ThemeSwatch id={t.id} />
                  <Typography fontWeight={700}>{t.label}</Typography>
                  <Typography variant='caption' color='text.secondary'>
                    {t.hint}
                  </Typography>
                </OptionCard>
              </Grid>
            ))}
          </Grid>
          <Divider sx={{ my: 3 }} />
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 4 }}>
            <FormControlLabel
              control={<Switch checked={draft.allowUserThemeChoice} onChange={e => set({ allowUserThemeChoice: e.target.checked })} />}
              label={
                <Box>
                  <Typography>Let users choose</Typography>
                  <Typography variant='caption' color='text.secondary'>
                    Shows System / Dark / Light on the profile page.
                  </Typography>
                </Box>
              }
            />
            <FormControlLabel
              control={
                <Switch
                  checked={draft.askThemeOnOnboarding}
                  disabled={!draft.allowUserThemeChoice}
                  onChange={e => set({ askThemeOnOnboarding: e.target.checked })}
                />
              }
              label={
                <Box>
                  <Typography>Ask during onboarding</Typography>
                  <Typography variant='caption' color='text.secondary'>
                    Adds a “Pick your look” step for first-time users.
                  </Typography>
                </Box>
              }
            />
          </Box>
        </Section>

        <Section title='Accent colour' subtitle='Primary buttons, gradients, live indicators and the call button.'>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2 }}>
            {accents.map(a => (
              <Tooltip title={a.label} key={a.id}>
                <Box
                  onClick={() => set({ accent: a.id })}
                  sx={{
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: 1.5,
                    pr: 2,
                    pl: 1,
                    py: 1,
                    borderRadius: '999px',
                    border: theme => `2px solid ${draft.accent === a.id ? theme.palette.primary.main : theme.palette.divider}`
                  }}
                >
                  <Box sx={{ width: 28, height: 28, borderRadius: '50%', background: `linear-gradient(135deg, ${a.light}, ${a.deep})`, boxShadow: `0 6px 14px ${a.primary}55` }} />
                  <Typography variant='body2' fontWeight={600}>
                    {a.label}
                  </Typography>
                </Box>
              </Tooltip>
            ))}
          </Box>
        </Section>

        <Section title='Shape & motion' subtitle='Corner radius of cards and how much the interface animates.'>
          <Grid container spacing={4}>
            <Grid item size={{ xs: 12, md: 6 }}>
              <Typography variant='subtitle2' sx={{ mb: 1.5 }}>
                Corner style
              </Typography>
              <Box sx={{ display: 'flex', gap: 2 }}>
                {CORNERS.map(c => (
                  <OptionCard key={c.id} selected={draft.cornerStyle === c.id} onClick={() => set({ cornerStyle: c.id })} sx={{ flex: 1, textAlign: 'center', p: 1.5 }}>
                    <Box sx={{ height: 34, borderRadius: `${c.radius / 1.6}px`, background: theme => theme.palette.action.selected, mb: 1 }} />
                    <Typography variant='body2' fontWeight={600}>
                      {c.label}
                    </Typography>
                  </OptionCard>
                ))}
              </Box>
            </Grid>
            <Grid item size={{ xs: 12, md: 6 }}>
              <Typography variant='subtitle2' sx={{ mb: 1.5 }}>
                Motion
              </Typography>
              <Select
                fullWidth
                size='small'
                value={draft.motion}
                onChange={e => set({ motion: e.target.value })}
                renderValue={v => MOTION.find(m => m.id === v)?.label}
              >
                {MOTION.map(m => (
                  <MenuItem key={m.id} value={m.id}>
                    <Box>
                      <Typography variant='body2'>{m.label}</Typography>
                      <Typography variant='caption' color='text.secondary'>
                        {m.hint}
                      </Typography>
                    </Box>
                  </MenuItem>
                ))}
              </Select>
            </Grid>
          </Grid>
        </Section>

        <Section title='Effects' subtitle='Individual visual effects. Turning these off also helps on low-end phones.'>
          <Grid container spacing={2}>
            {[
              ['ambientGlow', 'Ambient glow', 'Soft violet / accent glows behind Home, Random match and onboarding.'],
              ['liveRings', 'Ringing call buttons', 'Call buttons wiggle with expanding rings when a host is live.'],
              ['coinAnimation', 'Coin animation', 'The balance coin flips and sweeps every few seconds.']
            ].map(([key, label, hint]) => (
              <Grid item size={{ xs: 12, md: 4 }} key={key}>
                <FormControlLabel
                  sx={{ alignItems: 'flex-start', m: 0 }}
                  control={<Switch checked={draft[key]} disabled={draft.motion === 'reduced' && key !== 'ambientGlow'} onChange={e => set({ [key]: e.target.checked })} />}
                  label={
                    <Box sx={{ pt: 0.75 }}>
                      <Typography>{label}</Typography>
                      <Typography variant='caption' color='text.secondary'>
                        {hint}
                        {draft.motion === 'reduced' && key !== 'ambientGlow' ? ' Off while motion is reduced.' : ''}
                      </Typography>
                    </Box>
                  }
                />
              </Grid>
            ))}
          </Grid>
        </Section>

        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
          <Button variant='outlined' color='secondary' disabled={!dirty || saving} onClick={reset}>
            Discard
          </Button>
          <Button variant='contained' disabled={!dirty || saving} onClick={save} startIcon={saving ? <CircularProgress size={16} color='inherit' /> : null}>
            {saving ? 'Saving…' : 'Save appearance'}
          </Button>
        </Box>
      </Grid>

      <Grid item size={{ xs: 12, lg: 4 }}>
        <Box sx={{ position: { lg: 'sticky' }, top: 96, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}>
          <Typography variant='subtitle2' color='text.secondary'>
            Live preview · {draft.defaultTheme === 'system' ? 'System (shown dark)' : THEME_CARDS.find(t => t.id === draft.defaultTheme)?.label}
          </Typography>
          <PhonePreview draft={draft} accent={accent} mode={previewMode} />
          {draft.defaultTheme === 'system' && (
            <Box sx={{ mt: 1 }}>
              <PhonePreview draft={draft} accent={accent} mode='light' />
            </Box>
          )}
        </Box>
      </Grid>
    </Grid>
  )
}

export default AppearanceSettings
