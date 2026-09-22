'use client'

import React, { useEffect, useMemo } from 'react'

import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  CardHeader,
  Chip,
  CircularProgress,
  Divider,
  Grid,
  IconButton,
  Stack,
  Tooltip,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'
import { toast } from 'react-toastify'

import { fetchDownloads, startDownload } from '@/redux-store/slices/downloads'

const GROUP_ORDER = ['Source code', 'Marketplace package', 'Mobile builds', 'Documentation', 'Other']

const GROUP_HELP = {
  'Source code': 'Complete project with your keys and configuration: restore or migrate the whole platform from here.',
  'Marketplace package': 'Same product with every private key removed and the guided installer included. Safe to hand to a buyer or another developer.',
  'Mobile builds': 'Signed Android APKs (side-load) and the Play Store bundle (.aab). Upload the .aab in Play Console → Production.',
  Documentation: 'Guides for installing, configuring and running bebu.',
  Other: ''
}

const ICON = name => {
  const n = name.toLowerCase()

  if (n.endsWith('.apk')) return 'tabler-brand-android'
  if (n.endsWith('.aab')) return 'tabler-brand-google-play'
  if (n.endsWith('.ipa')) return 'tabler-brand-apple'
  if (n.endsWith('.pdf') || n.endsWith('.md')) return 'tabler-file-text'

  return 'tabler-file-zip'
}

const fmtBytes = b => {
  if (!b) return '0 B'
  const units = ['B', 'KB', 'MB', 'GB']
  const i = Math.min(units.length - 1, Math.floor(Math.log(b) / Math.log(1024)))

  return `${(b / 1024 ** i).toFixed(i === 0 ? 0 : 1)} ${units[i]}`
}

const fmtDate = d =>
  new Date(d).toLocaleString(undefined, { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })

const copy = async (text, label) => {
  try {
    await navigator.clipboard.writeText(text)
    toast.success(`${label} copied`)
  } catch {
    toast.error('Clipboard is not available in this browser')
  }
}

const FileRow = ({ file, busy, onDownload }) => (
  <Box
    sx={{
      display: 'flex',
      alignItems: 'center',
      gap: 3,
      py: 2.5,
      flexWrap: 'wrap'
    }}
  >
    <Box
      sx={{
        width: 44,
        height: 44,
        borderRadius: 2,
        display: 'grid',
        placeItems: 'center',
        bgcolor: 'action.hover',
        flexShrink: 0
      }}
    >
      <i className={ICON(file.name)} style={{ fontSize: 24 }} />
    </Box>
    <Box sx={{ flex: 1, minWidth: 220 }}>
      <Typography variant='subtitle1' sx={{ fontWeight: 600, lineHeight: 1.3 }}>
        {file.title}
      </Typography>
      <Typography variant='body2' color='text.secondary' sx={{ wordBreak: 'break-all' }}>
        {file.name}
      </Typography>
      {file.description ? (
        <Typography variant='body2' sx={{ mt: 0.5 }}>
          {file.description}
        </Typography>
      ) : null}
      <Stack direction='row' spacing={1} sx={{ mt: 1, flexWrap: 'wrap', rowGap: 1 }}>
        <Chip size='small' variant='tonal' label={fmtBytes(file.bytes)} />
        <Chip size='small' variant='tonal' label={fmtDate(file.modifiedAt)} />
        {file.sha256 ? (
          <Tooltip title={file.sha256}>
            <Chip
              size='small'
              variant='tonal'
              color='secondary'
              icon={<i className='tabler-shield-check' />}
              label={`SHA-256 ${file.sha256.slice(0, 10)}…`}
              onClick={() => copy(file.sha256, 'Checksum')}
            />
          </Tooltip>
        ) : null}
      </Stack>
    </Box>
    <Button
      variant='contained'
      startIcon={busy ? <CircularProgress size={16} color='inherit' /> : <i className='tabler-download' />}
      disabled={busy}
      onClick={onDownload}
      sx={{ minWidth: 140 }}
    >
      {busy ? 'Preparing…' : 'Download'}
    </Button>
  </Box>
)

export default function Downloads() {
  const dispatch = useDispatch()
  const { files, dir, status, error, starting } = useSelector(s => s.downloads)

  useEffect(() => {
    dispatch(fetchDownloads())
  }, [dispatch])

  const groups = useMemo(() => {
    const map = new Map()

    files.forEach(f => {
      if (!map.has(f.group)) map.set(f.group, [])
      map.get(f.group).push(f)
    })

    return [...map.entries()].sort(
      ([a], [b]) => (GROUP_ORDER.indexOf(a) + 1 || 99) - (GROUP_ORDER.indexOf(b) + 1 || 99)
    )
  }, [files])

  return (
    <Grid container spacing={6}>
      <Grid item xs={12}>
        <Card>
          <CardHeader
            title='Downloads'
            subheader='Release bundles, mobile builds and the full source code of this installation. Links are private to signed-in admins and expire after 10 minutes.'
            action={
              <Tooltip title='Refresh'>
                <IconButton onClick={() => dispatch(fetchDownloads())}>
                  <i className='tabler-refresh' />
                </IconButton>
              </Tooltip>
            }
          />
          <CardContent>
            {status === 'loading' && files.length === 0 ? (
              <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
                <CircularProgress />
              </Box>
            ) : null}

            {status === 'failed' ? <Alert severity='error'>{error}</Alert> : null}

            {status === 'succeeded' && files.length === 0 ? (
              <Alert severity='info' icon={<i className='tabler-folder-open' />}>
                Nothing here yet. Copy release zips, APK/AAB files or documents into <code>{dir}</code> on the server (the
                <code> bebu-backend</code> container&apos;s <code>storage/downloads</code> folder) and they appear in this
                list. An optional <code>manifest.json</code> there sets titles and descriptions; a <code>SHA256SUMS.txt</code>{' '}
                adds checksums.
              </Alert>
            ) : null}

            {groups.map(([group, list], gi) => (
              <Box key={group} sx={{ mb: gi === groups.length - 1 ? 0 : 4 }}>
                <Typography variant='h6' sx={{ mb: 0.5 }}>
                  {group}
                </Typography>
                {GROUP_HELP[group] ? (
                  <Typography variant='body2' color='text.secondary' sx={{ mb: 1 }}>
                    {GROUP_HELP[group]}
                  </Typography>
                ) : null}
                <Divider />
                {list.map((file, i) => (
                  <React.Fragment key={file.name}>
                    <FileRow file={file} busy={starting === file.name} onDownload={() => dispatch(startDownload(file.name))} />
                    {i < list.length - 1 ? <Divider /> : null}
                  </React.Fragment>
                ))}
              </Box>
            ))}
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  )
}
