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
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Divider,
  FormControlLabel,
  Grid,
  IconButton,
  InputAdornment,
  Slider,
  Switch,
  TextField,
  Tooltip,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import { baseURL } from '@/config'
import { addGift, deleteGift, editGift, fetchGiftCatalog, reorderGifts, toggleGift, updateGiftSettings } from '@/redux-store/slices/giftCatalog'

const imageUrl = path => (!path ? '' : path.startsWith('http') ? path : `${baseURL}/${path.replace(/\\/g, '/')}`)

const EMPTY = { name: '', tagline: '', coins: 50, accent: '#FF4D6D', isActive: true }

const fmt = n => (n || 0).toLocaleString()

const GiftDialog = ({ open, gift, onClose, onSave, saving }) => {
  const [form, setForm] = useState(EMPTY)
  const [file, setFile] = useState(null)
  const [preview, setPreview] = useState('')

  useEffect(() => {
    if (!open) return
    setFile(null)
    setForm(gift ? { ...EMPTY, ...gift } : EMPTY)
    setPreview(gift ? imageUrl(gift.image) : '')
  }, [open, gift])

  const set = patch => setForm(f => ({ ...f, ...patch }))

  const pick = e => {
    const f = e.target.files?.[0]

    if (!f) return
    setFile(f)
    setPreview(URL.createObjectURL(f))
  }

  const valid = form.name.trim() && form.coins > 0 && preview

  return (
    <Dialog open={open} onClose={onClose} maxWidth='sm' fullWidth>
      <DialogTitle>{gift ? `Edit ${gift.name}` : 'Add a gift'}</DialogTitle>
      <DialogContent dividers>
        <Grid container spacing={3}>
          <Grid item size={{ xs: 12, sm: 4 }}>
            <Box
              component='label'
              sx={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                aspectRatio: '1',
                borderRadius: 3,
                border: '1px dashed',
                borderColor: 'divider',
                cursor: 'pointer',
                background: `radial-gradient(circle at 50% 40%, ${form.accent}55, transparent 70%)`,
                overflow: 'hidden'
              }}
            >
              {preview ? (
                <img src={preview} alt='' style={{ width: '78%', height: '78%', objectFit: 'contain', filter: 'drop-shadow(0 10px 14px rgba(0,0,0,.35))' }} />
              ) : (
                <Typography variant='caption' color='text.secondary' textAlign='center'>
                  Click to upload
                  <br />
                  PNG, transparent
                </Typography>
              )}
              <input hidden type='file' accept='image/*' onChange={pick} />
            </Box>
            <Typography variant='caption' color='text.secondary' sx={{ display: 'block', mt: 1 }}>
              Square 3D render on a transparent background, 256–512px. The glow colour below is used in the app animation.
            </Typography>
          </Grid>
          <Grid item size={{ xs: 12, sm: 8 }}>
            <Grid container spacing={2}>
              <Grid item size={{ xs: 12 }}>
                <TextField fullWidth label='Name' value={form.name} onChange={e => set({ name: e.target.value })} inputProps={{ maxLength: 40 }} helperText='Short names fit the grid best (e.g. Rose, Crown).' />
              </Grid>
              <Grid item size={{ xs: 12 }}>
                <TextField fullWidth label='Tagline (shown when selected)' value={form.tagline} onChange={e => set({ tagline: e.target.value })} inputProps={{ maxLength: 80 }} />
              </Grid>
              <Grid item size={{ xs: 6 }}>
                <TextField
                  fullWidth
                  type='number'
                  label='Price'
                  value={form.coins}
                  onChange={e => set({ coins: Math.max(1, parseInt(e.target.value || '1', 10)) })}
                  InputProps={{ endAdornment: <InputAdornment position='end'>coins</InputAdornment> }}
                />
              </Grid>
              <Grid item size={{ xs: 6 }}>
                <TextField
                  fullWidth
                  label='Glow colour'
                  value={form.accent}
                  onChange={e => set({ accent: e.target.value })}
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position='start'>
                        <input type='color' value={/^#[0-9a-fA-F]{6}$/.test(form.accent) ? form.accent : '#FF4D6D'} onChange={e => set({ accent: e.target.value })} style={{ width: 24, height: 24, border: 0, background: 'none', padding: 0, cursor: 'pointer' }} />
                      </InputAdornment>
                    )
                  }}
                />
              </Grid>
              <Grid item size={{ xs: 12 }}>
                <FormControlLabel control={<Switch checked={form.isActive !== false} onChange={e => set({ isActive: e.target.checked })} />} label='Visible to users' />
              </Grid>
            </Grid>
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} disabled={saving}>
          Cancel
        </Button>
        <Button variant='contained' disabled={!valid || saving} onClick={() => onSave({ name: form.name.trim(), tagline: form.tagline.trim(), coins: form.coins, accent: form.accent, isActive: form.isActive, ...(file ? { image: file } : {}) })}>
          {saving ? 'Saving…' : gift ? 'Save changes' : 'Add gift'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

const GiftTile = ({ gift, hostShare, onEdit, onToggle, onDelete, onMove, first, last }) => {
  const host = Math.floor((gift.coins * hostShare) / 100)

  return (
    <Card variant='outlined' sx={{ opacity: gift.isActive ? 1 : 0.55, borderColor: `${gift.accent}66`, position: 'relative', height: '100%' }}>
      <Box sx={{ background: `radial-gradient(circle at 50% 45%, ${gift.accent}44, transparent 68%)`, display: 'flex', alignItems: 'center', justifyContent: 'center', height: 130 }}>
        {gift.image && <img src={imageUrl(gift.image)} alt={gift.name} style={{ width: 92, height: 92, objectFit: 'contain', filter: 'drop-shadow(0 10px 14px rgba(0,0,0,.35))' }} />}
      </Box>
      <Chip size='small' label={`${fmt(gift.coins)} coins`} sx={{ position: 'absolute', top: 8, left: 8, bgcolor: `${gift.accent}33`, color: gift.accent, fontWeight: 700, fontSize: 11 }} />
      {gift.coins >= 500 && <Chip size='small' label='VIP' color='secondary' sx={{ position: 'absolute', top: 8, right: 8, fontWeight: 700, fontSize: 10 }} />}
      {!gift.isActive && <Chip size='small' label='Hidden' sx={{ position: 'absolute', top: 36, right: 8 }} />}
      <CardContent sx={{ p: 1.5, '&:last-child': { pb: 1.5 } }}>
        <Typography variant='body2' fontWeight={700} noWrap>
          {gift.name}
        </Typography>
        <Typography variant='caption' color='text.secondary' noWrap sx={{ display: 'block' }}>
          {gift.tagline || '—'}
        </Typography>
        <Box display='flex' justifyContent='space-between' mt={1}>
          <Typography variant='caption' color='text.secondary'>
            Host gets <b>{fmt(host)}</b>
          </Typography>
          <Typography variant='caption' color='text.secondary'>
            Sent <b>{fmt(gift.sentCount)}</b>
          </Typography>
        </Box>
        <Box display='flex' gap={0.5} mt={1} alignItems='center'>
          <Button size='small' variant='outlined' onClick={onEdit} sx={{ flex: 1 }}>
            Edit
          </Button>
          <Tooltip title='Move earlier'>
            <span>
              <IconButton size='small' disabled={first} onClick={() => onMove(-1)}>
                <i className='tabler-chevron-left' style={{ fontSize: 18 }} />
              </IconButton>
            </span>
          </Tooltip>
          <Tooltip title='Move later'>
            <span>
              <IconButton size='small' disabled={last} onClick={() => onMove(1)}>
                <i className='tabler-chevron-right' style={{ fontSize: 18 }} />
              </IconButton>
            </span>
          </Tooltip>
          <Tooltip title={gift.isActive ? 'Hide from users' : 'Show to users'}>
            <IconButton size='small' onClick={onToggle}>
              <i className={gift.isActive ? 'tabler-eye' : 'tabler-eye-off'} style={{ fontSize: 18 }} />
            </IconButton>
          </Tooltip>
          <Tooltip title={gift.sentCount > 0 ? 'Sent before — hide instead of deleting' : 'Delete'}>
            <span>
              <IconButton size='small' color='error' disabled={gift.sentCount > 0} onClick={onDelete}>
                <i className='tabler-trash' style={{ fontSize: 18 }} />
              </IconButton>
            </span>
          </Tooltip>
        </Box>
      </CardContent>
    </Card>
  )
}

const Toggle = ({ label, hint, checked, onChange, disabled }) => (
  <FormControlLabel
    sx={{ alignItems: 'flex-start', m: 0 }}
    control={<Switch checked={checked} disabled={disabled} onChange={e => onChange(e.target.checked)} />}
    label={
      <Box>
        <Typography variant='body2' fontWeight={600}>
          {label}
        </Typography>
        <Typography variant='caption' color='text.secondary'>
          {hint}
        </Typography>
      </Box>
    }
  />
)

const Gifts = () => {
  const dispatch = useDispatch()
  const { loading, saving, settings, gifts, stats } = useSelector(s => s.giftCatalog)
  const [dialog, setDialog] = useState({ open: false, gift: null })
  const [busy, setBusy] = useState(false)
  const [share, setShare] = useState(null)

  useEffect(() => {
    dispatch(fetchGiftCatalog())
  }, [dispatch])

  useEffect(() => {
    if (settings) setShare(settings.hostSharePercent)
  }, [settings])

  const ordered = useMemo(() => [...gifts].sort((a, b) => a.sortOrder - b.sortOrder || a.coins - b.coins), [gifts])
  const enabled = settings?.enabled !== false
  const hostShare = share ?? settings?.hostSharePercent ?? 70

  const save = async fields => {
    setBusy(true)

    try {
      if (dialog.gift) await dispatch(editGift({ giftId: dialog.gift._id, ...fields })).unwrap()
      else await dispatch(addGift(fields)).unwrap()
      setDialog({ open: false, gift: null })
    } catch {
      /* toast shown by thunk */
    } finally {
      setBusy(false)
    }
  }

  const move = (index, dir) => {
    const next = ordered.map(g => g._id)
    const j = index + dir

    if (j < 0 || j >= next.length) return
    ;[next[index], next[j]] = [next[j], next[index]]
    dispatch(reorderGifts(next))
  }

  if (loading && !settings) {
    return (
      <Box display='flex' justifyContent='center' py={10}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Grid container spacing={4}>
      <Grid item size={{ xs: 12 }}>
        <Card>
          <CardContent>
            <Box display='flex' flexWrap='wrap' alignItems='center' justifyContent='space-between' gap={2}>
              <Box>
                <Typography variant='h5'>Gifts</Typography>
                <Typography variant='body2' color='text.secondary'>
                  Users send a gift from the chat composer or during a call. Coins leave their wallet instantly; the host earns the share you set below and the rest is platform revenue.
                </Typography>
              </Box>
              <Box display='flex' gap={3} flexWrap='wrap'>
                {[
                  ['Sent · 7 days', fmt(stats.sent7d)],
                  ['Coins spent · 7 days', fmt(stats.coins7d)],
                  ['Platform coins · 7 days', fmt(stats.platformCoins7d)],
                  ['Senders · 7 days', fmt(stats.senders7d)],
                  ['Top gift', stats.topGift || '—']
                ].map(([l, v]) => (
                  <Box key={l} textAlign='center' minWidth={90}>
                    <Typography variant='h5'>{v}</Typography>
                    <Typography variant='caption' color='text.secondary'>
                      {l}
                    </Typography>
                  </Box>
                ))}
              </Box>
            </Box>
            <Divider sx={{ my: 3 }} />
            <Grid container spacing={3}>
              <Grid item size={{ xs: 12, md: 4 }}>
                <Toggle
                  label='Gifting enabled'
                  hint='Master switch. Off hides every gift button, sheet and bubble in the app — users see nothing gift-related.'
                  checked={enabled}
                  disabled={saving}
                  onChange={v => dispatch(updateGiftSettings({ enabled: v }))}
                />
              </Grid>
              <Grid item size={{ xs: 12, md: 4 }}>
                <Toggle label='Show in chat' hint='Gift button beside the message box in one-to-one chat.' checked={settings?.showInChat !== false} disabled={saving || !enabled} onChange={v => dispatch(updateGiftSettings({ showInChat: v }))} />
              </Grid>
              <Grid item size={{ xs: 12, md: 4 }}>
                <Toggle label='Show during calls' hint='Gift button in the voice and video call control bar.' checked={settings?.showInCall !== false} disabled={saving || !enabled} onChange={v => dispatch(updateGiftSettings({ showInCall: v }))} />
              </Grid>
              <Grid item size={{ xs: 12, md: 4 }}>
                <Toggle label='AI hosts say thank you' hint='AI-powered hosts reply to a gift in their configured language (uses the AI Chat settings).' checked={settings?.aiThankYou !== false} disabled={saving || !enabled} onChange={v => dispatch(updateGiftSettings({ aiThankYou: v }))} />
              </Grid>
              <Grid item size={{ xs: 12, md: 4 }}>
                <Toggle label='“Get coins” nudge' hint='When a user picks a gift they cannot afford, the button becomes a one-tap path to the wallet.' checked={settings?.minBalanceHint !== false} disabled={saving || !enabled} onChange={v => dispatch(updateGiftSettings({ minBalanceHint: v }))} />
              </Grid>
              <Grid item size={{ xs: 12, md: 4 }}>
                <Typography variant='body2' fontWeight={600}>
                  Host share: {hostShare}%
                </Typography>
                <Typography variant='caption' color='text.secondary'>
                  Of every gift’s coins, the host earns {hostShare}% and the platform keeps {100 - hostShare}%. Example: a 100-coin gift pays the host {Math.floor(hostShare)} coins.
                </Typography>
                <Box display='flex' alignItems='center' gap={2} mt={1}>
                  <Slider value={hostShare} min={0} max={100} step={5} disabled={saving || !enabled} onChange={(_, v) => setShare(v)} onChangeCommitted={(_, v) => dispatch(updateGiftSettings({ hostSharePercent: v }))} valueLabelDisplay='auto' sx={{ flex: 1 }} />
                  <TextField
                    size='small'
                    type='number'
                    value={hostShare}
                    disabled={saving || !enabled}
                    onChange={e => setShare(Math.min(100, Math.max(0, parseInt(e.target.value || '0', 10))))}
                    onBlur={() => dispatch(updateGiftSettings({ hostSharePercent: hostShare }))}
                    InputProps={{ endAdornment: <InputAdornment position='end'>%</InputAdornment> }}
                    sx={{ width: 100 }}
                  />
                </Box>
              </Grid>
            </Grid>
            {!enabled && (
              <Alert severity='warning' sx={{ mt: 3 }}>
                Gifting is off. Nothing gift-related is visible in the app right now. Your catalog and history are kept.
              </Alert>
            )}
          </CardContent>
        </Card>
      </Grid>

      <Grid item size={{ xs: 12 }}>
        <Card>
          <Box display='flex' alignItems='center' justifyContent='space-between' px={3} py={2} flexWrap='wrap' gap={1}>
            <Box>
              <Typography variant='h6'>Catalog</Typography>
              <Typography variant='caption' color='text.secondary'>
                {stats.active} live · {stats.total} total. Order here is the order in the app. Hide a gift instead of deleting once it has been sent.
              </Typography>
            </Box>
            <Button variant='contained' onClick={() => setDialog({ open: true, gift: null })} startIcon={<i className='tabler-plus' />}>
              Add gift
            </Button>
          </Box>
          <Divider />
          <CardContent>
            {ordered.length === 0 ? (
              <Alert severity='info'>No gifts yet. Add one with a transparent PNG and a coin price.</Alert>
            ) : (
              <Grid container spacing={2}>
                {ordered.map((gift, i) => (
                  <Grid item size={{ xs: 12, sm: 6, md: 4, lg: 3, xl: 2.4 }} key={gift._id}>
                    <GiftTile
                      gift={gift}
                      hostShare={hostShare}
                      first={i === 0}
                      last={i === ordered.length - 1}
                      onMove={dir => move(i, dir)}
                      onEdit={() => setDialog({ open: true, gift })}
                      onToggle={() => dispatch(toggleGift(gift._id))}
                      onDelete={() => {
                        if (window.confirm(`Delete “${gift.name}”?`)) dispatch(deleteGift(gift._id))
                      }}
                    />
                  </Grid>
                ))}
              </Grid>
            )}
          </CardContent>
        </Card>
      </Grid>

      <GiftDialog open={dialog.open} gift={dialog.gift} saving={busy} onClose={() => setDialog({ open: false, gift: null })} onSave={save} />
    </Grid>
  )
}

export default Gifts
