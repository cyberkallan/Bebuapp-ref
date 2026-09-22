'use client'

import React, { useEffect, useMemo, useState } from 'react'

import {
  Alert,
  Autocomplete,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  Divider,
  FormControl,
  FormControlLabel,
  Grid,
  IconButton,
  InputAdornment,
  InputLabel,
  Link,
  MenuItem,
  Select,
  Slider,
  Stack,
  Switch,
  TextField,
  Tooltip,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import { fetchAiConfig, fetchAiUsage, testAiProvider, updateAiConfig } from '@/redux-store/slices/aiChat'
import AiPlayground from './ai/AiPlayground'
import AiUsagePanel from './ai/AiUsagePanel'

const SectionTitle = ({ icon, title, subtitle, action }) => (
  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 2, mb: 3 }}>
    <Box>
      <Typography variant='h6' sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <i className={`${icon} text-xl`} />
        {title}
      </Typography>
      {subtitle && (
        <Typography variant='body2' color='text.secondary' sx={{ mt: 0.5 }}>
          {subtitle}
        </Typography>
      )}
    </Box>
    {action}
  </Box>
)

const StatCard = ({ label, value, hint, color = 'primary', icon }) => (
  <Card variant='outlined' sx={{ height: '100%' }}>
    <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 3, py: '18px !important' }}>
      <Box
        sx={{
          width: 44,
          height: 44,
          borderRadius: 2,
          display: 'grid',
          placeItems: 'center',
          bgcolor: theme => `rgba(var(--mui-palette-${color}-mainChannel) / 0.14)`,
          color: `${color}.main`,
          flexShrink: 0
        }}
      >
        <i className={`${icon} text-2xl`} />
      </Box>
      <Box sx={{ minWidth: 0 }}>
        <Typography variant='h5' sx={{ lineHeight: 1.2 }}>
          {value}
        </Typography>
        <Typography variant='body2' color='text.secondary' noWrap>
          {label}
        </Typography>
        {hint && (
          <Typography variant='caption' color='text.disabled'>
            {hint}
          </Typography>
        )}
      </Box>
    </CardContent>
  </Card>
)

const emptyProvider = preset => ({
  preset: preset.id,
  label: '',
  baseUrl: preset.id === 'custom' ? preset.baseUrl : '',
  apiKey: '',
  model: preset.model,
  enabled: true,
  hasKey: false
})

const AiChatSettings = () => {
  const dispatch = useDispatch()

  const { aiChat, languages, tones, presets, loading, saving, error, providerTests, usage, cooldowns } = useSelector(
    state => state.aiChat
  )

  const [form, setForm] = useState(null)
  const [dirty, setDirty] = useState(false)
  const [showKey, setShowKey] = useState({})
  const [topicInput, setTopicInput] = useState('')

  useEffect(() => {
    dispatch(fetchAiConfig())
    dispatch(fetchAiUsage(14))
  }, [dispatch])

  useEffect(() => {
    if (aiChat) {
      setForm({ ...aiChat, providers: (aiChat.providers || []).map(p => ({ ...p })) })
      setDirty(false)
    }
  }, [aiChat])

  const presetMap = useMemo(() => Object.fromEntries(presets.map(p => [p.id, p])), [presets])

  const set = (key, value) => {
    setForm(prev => ({ ...prev, [key]: value }))
    setDirty(true)
  }

  const setProvider = (index, patch) => {
    setForm(prev => {
      const providers = prev.providers.map((p, i) => (i === index ? { ...p, ...patch } : p))

      return { ...prev, providers }
    })
    setDirty(true)
  }

  const moveProvider = (index, dir) => {
    setForm(prev => {
      const providers = [...prev.providers]
      const target = index + dir

      if (target < 0 || target >= providers.length) return prev
      ;[providers[index], providers[target]] = [providers[target], providers[index]]

      return { ...prev, providers }
    })
    setDirty(true)
  }

  const removeProvider = index => {
    setForm(prev => ({ ...prev, providers: prev.providers.filter((_, i) => i !== index) }))
    setDirty(true)
  }

  const addProvider = presetId => {
    const preset = presetMap[presetId] || presetMap.custom

    if (!preset) return
    setForm(prev => ({ ...prev, providers: [...(prev.providers || []), emptyProvider(preset)] }))
    setDirty(true)
  }

  const handleSave = async () => {
    const payload = {
      ...form,
      providers: form.providers.map(p => ({
        _id: p._id,
        preset: p.preset,
        label: p.label,
        baseUrl: p.baseUrl,
        apiKey: p.apiKey,
        clearKey: p.clearKey === true,
        model: p.model,
        enabled: p.enabled
      }))
    }

    await dispatch(updateAiConfig(payload))
    dispatch(fetchAiConfig())
  }

  if (loading && !form) {
    return (
      <Box sx={{ display: 'grid', placeItems: 'center', height: '50vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error && !form) {
    return <Alert severity='error'>{error}</Alert>
  }

  if (!form) return null

  const configuredProviders = form.providers.filter(p => p.enabled && (p.hasKey || p.apiKey || p.preset === 'custom'))
  const readyToReply = form.enabled && configuredProviders.length > 0
  const coolingDown = Object.keys(cooldowns || {}).length

  return (
    <Box>
      {/* Header */}
      <Box
        sx={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: { xs: 'flex-start', md: 'center' },
          flexDirection: { xs: 'column', md: 'row' },
          gap: 3,
          mb: 5
        }}
      >
        <Box>
          <Typography variant='h5'>AI Chat for Fake Hosts</Typography>
          <Typography variant='body2' color='text.secondary'>
            Fake hosts answer user messages automatically, in the language and personality you assign. Free API
            providers with automatic failover, human-like typing delays, daily caps and safety rules.
          </Typography>
        </Box>
        <Stack direction='row' spacing={2} alignItems='center'>
          <FormControlLabel
            sx={{ mr: 0 }}
            control={<Switch checked={!!form.enabled} onChange={e => set('enabled', e.target.checked)} color='success' />}
            label={<Typography fontWeight={600}>{form.enabled ? 'Enabled' : 'Disabled'}</Typography>}
          />
          <Button
            variant='contained'
            onClick={handleSave}
            disabled={saving || !dirty}
            startIcon={saving ? <CircularProgress size={18} sx={{ color: 'white' }} /> : <i className='tabler-device-floppy' />}
          >
            Save Changes
          </Button>
        </Stack>
      </Box>

      {!readyToReply && (
        <Alert severity={form.enabled ? 'warning' : 'info'} sx={{ mb: 4 }}>
          {form.enabled
            ? 'AI is enabled but no provider has an API key yet. Add a free key below (Groq or Gemini take under a minute) or hosts will only send the fallback line.'
            : 'AI replies are turned off. Configure a provider, pick a default language, then flip the switch above.'}
        </Alert>
      )}

      {/* Overview */}
      <Grid container spacing={4} sx={{ mb: 5 }}>
        <Grid size={{ xs: 12, sm: 6, lg: 3 }}>
          <StatCard
            icon='tabler-message-2-bolt'
            label='Replies today'
            value={usage?.today?.replies ?? '—'}
            hint={usage?.today?.cap ? `cap ${usage.today.cap.toLocaleString()}` : undefined}
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, lg: 3 }}>
          <StatCard icon='tabler-users' color='info' label='Hosts with AI on' value={usage?.activeProfiles ?? '—'} />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, lg: 3 }}>
          <StatCard
            icon='tabler-plug-connected'
            color={configuredProviders.length ? 'success' : 'warning'}
            label='Providers ready'
            value={`${configuredProviders.length}/${form.providers.length}`}
            hint={coolingDown ? `${coolingDown} cooling down` : 'failover in order'}
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, lg: 3 }}>
          <StatCard
            icon='tabler-clock-bolt'
            color='secondary'
            label='Avg latency today'
            value={usage?.today?.avgLatencyMs ? `${(usage.today.avgLatencyMs / 1000).toFixed(1)}s` : '—'}
            hint={usage?.today?.failures ? `${usage.today.failures} failures` : undefined}
          />
        </Grid>
      </Grid>

      {/* Providers */}
      <Card sx={{ mb: 5 }}>
        <CardContent>
          <SectionTitle
            icon='tabler-server-bolt'
            title='AI providers (free)'
            subtitle='Requests go to the first provider; if it is rate-limited or down, the next one takes over automatically. All are OpenAI-compatible, so you can add any endpoint.'
            action={
              <FormControl size='small' sx={{ minWidth: 200 }}>
                <InputLabel>Add provider</InputLabel>
                <Select label='Add provider' value='' onChange={e => addProvider(e.target.value)}>
                  {presets.map(p => (
                    <MenuItem key={p.id} value={p.id}>
                      {p.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            }
          />

          {form.providers.length === 0 && (
            <Box
              sx={{
                border: '1px dashed',
                borderColor: 'divider',
                borderRadius: 2,
                p: 5,
                textAlign: 'center'
              }}
            >
              <i className='tabler-key text-4xl' style={{ opacity: 0.5 }} />
              <Typography variant='h6' sx={{ mt: 2 }}>
                No provider yet
              </Typography>
              <Typography variant='body2' color='text.secondary' sx={{ mb: 3 }}>
                Recommended: add Groq first (fastest), then Gemini as backup (best Indic language quality). Both are
                free with no card.
              </Typography>
              <Stack direction='row' spacing={2} justifyContent='center'>
                <Button variant='contained' onClick={() => addProvider('groq')}>
                  Add Groq
                </Button>
                <Button variant='outlined' onClick={() => addProvider('gemini')}>
                  Add Gemini
                </Button>
              </Stack>
            </Box>
          )}

          <Stack spacing={3}>
            {form.providers.map((p, index) => {
              const preset = presetMap[p.preset] || presetMap.custom || {}
              const test = providerTests[index]
              const cooling = cooldowns?.[`${p.preset}${p.model || preset.model}`]

              return (
                <Card key={p._id || index} variant='outlined' sx={{ opacity: p.enabled ? 1 : 0.6 }}>
                  <CardContent>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3, flexWrap: 'wrap' }}>
                      <Chip size='small' label={`#${index + 1}`} color={index === 0 ? 'primary' : 'default'} />
                      <Typography variant='subtitle1' fontWeight={600}>
                        {p.label || preset.label}
                      </Typography>
                      {p.hasKey && !p.clearKey && <Chip size='small' variant='tonal' color='success' label='Key saved' />}
                      {cooling && <Chip size='small' variant='tonal' color='warning' label={`Cooling down ${cooling}s`} />}
                      <Box sx={{ flex: 1 }} />
                      <Tooltip title='Move up'>
                        <IconButton size='small' disabled={index === 0} onClick={() => moveProvider(index, -1)}>
                          <i className='tabler-arrow-up' />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title='Move down'>
                        <IconButton
                          size='small'
                          disabled={index === form.providers.length - 1}
                          onClick={() => moveProvider(index, 1)}
                        >
                          <i className='tabler-arrow-down' />
                        </IconButton>
                      </Tooltip>
                      <Switch checked={!!p.enabled} onChange={e => setProvider(index, { enabled: e.target.checked })} />
                      <Tooltip title='Remove'>
                        <IconButton size='small' color='error' onClick={() => removeProvider(index)}>
                          <i className='tabler-trash' />
                        </IconButton>
                      </Tooltip>
                    </Box>

                    <Grid container spacing={3}>
                      <Grid size={{ xs: 12, md: 3 }}>
                        <FormControl fullWidth size='small'>
                          <InputLabel>Provider</InputLabel>
                          <Select
                            label='Provider'
                            value={p.preset}
                            onChange={e => {
                              const next = presetMap[e.target.value]

                              setProvider(index, {
                                preset: e.target.value,
                                model: next?.model || '',
                                baseUrl: e.target.value === 'custom' ? next?.baseUrl || '' : ''
                              })
                            }}
                          >
                            {presets.map(opt => (
                              <MenuItem key={opt.id} value={opt.id}>
                                {opt.label}
                              </MenuItem>
                            ))}
                          </Select>
                        </FormControl>
                      </Grid>
                      <Grid size={{ xs: 12, md: 4 }}>
                        <Autocomplete
                          freeSolo
                          size='small'
                          options={preset.models || []}
                          value={p.model || ''}
                          onInputChange={(_, v) => setProvider(index, { model: v })}
                          renderInput={params => <TextField {...params} label='Model' placeholder={preset.model} />}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 5 }}>
                        <TextField
                          fullWidth
                          size='small'
                          type={showKey[index] ? 'text' : 'password'}
                          label='API key'
                          placeholder={p.hasKey ? 'Saved — paste a new key to replace' : 'Paste your API key'}
                          value={p.apiKey || ''}
                          onChange={e => setProvider(index, { apiKey: e.target.value, clearKey: false })}
                          InputProps={{
                            endAdornment: (
                              <InputAdornment position='end'>
                                <IconButton size='small' onClick={() => setShowKey(s => ({ ...s, [index]: !s[index] }))}>
                                  <i className={showKey[index] ? 'tabler-eye-off' : 'tabler-eye'} />
                                </IconButton>
                              </InputAdornment>
                            )
                          }}
                        />
                      </Grid>
                      {p.preset === 'custom' && (
                        <Grid size={{ xs: 12, md: 7 }}>
                          <TextField
                            fullWidth
                            size='small'
                            label='Base URL (OpenAI-compatible)'
                            placeholder='http://host:11434/v1'
                            value={p.baseUrl || ''}
                            onChange={e => setProvider(index, { baseUrl: e.target.value })}
                          />
                        </Grid>
                      )}
                      <Grid size={{ xs: 12, md: p.preset === 'custom' ? 5 : 12 }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
                          <Button
                            size='small'
                            variant='outlined'
                            disabled={test?.loading}
                            onClick={() => dispatch(testAiProvider({ provider: p, index }))}
                            startIcon={test?.loading ? <CircularProgress size={14} /> : <i className='tabler-plug' />}
                          >
                            Test connection
                          </Button>
                          {preset.keyUrl && (
                            <Link href={preset.keyUrl} target='_blank' rel='noreferrer' variant='body2'>
                              Get a free key <i className='tabler-external-link text-sm' />
                            </Link>
                          )}
                          <Typography variant='caption' color='text.secondary'>
                            {preset.freeTier}
                          </Typography>
                        </Box>
                        {test && !test.loading && (
                          <Alert severity={test.ok ? 'success' : 'error'} sx={{ mt: 2 }} icon={false}>
                            {test.ok ? (
                              <>
                                <strong>Working</strong> · {test.model} · {test.latencyMs} ms
                                <br />
                                <em>“{test.sample}”</em>
                              </>
                            ) : (
                              test.message
                            )}
                          </Alert>
                        )}
                      </Grid>
                    </Grid>
                  </CardContent>
                </Card>
              )
            })}
          </Stack>
        </CardContent>
      </Card>

      {/* Behaviour */}
      <Card sx={{ mb: 5 }}>
        <CardContent>
          <SectionTitle
            icon='tabler-message-language'
            title='Default language & personality'
            subtitle='Applies to every fake host unless you override it per host from the Listener list (robot icon).'
          />
          <Grid container spacing={4}>
            <Grid size={{ xs: 12, md: 4 }}>
              <FormControl fullWidth>
                <InputLabel>Default language</InputLabel>
                <Select
                  label='Default language'
                  value={form.defaultLanguage || 'english'}
                  onChange={e => set('defaultLanguage', e.target.value)}
                  renderValue={v => {
                    const l = languages.find(x => x.id === v)

                    return l ? `${l.label} · ${l.native}` : v
                  }}
                >
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
            <Grid size={{ xs: 12, md: 4 }}>
              <FormControl fullWidth>
                <InputLabel>Tone</InputLabel>
                <Select label='Tone' value={form.tone || 'warm'} onChange={e => set('tone', e.target.value)}>
                  {tones.map(t => (
                    <MenuItem key={t.id} value={t.id}>
                      {t.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid size={{ xs: 12, md: 4 }}>
              <FormControl fullWidth>
                <InputLabel>If asked “are you a bot?”</InputLabel>
                <Select
                  label='If asked “are you a bot?”'
                  value={form.identityRule || 'stay_in_character'}
                  onChange={e => set('identityRule', e.target.value)}
                >
                  <MenuItem value='stay_in_character'>Stay in character, steer back</MenuItem>
                  <MenuItem value='honest'>Answer honestly, keep chatting</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid size={{ xs: 12, md: 4 }}>
              <FormControl fullWidth>
                <InputLabel>Reply length</InputLabel>
                <Select
                  label='Reply length'
                  value={form.replyLength || 'short'}
                  onChange={e => set('replyLength', e.target.value)}
                >
                  <MenuItem value='short'>Short · 1–2 lines (like real texting)</MenuItem>
                  <MenuItem value='medium'>Medium · 1–3 sentences</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid size={{ xs: 12, md: 4 }}>
              <FormControl fullWidth>
                <InputLabel>Emoji</InputLabel>
                <Select label='Emoji' value={form.emojiLevel || 'light'} onChange={e => set('emojiLevel', e.target.value)}>
                  <MenuItem value='none'>None</MenuItem>
                  <MenuItem value='light'>Light · max one</MenuItem>
                  <MenuItem value='expressive'>Expressive · 1–3</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid size={{ xs: 12, md: 4 }}>
              <FormControl fullWidth>
                <InputLabel>Reply when host is</InputLabel>
                <Select
                  label='Reply when host is'
                  value={form.replyWhen || 'always'}
                  onChange={e => set('replyWhen', e.target.value)}
                >
                  <MenuItem value='always'>Always (online or offline)</MenuItem>
                  <MenuItem value='online'>Only while marked online</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid size={{ xs: 12, md: 6 }}>
              <Typography gutterBottom>
                Typing delay before replying: <strong>{form.typingDelayMinSec}s – {form.typingDelayMaxSec}s</strong>
              </Typography>
              <Slider
                value={[Number(form.typingDelayMinSec), Number(form.typingDelayMaxSec)]}
                min={0}
                max={30}
                step={1}
                valueLabelDisplay='auto'
                onChange={(_, v) => {
                  set('typingDelayMinSec', v[0])
                  set('typingDelayMaxSec', v[1])
                }}
              />
              <Typography variant='caption' color='text.secondary'>
                A random delay in this range plus a little extra for longer replies, so it feels like a person typing.
              </Typography>
            </Grid>
            <Grid size={{ xs: 12, md: 3 }}>
              <TextField
                fullWidth
                type='number'
                label='Memory (messages)'
                value={form.memoryMessages}
                onChange={e => set('memoryMessages', e.target.value)}
                helperText='How much of the conversation the AI re-reads'
                inputProps={{ min: 2, max: 40 }}
              />
            </Grid>
            <Grid size={{ xs: 12, md: 3 }}>
              <FormControlLabel
                sx={{ mt: 1 }}
                control={<Switch checked={!!form.splitLongReplies} onChange={e => set('splitLongReplies', e.target.checked)} />}
                label={
                  <Box>
                    <Typography>Split into two bubbles</Typography>
                    <Typography variant='caption' color='text.secondary'>
                      Longer replies arrive as two messages
                    </Typography>
                  </Box>
                }
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Limits & monetisation */}
      <Grid container spacing={5} sx={{ mb: 5 }}>
        <Grid size={{ xs: 12, lg: 6 }}>
          <Card sx={{ height: '100%' }}>
            <CardContent>
              <SectionTitle
                icon='tabler-gauge'
                title='Limits & schedule'
                subtitle='Keeps you inside free-tier quotas and stops hosts replying at odd hours.'
              />
              <Grid container spacing={3}>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField
                    fullWidth
                    type='number'
                    label='Max replies per user / day'
                    value={form.maxRepliesPerUserPerDay}
                    onChange={e => set('maxRepliesPerUserPerDay', e.target.value)}
                  />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField
                    fullWidth
                    type='number'
                    label='Max replies total / day'
                    value={form.maxRepliesPerDay}
                    onChange={e => set('maxRepliesPerDay', e.target.value)}
                    helperText='Groq free ≈ 1,000/day per model'
                  />
                </Grid>
                <Grid size={{ xs: 12 }}>
                  <FormControlLabel
                    control={
                      <Switch checked={!!form.quietHoursEnabled} onChange={e => set('quietHoursEnabled', e.target.checked)} />
                    }
                    label='Quiet hours (hosts stay silent)'
                  />
                </Grid>
                <Grid size={{ xs: 6, sm: 4 }}>
                  <TextField
                    fullWidth
                    type='time'
                    label='From'
                    value={form.quietStart}
                    disabled={!form.quietHoursEnabled}
                    onChange={e => set('quietStart', e.target.value)}
                    InputLabelProps={{ shrink: true }}
                  />
                </Grid>
                <Grid size={{ xs: 6, sm: 4 }}>
                  <TextField
                    fullWidth
                    type='time'
                    label='To'
                    value={form.quietEnd}
                    disabled={!form.quietHoursEnabled}
                    onChange={e => set('quietEnd', e.target.value)}
                    InputLabelProps={{ shrink: true }}
                  />
                </Grid>
                <Grid size={{ xs: 12, sm: 4 }}>
                  <TextField
                    fullWidth
                    label='Timezone'
                    value={form.timezone}
                    onChange={e => set('timezone', e.target.value)}
                    placeholder='Asia/Kolkata'
                  />
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>
        <Grid size={{ xs: 12, lg: 6 }}>
          <Card sx={{ height: '100%' }}>
            <CardContent>
              <SectionTitle
                icon='tabler-phone-call'
                title='Call nudges'
                subtitle='Hosts gently suggest moving to a paid voice/video call at a cadence you control. Never pushy.'
              />
              <Grid container spacing={3}>
                <Grid size={{ xs: 12 }}>
                  <FormControlLabel
                    control={<Switch checked={!!form.callNudgeEnabled} onChange={e => set('callNudgeEnabled', e.target.checked)} />}
                    label='Suggest calls during chat'
                  />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField
                    fullWidth
                    type='number'
                    label='First nudge after (user messages)'
                    value={form.callNudgeAfterMessages}
                    disabled={!form.callNudgeEnabled}
                    onChange={e => set('callNudgeAfterMessages', e.target.value)}
                  />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField
                    fullWidth
                    type='number'
                    label='Then every (user messages)'
                    value={form.callNudgeEveryMessages}
                    disabled={!form.callNudgeEnabled}
                    onChange={e => set('callNudgeEveryMessages', e.target.value)}
                  />
                </Grid>
                <Grid size={{ xs: 12 }}>
                  <Alert severity='info' icon={<i className='tabler-bulb' />}>
                    Example (Manglish): “Ithu type cheythu parayaan pattilla 😄 oru quick call cheyyaam?”
                  </Alert>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Safety */}
      <Card sx={{ mb: 5 }}>
        <CardContent>
          <SectionTitle
            icon='tabler-shield-check'
            title='Safety & custom rules'
            subtitle='Built-in: no phone numbers or off-app contact, no asking for money, PG-13 only, caring response to distress.'
          />
          <Grid container spacing={4}>
            <Grid size={{ xs: 12, md: 6 }}>
              <Autocomplete
                multiple
                freeSolo
                options={['politics', 'religion debates', 'drugs', 'gambling', 'explicit sexual content', 'self-harm instructions']}
                value={form.blockedTopics || []}
                inputValue={topicInput}
                onInputChange={(_, v) => setTopicInput(v)}
                onChange={(_, v) => set('blockedTopics', v)}
                renderTags={(value, getTagProps) =>
                  value.map((option, index) => (
                    <Chip variant='tonal' size='small' label={option} {...getTagProps({ index })} key={option} />
                  ))
                }
                renderInput={params => (
                  <TextField {...params} label='Blocked topics' helperText='Type and press Enter to add' />
                )}
              />
            </Grid>
            <Grid size={{ xs: 12, md: 6 }}>
              <TextField
                fullWidth
                multiline
                minRows={3}
                label='Extra rules for every host'
                placeholder='e.g. Never mention other apps. Always ask about their day in the first reply.'
                value={form.customRules || ''}
                onChange={e => set('customRules', e.target.value)}
              />
            </Grid>
            <Grid size={{ xs: 12 }}>
              <FormControlLabel
                control={<Switch checked={!!form.fallbackEnabled} onChange={e => set('fallbackEnabled', e.target.checked)} />}
                label={
                  <Box>
                    <Typography>Send a fallback line when all providers fail</Typography>
                    <Typography variant='caption' color='text.secondary'>
                      Per language, e.g. Manglish: “{languages.find(l => l.id === (form.defaultLanguage || 'english'))?.fallback}”
                    </Typography>
                  </Box>
                }
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Advanced */}
      <Card sx={{ mb: 5 }}>
        <CardContent>
          <SectionTitle icon='tabler-adjustments-alt' title='Model parameters' subtitle='Defaults work well; tweak only if replies feel off.' />
          <Grid container spacing={4}>
            <Grid size={{ xs: 12, md: 4 }}>
              <Typography gutterBottom>
                Creativity (temperature): <strong>{Number(form.temperature).toFixed(2)}</strong>
              </Typography>
              <Slider value={Number(form.temperature)} min={0} max={1.5} step={0.05} onChange={(_, v) => set('temperature', v)} />
            </Grid>
            <Grid size={{ xs: 12, md: 4 }}>
              <TextField fullWidth type='number' label='Max tokens per reply' value={form.maxTokens} onChange={e => set('maxTokens', e.target.value)} />
            </Grid>
            <Grid size={{ xs: 12, md: 4 }}>
              <TextField fullWidth type='number' label='Provider timeout (ms)' value={form.timeoutMs} onChange={e => set('timeoutMs', e.target.value)} />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Divider sx={{ my: 6 }} />

      <AiPlayground languages={languages} tones={tones} defaults={form} disabled={!configuredProviders.length} />

      <AiUsagePanel />
    </Box>
  )
}

export default AiChatSettings
