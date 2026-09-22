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
  MenuItem,
  Switch,
  Tab,
  Tabs,
  TextField,
  Tooltip,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import { baseURL } from '@/config'
import {
  addAvatarItem,
  deleteAvatarItem,
  editAvatarItem,
  fetchAvatarStudio,
  toggleAvatarItem,
  updateAvatarStudioSettings
} from '@/redux-store/slices/avatarStudio'

const CATEGORY_META = {
  avatar: { label: 'Avatars', hint: 'The face users pick. Shown as their profile picture.' },
  background: { label: 'Scenes', hint: 'Gradient backdrops (3 hex colours) with a soft decor image.' },
  accessory: { label: 'Style', hint: 'Worn on the avatar: crowns, hats, shades, headphones.' },
  pet: { label: 'Pets', hint: 'Sits beside the avatar.' },
  vehicle: { label: 'Rides', hint: 'Parked in front of the stage.' },
  home: { label: 'Homes', hint: 'Shown behind the avatar.' },
  sky: { label: 'Sky', hint: 'Floats above the scene: jets, helicopters, UFOs.' }
}

const RARITY_COLOR = { common: '#9CA3AF', rare: '#38BDF8', epic: '#A855F7', legendary: '#FBBF24' }

const imageUrl = path => (!path ? '' : path.startsWith('http') ? path : `${baseURL}/${path.replace(/\\/g, '/')}`)

const EMPTY = { name: '', category: 'pet', rarity: 'rare', gender: 'any', coins: 100, sortOrder: 0, colors: '', isActive: true }

const ItemDialog = ({ open, item, options, onClose, onSave, saving }) => {
  const [form, setForm] = useState(EMPTY)
  const [file, setFile] = useState(null)
  const [preview, setPreview] = useState('')

  useEffect(() => {
    if (!open) return
    setFile(null)
    setForm(item ? { ...EMPTY, ...item, colors: (item.colors || []).join(', ') } : EMPTY)
    setPreview(item ? imageUrl(item.image) : '')
  }, [open, item])

  const set = patch => setForm(f => ({ ...f, ...patch }))

  const pick = e => {
    const f = e.target.files?.[0]

    if (!f) return
    setFile(f)
    setPreview(URL.createObjectURL(f))
  }

  const valid = form.name.trim() && form.category && (form.category === 'background' || preview)

  return (
    <Dialog open={open} onClose={onClose} maxWidth='sm' fullWidth>
      <DialogTitle>{item ? `Edit ${item.name}` : 'Add item'}</DialogTitle>
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
                background: form.category === 'background' && form.colors ? `linear-gradient(135deg, ${form.colors})` : 'rgba(127,127,127,.06)',
                overflow: 'hidden'
              }}
            >
              {preview ? <img src={preview} alt='' style={{ width: '80%', height: '80%', objectFit: 'contain' }} /> : <Typography variant='caption' color='text.secondary' textAlign='center'>Click to upload<br />PNG / WebP, transparent</Typography>}
              <input hidden type='file' accept='image/*' onChange={pick} />
            </Box>
            <Typography variant='caption' color='text.secondary' sx={{ display: 'block', mt: 1 }}>
              Square, transparent 3D render works best (512px).
            </Typography>
          </Grid>
          <Grid item size={{ xs: 12, sm: 8 }}>
            <Grid container spacing={2}>
              <Grid item size={{ xs: 12 }}>
                <TextField fullWidth label='Name' value={form.name} onChange={e => set({ name: e.target.value })} />
              </Grid>
              <Grid item size={{ xs: 6 }}>
                <TextField select fullWidth label='Category' value={form.category} onChange={e => set({ category: e.target.value })} disabled={!!item}>
                  {options.categories.map(c => (
                    <MenuItem key={c} value={c}>
                      {CATEGORY_META[c]?.label || c}
                    </MenuItem>
                  ))}
                </TextField>
              </Grid>
              <Grid item size={{ xs: 6 }}>
                <TextField select fullWidth label='Rarity' value={form.rarity} onChange={e => set({ rarity: e.target.value })}>
                  {options.rarities.map(r => (
                    <MenuItem key={r} value={r}>
                      {r}
                    </MenuItem>
                  ))}
                </TextField>
              </Grid>
              <Grid item size={{ xs: 6 }}>
                <TextField fullWidth type='number' label='Price (coins, 0 = free)' value={form.coins} onChange={e => set({ coins: Math.max(0, parseInt(e.target.value || '0', 10)) })} />
              </Grid>
              <Grid item size={{ xs: 6 }}>
                <TextField fullWidth type='number' label='Sort order' value={form.sortOrder} onChange={e => set({ sortOrder: parseInt(e.target.value || '0', 10) })} />
              </Grid>
              {form.category === 'avatar' && (
                <Grid item size={{ xs: 12 }}>
                  <TextField select fullWidth label='Gender' value={form.gender} onChange={e => set({ gender: e.target.value })}>
                    {options.genders.map(g => (
                      <MenuItem key={g} value={g}>
                        {g}
                      </MenuItem>
                    ))}
                  </TextField>
                </Grid>
              )}
              {form.category === 'background' && (
                <Grid item size={{ xs: 12 }}>
                  <TextField fullWidth label='Gradient colours' placeholder='#1B1033, #3A1C71, #0E0B14' value={form.colors} onChange={e => set({ colors: e.target.value })} helperText='Two or three hex colours, comma separated' />
                </Grid>
              )}
              <Grid item size={{ xs: 12 }}>
                <FormControlLabel control={<Switch checked={form.isActive} onChange={e => set({ isActive: e.target.checked })} />} label='Live in the app' />
              </Grid>
            </Grid>
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} color='secondary'>
          Cancel
        </Button>
        <Button
          variant='contained'
          disabled={!valid || saving}
          startIcon={saving ? <CircularProgress size={16} color='inherit' /> : null}
          onClick={() => onSave({ ...form, colors: form.colors, image: file || undefined })}
        >
          {item ? 'Save changes' : 'Add item'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

const ItemTile = ({ item, onEdit, onToggle, onDelete }) => {
  const color = RARITY_COLOR[item.rarity] || RARITY_COLOR.common
  const bg = item.category === 'background' && item.colors?.length >= 2 ? `linear-gradient(135deg, ${item.colors.join(', ')})` : `linear-gradient(180deg, ${color}22, transparent 70%)`

  return (
    <Card variant='outlined' sx={{ opacity: item.isActive ? 1 : 0.55, borderColor: `${color}55`, position: 'relative' }}>
      <Box sx={{ background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center', height: 120 }}>
        {item.image && <img src={imageUrl(item.image)} alt={item.name} style={{ width: 88, height: 88, objectFit: 'contain', filter: 'drop-shadow(0 8px 12px rgba(0,0,0,.35))' }} />}
      </Box>
      <Chip size='small' label={item.rarity} sx={{ position: 'absolute', top: 8, left: 8, bgcolor: `${color}33`, color, fontWeight: 700, textTransform: 'uppercase', fontSize: 10 }} />
      {!item.isActive && <Chip size='small' label='Hidden' color='default' sx={{ position: 'absolute', top: 8, right: 8 }} />}
      <CardContent sx={{ p: 1.5, '&:last-child': { pb: 1.5 } }}>
        <Box display='flex' justifyContent='space-between' alignItems='center' gap={1}>
          <Typography variant='body2' fontWeight={600} noWrap>
            {item.name}
          </Typography>
          <Typography variant='caption' fontWeight={700} color={item.coins > 0 ? 'warning.main' : 'success.main'}>
            {item.coins > 0 ? `${item.coins} coins` : 'Free'}
          </Typography>
        </Box>
        <Typography variant='caption' color='text.secondary'>
          {item.gender !== 'any' ? `${item.gender} · ` : ''}
          {item.unlockCount || 0} unlocks
        </Typography>
        <Box display='flex' gap={0.5} mt={1}>
          <Button size='small' variant='outlined' onClick={onEdit} sx={{ flex: 1 }}>
            Edit
          </Button>
          <Tooltip title={item.isActive ? 'Hide from users' : 'Show to users'}>
            <IconButton size='small' onClick={onToggle}>
              <i className={item.isActive ? 'tabler-eye' : 'tabler-eye-off'} style={{ fontSize: 18 }} />
            </IconButton>
          </Tooltip>
          <Tooltip title='Delete (only when nobody has it equipped)'>
            <IconButton size='small' color='error' onClick={onDelete}>
              <i className='tabler-trash' style={{ fontSize: 18 }} />
            </IconButton>
          </Tooltip>
        </Box>
      </CardContent>
    </Card>
  )
}

const AvatarStudioSettings = () => {
  const dispatch = useDispatch()
  const { loading, saving, settings, items, stats, options } = useSelector(s => s.avatarStudio)
  const [category, setCategory] = useState('avatar')
  const [dialog, setDialog] = useState({ open: false, item: null })
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    dispatch(fetchAvatarStudio())
  }, [dispatch])

  const visible = useMemo(() => items.filter(i => i.category === category).sort((a, b) => a.sortOrder - b.sortOrder), [items, category])
  const counts = useMemo(() => items.reduce((acc, i) => ({ ...acc, [i.category]: (acc[i.category] || 0) + 1 }), {}), [items])

  const save = async fields => {
    setBusy(true)

    try {
      if (dialog.item) await dispatch(editAvatarItem({ itemId: dialog.item._id, ...fields })).unwrap()
      else await dispatch(addAvatarItem(fields)).unwrap()
      setDialog({ open: false, item: null })
    } catch {
      /* toast shown by thunk */
    } finally {
      setBusy(false)
    }
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
                <Typography variant='h5'>Avatar Studio</Typography>
                <Typography variant='body2' color='text.secondary'>
                  Users build a 3D look (avatar, scene, pet, ride, home, sky, style) and unlock premium items with coins. Off = classic photo upload plus three male / three female presets.
                </Typography>
              </Box>
              <Box display='flex' gap={3}>
                {[
                  ['Items', stats.items],
                  ['Users with a 3D look', stats.usingAvatar],
                  ['Total unlocks', stats.unlocks]
                ].map(([l, v]) => (
                  <Box key={l} textAlign='center'>
                    <Typography variant='h5'>{v}</Typography>
                    <Typography variant='caption' color='text.secondary'>
                      {l}
                    </Typography>
                  </Box>
                ))}
              </Box>
            </Box>
            <Divider sx={{ my: 3 }} />
            <Grid container spacing={2}>
              <Grid item size={{ xs: 12, md: 6 }}>
                <FormControlLabel
                  control={<Switch checked={settings?.enabled !== false} disabled={saving} onChange={e => dispatch(updateAvatarStudioSettings({ enabled: e.target.checked }))} />}
                  label={
                    <Box>
                      <Typography variant='body2' fontWeight={600}>
                        Avatar Studio enabled
                      </Typography>
                      <Typography variant='caption' color='text.secondary'>
                        Turning it off hides the studio; profiles fall back to a photo or the six preset pictures. Unlocked items are kept.
                      </Typography>
                    </Box>
                  }
                />
              </Grid>
              <Grid item size={{ xs: 12, md: 6 }}>
                <FormControlLabel
                  control={<Switch checked={settings?.allowPhotoUpload !== false} disabled={saving} onChange={e => dispatch(updateAvatarStudioSettings({ allowPhotoUpload: e.target.checked }))} />}
                  label={
                    <Box>
                      <Typography variant='body2' fontWeight={600}>
                        Allow real photo upload
                      </Typography>
                      <Typography variant='caption' color='text.secondary'>
                        Off = users can only use studio avatars or presets (no camera / gallery).
                      </Typography>
                    </Box>
                  }
                />
              </Grid>
            </Grid>
            {settings?.enabled === false && (
              <Alert severity='warning' sx={{ mt: 2 }}>
                The studio is off. Users see photo upload and the three male / three female preset avatars (the free “Classic / Fair / Deep” items below).
              </Alert>
            )}
          </CardContent>
        </Card>
      </Grid>

      <Grid item size={{ xs: 12 }}>
        <Card>
          <Box display='flex' alignItems='center' justifyContent='space-between' px={2} pt={1} flexWrap='wrap' gap={1}>
            <Tabs value={category} onChange={(_, v) => setCategory(v)} variant='scrollable' scrollButtons='auto'>
              {options.categories.map(c => (
                <Tab key={c} value={c} label={`${CATEGORY_META[c]?.label || c} (${counts[c] || 0})`} />
              ))}
            </Tabs>
            <Button variant='contained' onClick={() => setDialog({ open: true, item: null })} startIcon={<i className='tabler-plus' />}>
              Add item
            </Button>
          </Box>
          <Divider />
          <CardContent>
            <Typography variant='body2' color='text.secondary' sx={{ mb: 2 }}>
              {CATEGORY_META[category]?.hint}
            </Typography>
            {visible.length === 0 ? (
              <Alert severity='info'>No items in this category yet.</Alert>
            ) : (
              <Grid container spacing={2}>
                {visible.map(item => (
                  <Grid item size={{ xs: 12, sm: 6, md: 4, lg: 3, xl: 2 }} key={item._id}>
                    <ItemTile
                      item={item}
                      onEdit={() => setDialog({ open: true, item })}
                      onToggle={() => dispatch(toggleAvatarItem(item._id))}
                      onDelete={() => {
                        if (window.confirm(`Delete “${item.name}”? Users who unlocked it lose it.`)) dispatch(deleteAvatarItem(item._id))
                      }}
                    />
                  </Grid>
                ))}
              </Grid>
            )}
          </CardContent>
        </Card>
      </Grid>

      <ItemDialog open={dialog.open} item={dialog.item} options={options} saving={busy} onClose={() => setDialog({ open: false, item: null })} onSave={save} />
    </Grid>
  )
}

export default AvatarStudioSettings
