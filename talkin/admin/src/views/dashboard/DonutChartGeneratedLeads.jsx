'use client'

// Next Imports
import { useState, useEffect } from 'react'

import dynamic from 'next/dynamic'

// React Imports
import { useSelector } from 'react-redux'

// MUI Imports
import Card from '@mui/material/Card'
import Typography from '@mui/material/Typography'
import CardContent from '@mui/material/CardContent'
import { useTheme } from '@mui/material/styles'
import Box from '@mui/material/Box'
import CircularProgress from '@mui/material/CircularProgress'

// Styled Component Imports
const AppReactApexCharts = dynamic(() => import('@/libs/styles/AppReactApexCharts'), { ssr: false })

const DonutChartGeneratedLeads = () => {
  // Hook
  const theme = useTheme()
  const [chartMounted, setChartMounted] = useState(false)

  // Wait until component is mounted before rendering chart
  useEffect(() => {
    setChartMounted(true)
  }, [])

  // Redux state
  const { graphStats, loading, metrics } = useSelector(state => state.dashboard)
  const postStats = Array.isArray(graphStats.post) ? graphStats.post : []

  // Calculate total posts from the API data
  const totalPosts =
    metrics.totalPosts || (postStats.length > 0 ? postStats.reduce((sum, item) => sum + (item.count || 0), 0) : 0)

  // Generate series data for the chart - for this example we'll categorize posts by their count
  const getPostCategories = () => {
    if (!postStats || postStats.length === 0) return [25, 25, 25, 25]

    try {
      // Sort posts by date to get the latest first
      const sortedPosts = [...postStats].sort((a, b) => {
        if (!a._id || !b._id) return 0

        return new Date(b._id) - new Date(a._id)
      })

      // If we have less than 4 data points, pad with zeros
      if (sortedPosts.length < 4) {
        const counts = sortedPosts.map(post => post.count || 0)

        while (counts.length < 4) {
          counts.push(0)
        }

        return counts
      }

      // Otherwise, use the most recent 4 data points
      return sortedPosts.slice(0, 4).map(post => post.count || 0)
    } catch (error) {
      console.error('Error processing post data:', error)

      return [25, 25, 25, 25]
    }
  }

  const series = getPostCategories()

  // Generate labels for the chart based on dates
  const getPostLabels = () => {
    if (!postStats || postStats.length === 0) return ['No Data', 'No Data', 'No Data', 'No Data']

    try {
      // Sort posts by date to get the latest first
      const sortedPosts = [...postStats].sort((a, b) => {
        if (!a._id || !b._id) return 0

        return new Date(b._id) - new Date(a._id)
      })

      // Format dates for labels
      const labels = sortedPosts.slice(0, 4).map(post => {
        if (!post || !post._id) return 'Invalid Date'

        try {
          const date = new Date(post._id)

          return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
        } catch (e) {
          return 'Invalid Date'
        }
      })

      // Pad with placeholder labels if needed
      while (labels.length < 4) {
        labels.push('No Data')
      }

      return labels
    } catch (error) {
      console.error('Error processing post label data:', error)

      return ['No Data', 'No Data', 'No Data', 'No Data']
    }
  }

  const labels = getPostLabels()

  // Calculate percentage change (dummy calculation for demo)
  const percentChange = postStats.length > 1 ? '+15.8%' : '+0%'

  // Vars
  const textSecondary = 'var(--mui-palette-text-secondary)'
  const successColor = 'var(--mui-palette-success-main)'

  const options = {
    colors: [
      successColor,
      'rgba(var(--mui-palette-success-mainChannel) / 0.7)',
      'rgba(var(--mui-palette-success-mainChannel) / 0.5)',
      'var(--mui-palette-success-lightOpacity)'
    ],
    stroke: { width: 0 },
    legend: { show: false },
    tooltip: { enabled: true, theme: 'false' },
    dataLabels: { enabled: false },
    labels: labels,
    states: {
      hover: {
        filter: { type: 'none' }
      },
      active: {
        filter: { type: 'none' }
      }
    },
    grid: {
      padding: {
        top: -22,
        bottom: -18
      }
    },
    plotOptions: {
      pie: {
        customScale: 0.8,
        expandOnClick: false,
        donut: {
          size: '73%',
          labels: {
            show: true,
            name: {
              offsetY: 25,
              color: textSecondary,
              fontFamily: theme.typography.fontFamily
            },
            value: {
              offsetY: -15,
              fontWeight: 500,
              formatter: val => `${val}`,
              color: 'var(--mui-palette-text-primary)',
              fontFamily: theme.typography.fontFamily,
              fontSize: theme.typography.h3.fontSize
            },
            total: {
              show: true,
              showAlways: true,
              label: 'Total',
              color: successColor,
              fontFamily: theme.typography.fontFamily,
              fontSize: theme.typography.body1.fontSize
            }
          }
        }
      }
    },
    responsive: [
      {
        breakpoint: theme.breakpoints.values.xl,
        options: {
          chart: { width: 200, height: 237 }
        }
      },
      {
        breakpoint: theme.breakpoints.values.md,
        options: {
          chart: { width: 150, height: 199 }
        }
      }
    ]
  }

  const renderChart = () => {
    if (!chartMounted) return null

    return <AppReactApexCharts type='donut' width={150} height={177} series={series} options={options} />
  }

  return (
    <Card className='overflow-visible'>
      <CardContent className='flex justify-between gap-4'>
        <div className='flex flex-col justify-between'>
          <div className='flex flex-col'>
            <Typography variant='h5'>Total Posts</Typography>
            <Typography>Monthly Report</Typography>
          </div>
          <div className='flex flex-col items-start'>
            <Typography variant='h3'>{totalPosts}</Typography>
            <div className='flex items-center gap-1'>
              <i className='tabler-chevron-up text-success text-xl'></i>
              <Typography color='success.main' component='span'>
                {percentChange}
              </Typography>
            </div>
          </div>
        </div>
        {loading.graphStats.post ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', width: 150, height: 177 }}>
            <CircularProgress size={40} />
          </Box>
        ) : (
          renderChart()
        )}
      </CardContent>
    </Card>
  )
}

export default DonutChartGeneratedLeads
