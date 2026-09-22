'use client'

import React, { useMemo } from 'react'

import {
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  Grid,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Tooltip,
  Typography
} from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import { fetchAiUsage } from '@/redux-store/slices/aiChat'

const Bars = ({ data }) => {
  const max = Math.max(1, ...data.map(d => d.replies + d.failures))

  return (
    <Box sx={{ display: 'flex', alignItems: 'flex-end', gap: 1, height: 120 }}>
      {data.map(d => (
        <Tooltip key={d.day} title={`${d.day}: ${d.replies} replies, ${d.failures} failures`}>
          <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', height: '100%', gap: '2px' }}>
            {d.failures > 0 && (
              <Box sx={{ height: `${(d.failures / max) * 100}%`, bgcolor: 'error.main', borderRadius: 1, minHeight: 2 }} />
            )}
            <Box
              sx={{
                height: `${(d.replies / max) * 100}%`,
                bgcolor: 'primary.main',
                borderRadius: 1,
                minHeight: d.replies ? 3 : 0,
                opacity: 0.9
              }}
            />
          </Box>
        </Tooltip>
      ))}
    </Box>
  )
}

const AiUsagePanel = () => {
  const dispatch = useDispatch()
  const { usage, usageLoading } = useSelector(state => state.aiChat)

  const days = useMemo(() => {
    const out = []
    const byDay = Object.fromEntries((usage?.byDay || []).map(d => [d.day, d]))

    for (let i = 13; i >= 0; i--) {
      const d = new Date(Date.now() - i * 86400000).toISOString().slice(0, 10)

      out.push(byDay[d] || { day: d, replies: 0, failures: 0 })
    }

    return out
  }, [usage])

  return (
    <Card>
      <CardContent>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 2, mb: 3 }}>
          <Box>
            <Typography variant='h6' sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
              <i className='tabler-chart-bar text-xl' />
              Usage & recent replies
            </Typography>
            <Typography variant='body2' color='text.secondary'>
              Last 14 days. Use this to see which provider is doing the work and whether you are near a free quota.
            </Typography>
          </Box>
          <Button
            size='small'
            variant='outlined'
            color='secondary'
            onClick={() => dispatch(fetchAiUsage(14))}
            disabled={usageLoading}
            startIcon={usageLoading ? <CircularProgress size={14} /> : <i className='tabler-refresh' />}
          >
            Refresh
          </Button>
        </Box>

        <Grid container spacing={4}>
          <Grid size={{ xs: 12, md: 5 }}>
            <Typography variant='subtitle2' sx={{ mb: 2 }}>
              Replies per day
            </Typography>
            <Bars data={days} />
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 1 }}>
              <Typography variant='caption' color='text.disabled'>
                {days[0]?.day}
              </Typography>
              <Typography variant='caption' color='text.disabled'>
                today
              </Typography>
            </Box>

            <Typography variant='subtitle2' sx={{ mt: 4, mb: 1 }}>
              By provider
            </Typography>
            <Table size='small'>
              <TableHead>
                <TableRow>
                  <TableCell>Provider</TableCell>
                  <TableCell align='right'>Replies</TableCell>
                  <TableCell align='right'>Fail</TableCell>
                  <TableCell align='right'>Avg</TableCell>
                  <TableCell align='right'>Tokens</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {(usage?.byProvider || []).length === 0 && (
                  <TableRow>
                    <TableCell colSpan={5}>
                      <Typography variant='body2' color='text.disabled'>
                        No AI replies yet.
                      </Typography>
                    </TableCell>
                  </TableRow>
                )}
                {(usage?.byProvider || []).map(p => (
                  <TableRow key={p.provider}>
                    <TableCell sx={{ textTransform: 'capitalize' }}>{p.provider}</TableCell>
                    <TableCell align='right'>{p.replies}</TableCell>
                    <TableCell align='right' sx={{ color: p.failures ? 'error.main' : 'inherit' }}>
                      {p.failures}
                    </TableCell>
                    <TableCell align='right'>{p.avgLatencyMs ? `${(p.avgLatencyMs / 1000).toFixed(1)}s` : '—'}</TableCell>
                    <TableCell align='right'>{(p.inputTokens + p.outputTokens).toLocaleString()}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>

            {(usage?.topHosts || []).length > 0 && (
              <>
                <Typography variant='subtitle2' sx={{ mt: 4, mb: 1 }}>
                  Most active hosts
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                  {usage.topHosts.map(h => (
                    <Chip key={String(h._id)} size='small' variant='tonal' label={`${h.name || 'Host'} · ${h.replies}`} />
                  ))}
                </Box>
              </>
            )}
          </Grid>

          <Grid size={{ xs: 12, md: 7 }}>
            <Typography variant='subtitle2' sx={{ mb: 2 }}>
              Recent replies
            </Typography>
            <Box sx={{ maxHeight: 520, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: 2 }}>
              {(usage?.recent || []).length === 0 && (
                <Typography variant='body2' color='text.disabled'>
                  Replies will appear here as users chat with fake hosts.
                </Typography>
              )}
              {(usage?.recent || []).map(r => (
                <Box key={r._id} sx={{ p: 3, borderRadius: 2, border: '1px solid', borderColor: r.ok ? 'divider' : 'error.main' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1, flexWrap: 'wrap' }}>
                    <Typography variant='subtitle2'>{r.listenerName || 'Host'}</Typography>
                    <Chip size='small' label={r.language} variant='tonal' color='info' />
                    <Chip size='small' label={r.provider} variant='tonal' color={r.ok ? 'success' : 'error'} />
                    <Box sx={{ flex: 1 }} />
                    <Typography variant='caption' color='text.disabled'>
                      {new Date(r.createdAt).toLocaleString()}
                      {r.latencyMs ? ` · ${r.latencyMs} ms` : ''}
                    </Typography>
                  </Box>
                  <Typography variant='body2' color='text.secondary' sx={{ mb: 0.5 }}>
                    <strong>User:</strong> {r.userMessage || '—'}
                  </Typography>
                  <Typography variant='body2' sx={{ whiteSpace: 'pre-wrap' }}>
                    <strong>{r.ok ? 'Host' : 'Error'}:</strong> {r.ok ? r.reply : r.error}
                  </Typography>
                </Box>
              ))}
            </Box>
          </Grid>
        </Grid>
      </CardContent>
    </Card>
  )
}

export default AiUsagePanel
