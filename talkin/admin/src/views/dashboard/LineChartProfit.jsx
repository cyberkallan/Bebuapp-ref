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
import CardHeader from '@mui/material/CardHeader'
import { useTheme } from '@mui/material/styles'
import Box from '@mui/material/Box'
import CircularProgress from '@mui/material/CircularProgress'

// Styled Component Imports
const AppReactApexCharts = dynamic(() => import('@/libs/styles/AppReactApexCharts'), { ssr: false })

const LineChartProfit = () => {
  // Hooks
  const theme = useTheme()
  const { graphStats, loading, metrics } = useSelector(state => state.dashboard)
  const videoStats = graphStats.video || []
  const [chartMounted, setChartMounted] = useState(false)

  // Wait until component is mounted before rendering chart
  useEffect(() => {
    setChartMounted(true)
  }, [])

  // Format the data for the chart
  const chartData =
    videoStats.length > 0
      ? [
          {
            data: videoStats.map(item => item.count || 0),
            name: 'Videos'
          }
        ]
      : [
          {
            data: [0, 0, 0], // Default data with multiple points
            name: 'Videos'
          }
        ]

  const chartLabels =
    videoStats.length > 0
      ? videoStats.map(item => {
          if (!item || !item._id) return 'Invalid Date'

          try {
            const date = new Date(item._id)

            return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
          } catch (e) {
            return 'Invalid Date'
          }
        })
      : ['Day 1', 'Day 2', 'Day 3'] // Default labels with multiple points

  // Calculate total videos
  const totalVideos = metrics.totalVideos || videoStats.reduce((sum, item) => sum + (item.count || 0), 0) || 0

  // Calculate percentage change (dummy calculation for demo)
  const percentChange = videoStats.length > 1 ? '+12.5%' : '+0%'

  // Vars
  const infoColor = 'var(--mui-palette-info-main)'

  const options = {
    chart: {
      parentHeightOffset: 0,
      toolbar: { show: false }
    },
    tooltip: { enabled: true },
    grid: {
      strokeDashArray: 6,
      borderColor: 'var(--mui-palette-divider)',
      xaxis: {
        lines: { show: true }
      },
      yaxis: {
        lines: { show: false }
      },
      padding: {
        top: -20,
        left: -5,
        right: 10,
        bottom: -10
      }
    },
    stroke: {
      width: 3,
      lineCap: 'butt',
      curve: 'straight'
    },
    colors: [infoColor],
    markers: {
      size: 4,
      strokeWidth: 3,
      colors: infoColor,
      strokeColors: 'transparent',
      discrete:
        chartData[0]?.data?.length > 0
          ? [
              {
                size: 5.5,
                seriesIndex: 0,
                strokeColor: infoColor,
                fillColor: 'var(--mui-palette-background-paper)',
                dataPointIndex: (chartData[0]?.data?.length || 1) - 1
              }
            ]
          : []
    },
    xaxis: {
      categories: chartLabels,
      labels: { show: true },
      axisTicks: { show: false },
      axisBorder: { show: false }
    },
    yaxis: {
      labels: { show: false }
    },
    responsive: [
      {
        breakpoint: theme.breakpoints.values.lg,
        options: {
          chart: { height: 120 }
        }
      },
      {
        breakpoint: theme.breakpoints.values.md,
        options: {
          chart: { height: 150 }
        }
      },
      {
        breakpoint: 430,
        options: {
          chart: { height: 180 }
        }
      }
    ]
  }

  const renderChart = () => {
    if (!chartMounted) return null

    return <AppReactApexCharts type='line' height={120} width='100%' options={options} series={chartData} />
  }

  return (
    <Card>
      <CardHeader title='Videos' subheader='Video Upload Trend' className='pbe-0' />
      <CardContent className='flex flex-col gap-3 pbs-3'>
        {loading.graphStats.video ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}>
            <CircularProgress size={40} />
          </Box>
        ) : (
          renderChart()
        )}
        <div className='flex items-center justify-between flex-wrap gap-x-4 gap-y-0.5'>
          <Typography variant='h4' color='text.primary'>
            {totalVideos}
          </Typography>
          <Typography variant='body2' color='success.main'>
            {percentChange}
          </Typography>
        </div>
      </CardContent>
    </Card>
  )
}

export default LineChartProfit
