'use client'

import React, { useEffect, useRef, useState } from 'react'

import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  Collapse,
  FormControl,
  Grid,
  IconButton,
  InputLabel,
  MenuItem,
  Select,
  Stack,
  TextField,
  Tooltip,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import { clearPlayground, runAiPlayground } from '@/redux-store/slices/aiChat'
import { fetchListeners } from '@/redux-store/slices/listener'

const Bubble = ({ role, text }) => {
  const mine = role === 'user'

  return (
    <Box sx={{ display: 'flex', justifyContent: mine ? 'flex-end' : 'flex-start' }}>
      <Box
        sx={{
          maxWidth: '78%',
          px: 3,
          py: 2,
          borderRadius: 3,
          borderTopRightRadius: mine ? 4 : 12,
          borderTopLeftRadius: mine ? 12 : 4,
          bgcolor: mine ? 'primary.main' : 'action.hover',
          color: mine ? 'primary.contrastText' : 'text.primary',
          whiteSpace: 'pre-wrap',
          fontSize: 14,
          lineHeight: 1.5
        }}
      >
        {text}
      </Box>
    </Box>
  )
}

const AiPlayground = ({ languages, tones, defaults, disabled }) => {
  const dispatch = useDispatch()
  const { playgroundLoading, playgroundResult, playgroundError } = useSelector(state => state.aiChat)
  const { listeners } = useSelector(state => state.listener)

  const [listenerId, setListenerId] = useState('')
  const [language, setLanguage] = useState('')
  const [tone, setTone] = useState('')
  const [persona, setPersona] = useState('')
  const [input, setInput] = useState('')
  const [thread, setThread] = useState([])
  const [showPrompt, setShowPrompt] = useState(false)
  const endRef = useRef(null)

  useEffect(() => {
    dispatch(fetchListeners({ isFake: true, page: 1, limit: 100 }))
  }, [dispatch])

  useEffect(() => {
    if (playgroundResult?.reply) {
      setThread(t => [...t, { role: 'assistant', content: playgroundResult.reply, meta: playgroundResult }])
    }
  }, [playgroundResult])

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [thread, playgroundLoading])

  const fakeListeners = (listeners || []).filter(l => l && l._id)
  const selected = fakeListeners.find(l => l._id === listenerId)

  const send = () => {
    const text = input.trim()

    if (!text || playgroundLoading) return
    const next = [...thread, { role: 'user', content: text }]

    setThread(next)
    setInput('')
    dispatch(
      runAiPlayground({
        listenerId: listenerId || undefined,
        language: language || undefined,
        tone: tone || undefined,
        persona: persona || undefined,
        showPrompt: true,
        messages: next.map(({ role, content }) => ({ role, content }))
      })
    )
  }

  const reset = () => {
    setThread([])
    dispatch(clearPlayground())
  }

  const lastMeta = [...thread].reverse().find(m => m.meta)?.meta

  return (
    <Card sx={{ mb: 5 }}>
      <CardContent>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 2, mb: 3 }}>
          <Box>
            <Typography variant='h6' sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
              <i className='tabler-flask text-xl' />
              Playground
            </Typography>
            <Typography variant='body2' color='text.secondary'>
              Chat with a host persona exactly as a user would. Nothing here is saved to real conversations.
            </Typography>
          </Box>
          <Button size='small' variant='outlined' color='secondary' onClick={reset} startIcon={<i className='tabler-refresh' />}>
            New chat
          </Button>
        </Box>

        <Grid container spacing={4}>
          <Grid size={{ xs: 12, md: 4 }}>
            <Stack spacing={3}>
              <FormControl fullWidth size='small'>
                <InputLabel>Host</InputLabel>
                <Select label='Host' value={listenerId} onChange={e => setListenerId(e.target.value)}>
                  <MenuItem value=''>Sample persona (Anjali, Kochi)</MenuItem>
                  {fakeListeners.map(l => (
                    <MenuItem key={l._id} value={l._id}>
                      {l.name}
                      {l.aiProfile?.language ? ` · ${l.aiProfile.language}` : ''}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <FormControl fullWidth size='small'>
                <InputLabel>Language</InputLabel>
                <Select label='Language' value={language} onChange={e => setLanguage(e.target.value)}>
                  <MenuItem value=''>
                    Host default ({selected?.aiProfile?.language || defaults?.defaultLanguage || 'english'})
                  </MenuItem>
                  {languages.map(l => (
                    <MenuItem key={l.id} value={l.id}>
                      {l.label} · {l.native}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <FormControl fullWidth size='small'>
                <InputLabel>Tone</InputLabel>
                <Select label='Tone' value={tone} onChange={e => setTone(e.target.value)}>
                  <MenuItem value=''>Host default</MenuItem>
                  {tones.map(t => (
                    <MenuItem key={t.id} value={t.id}>
                      {t.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                size='small'
                multiline
                minRows={3}
                label='Persona override (optional)'
                placeholder='e.g. Nursing student from Thrissur, loves Mohanlal movies and rain.'
                value={persona}
                onChange={e => setPersona(e.target.value)}
              />
              {lastMeta && (
                <Alert severity='success' icon={<i className='tabler-bolt' />}>
                  <Typography variant='body2'>
                    <strong>{lastMeta.providerLabel || lastMeta.provider}</strong> · {lastMeta.model}
                  </Typography>
                  <Typography variant='caption'>
                    {lastMeta.latencyMs} ms · {lastMeta.inputTokens} in / {lastMeta.outputTokens} out tokens
                  </Typography>
                </Alert>
              )}
            </Stack>
          </Grid>

          <Grid size={{ xs: 12, md: 8 }}>
            <Box
              sx={{
                border: '1px solid',
                borderColor: 'divider',
                borderRadius: 2,
                height: 380,
                display: 'flex',
                flexDirection: 'column',
                overflow: 'hidden'
              }}
            >
              <Box sx={{ flex: 1, overflowY: 'auto', p: 3, display: 'flex', flexDirection: 'column', gap: 2 }}>
                {thread.length === 0 && (
                  <Box sx={{ m: 'auto', textAlign: 'center', color: 'text.disabled' }}>
                    <i className='tabler-messages text-4xl' />
                    <Typography variant='body2' sx={{ mt: 1 }}>
                      {disabled ? 'Add a provider with an API key first.' : 'Say hi to see how the host replies.'}
                    </Typography>
                    {!disabled && (
                      <Stack direction='row' spacing={1} justifyContent='center' sx={{ mt: 2, flexWrap: 'wrap', gap: 1 }}>
                        {['Hi, enthokke undu?', 'Ninte peru enthaa?', 'Innu njan valare bored aanu', 'Are you a bot?'].map(s => (
                          <Chip key={s} size='small' label={s} onClick={() => setInput(s)} />
                        ))}
                      </Stack>
                    )}
                  </Box>
                )}
                {thread.map((m, i) => (
                  <Bubble key={i} role={m.role} text={m.content} />
                ))}
                {playgroundLoading && (
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, color: 'text.secondary' }}>
                    <CircularProgress size={14} />
                    <Typography variant='caption'>typing…</Typography>
                  </Box>
                )}
                {playgroundError && <Alert severity='error'>{playgroundError}</Alert>}
                <div ref={endRef} />
              </Box>
              <Box sx={{ display: 'flex', gap: 2, p: 2, borderTop: '1px solid', borderColor: 'divider' }}>
                <TextField
                  fullWidth
                  size='small'
                  placeholder={disabled ? 'Configure a provider to start' : 'Type a message as the user…'}
                  value={input}
                  disabled={disabled}
                  onChange={e => setInput(e.target.value)}
                  onKeyDown={e => {
                    if (e.key === 'Enter' && !e.shiftKey) {
                      e.preventDefault()
                      send()
                    }
                  }}
                />
                <Button variant='contained' onClick={send} disabled={disabled || playgroundLoading || !input.trim()}>
                  <i className='tabler-send' />
                </Button>
              </Box>
            </Box>
            {lastMeta?.systemPrompt && (
              <Box sx={{ mt: 2 }}>
                <Button size='small' onClick={() => setShowPrompt(s => !s)} endIcon={<i className={showPrompt ? 'tabler-chevron-up' : 'tabler-chevron-down'} />}>
                  {showPrompt ? 'Hide' : 'Show'} the exact instructions sent to the model
                </Button>
                <Collapse in={showPrompt}>
                  <Box
                    component='pre'
                    sx={{
                      mt: 1,
                      p: 3,
                      borderRadius: 2,
                      bgcolor: 'action.hover',
                      fontSize: 12,
                      whiteSpace: 'pre-wrap',
                      maxHeight: 260,
                      overflow: 'auto'
                    }}
                  >
                    {lastMeta.systemPrompt}
                  </Box>
                </Collapse>
              </Box>
            )}
          </Grid>
        </Grid>
      </CardContent>
    </Card>
  )
}

export default AiPlayground
