'use client'

import React, { useEffect, useState } from 'react'

import {
  Alert,
  Autocomplete,
  Box,
  Button,
  Chip,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControl,
  FormControlLabel,
  Grid,
  InputLabel,
  MenuItem,
  Select,
  Switch,
  TextField,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import CustomAvatar from '@core/components/mui/Avatar'
import DialogCloseButton from '@/components/dialogs/DialogCloseButton'
import { fetchAiConfig, fetchListenerAiProfile, updateListenerAiProfile } from '@/redux-store/slices/aiChat'
import { getFullImageUrl } from '@/utils/commonfunctions'

const PERSONA_TEMPLATES = [
  {
    label: 'Kerala nursing student',
    text: 'Final-year nursing student from Thrissur living in a Kochi hostel. Loves Mohanlal movies, rain, chai at the tea kada and late-night talks. Playful, teases a little, very caring when someone is low.'
  },
  {
    label: 'Chennai IT professional',
    text: 'Software tester in Chennai, 26. Weekend beach walks at Besant Nagar, filter coffee addict, loves Vijay films and cricket banter. Calm, witty, good listener.'
  },
  {
    label: 'Bengaluru café owner',
    text: 'Runs a tiny café in Indiranagar. Loves indie music, traffic complaints, weekend treks. Confident, warm, asks lots of questions about the other person.'
  },
  {
    label: 'Mumbai dance teacher',
    text: 'Bollywood dance instructor in Andheri. High energy, uses Hinglish, loves street food and monsoon. Encouraging and a bit dramatic in a fun way.'
  }
]

const empty = { enabled: true, language: '', tone: '', persona: '', interests: [], openingLine: '', callNudge: 'inherit', extraRules: '' }

const AiPersonaDialog = ({ open, onClose, listener, onSaved }) => {
  const dispatch = useDispatch()
  const { languages, tones, aiChat } = useSelector(state => state.aiChat)

  const [form, setForm] = useState(empty)
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!open || !listener?._id) return
    if (!languages.length) dispatch(fetchAiConfig())
    setLoading(true)
    dispatch(fetchListenerAiProfile(listener._id))
      .unwrap()
      .then(p => setForm({ ...empty, ...p, interests: p.interests || [] }))
      .catch(() => setForm(empty))
      .finally(() => setLoading(false))
  }, [open, listener?._id, dispatch, languages.length])

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))

  const save = async () => {
    setSaving(true)

    try {
      const saved = await dispatch(updateListenerAiProfile({ listenerId: listener._id, profile: form })).unwrap()

      onSaved?.(saved)
      onClose()
    } catch (e) {
      // toast handled in thunk
    } finally {
      setSaving(false)
    }
  }

  const defaultLang = languages.find(l => l.id === aiChat?.defaultLanguage)
  const defaultTone = tones.find(t => t.id === aiChat?.tone)

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth='md' PaperProps={{ sx: { overflow: 'visible' } }}>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 3, pr: 12 }}>
        <CustomAvatar src={listener?.image ? getFullImageUrl(listener.image) : undefined} size={44}>
          {listener?.name?.[0]}
        </CustomAvatar>
        <Box>
          <Typography variant='h5' component='div'>
            AI persona · {listener?.name}
          </Typography>
          <Typography variant='body2' color='text.secondary'>
            How this host talks when a user messages her.
          </Typography>
        </Box>
        <DialogCloseButton onClick={onClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent sx={{ pt: 1 }}>
        {loading ? (
          <Box sx={{ display: 'grid', placeItems: 'center', py: 8 }}>
            <CircularProgress />
          </Box>
        ) : (
          <Grid container spacing={4} sx={{ mt: 1 }}>
            {aiChat && !aiChat.enabled && (
              <Grid size={{ xs: 12 }}>
                <Alert severity='warning'>
                  AI chat is turned off globally. This persona is saved but will not reply until you enable it in
                  Settings → AI Chat.
                </Alert>
              </Grid>
            )}
            <Grid size={{ xs: 12 }}>
              <FormControlLabel
                control={<Switch checked={!!form.enabled} onChange={e => set('enabled', e.target.checked)} color='success' />}
                label={<Typography fontWeight={600}>{form.enabled ? 'AI replies on for this host' : 'AI replies off for this host'}</Typography>}
              />
            </Grid>
            <Grid size={{ xs: 12, md: 6 }}>
              <FormControl fullWidth>
                <InputLabel>Language</InputLabel>
                <Select label='Language' value={form.language} onChange={e => set('language', e.target.value)}>
                  <MenuItem value=''>
                    <em>Use default{defaultLang ? ` (${defaultLang.label})` : ''}</em>
                  </MenuItem>
                  {languages.map(l => (
                    <MenuItem key={l.id} value={l.id}>
                      <Box>
                        <Typography>{l.label}</Typography>
                        <Typography variant='caption' color='text.secondary'>
                          {l.native} · {l.region}
                        </Typography>
                      </Box>
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid size={{ xs: 12, md: 6 }}>
              <FormControl fullWidth>
                <InputLabel>Tone</InputLabel>
                <Select label='Tone' value={form.tone} onChange={e => set('tone', e.target.value)}>
                  <MenuItem value=''>
                    <em>Use default{defaultTone ? ` (${defaultTone.label})` : ''}</em>
                  </MenuItem>
                  {tones.map(t => (
                    <MenuItem key={t.id} value={t.id}>
                      {t.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid size={{ xs: 12 }}>
              <TextField
                fullWidth
                multiline
                minRows={4}
                label='Personality & backstory'
                placeholder='Who is she? Where does she live, what does she do, what does she love, how does she text?'
                value={form.persona}
                onChange={e => set('persona', e.target.value)}
                helperText={`${form.persona.length}/1200 · the profile intro and talk topics are already included automatically`}
                inputProps={{ maxLength: 1200 }}
              />
              <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mt: 1.5 }}>
                <Typography variant='caption' color='text.secondary' sx={{ alignSelf: 'center' }}>
                  Templates:
                </Typography>
                {PERSONA_TEMPLATES.map(t => (
                  <Chip key={t.label} size='small' label={t.label} onClick={() => set('persona', t.text)} />
                ))}
              </Box>
            </Grid>
            <Grid size={{ xs: 12, md: 6 }}>
              <Autocomplete
                multiple
                freeSolo
                options={['Movies', 'Music', 'Travel', 'Food', 'Cricket', 'Relationships', 'Career', 'Fitness', 'Rain', 'Late-night talks']}
                value={form.interests}
                onChange={(_, v) => set('interests', v.slice(0, 12))}
                renderTags={(value, getTagProps) =>
                  value.map((option, index) => <Chip variant='tonal' size='small' label={option} {...getTagProps({ index })} key={option} />)
                }
                renderInput={params => <TextField {...params} label='Interests' helperText='Press Enter to add' />}
              />
            </Grid>
            <Grid size={{ xs: 12, md: 6 }}>
              <FormControl fullWidth>
                <InputLabel>Suggest calls</InputLabel>
                <Select label='Suggest calls' value={form.callNudge} onChange={e => set('callNudge', e.target.value)}>
                  <MenuItem value='inherit'>Use global setting</MenuItem>
                  <MenuItem value='on'>Yes, nudge towards calls</MenuItem>
                  <MenuItem value='off'>Never suggest a call</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid size={{ xs: 12, md: 6 }}>
              <TextField
                fullWidth
                label='Opening line (optional)'
                placeholder='Sent as the very first reply instead of AI, e.g. “Hii! Njan Anjali 😊 ninte peru enthaa?”'
                value={form.openingLine}
                onChange={e => set('openingLine', e.target.value)}
              />
            </Grid>
            <Grid size={{ xs: 12, md: 6 }}>
              <TextField
                fullWidth
                label='Extra rules for this host'
                placeholder='e.g. Never mention her hometown. Always call the user “chetta”.'
                value={form.extraRules}
                onChange={e => set('extraRules', e.target.value)}
              />
            </Grid>
          </Grid>
        )}
      </DialogContent>

      <DialogActions className='p-6 pt-2'>
        <Button variant='outlined' color='secondary' onClick={onClose}>
          Cancel
        </Button>
        <Button variant='contained' onClick={save} disabled={saving || loading} startIcon={saving ? <CircularProgress size={16} sx={{ color: 'white' }} /> : <i className='tabler-device-floppy' />}>
          Save persona
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default AiPersonaDialog
