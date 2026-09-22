'use client'

// Next Imports
import { useState, useEffect } from 'react'

import dynamic from 'next/dynamic'

// React Imports
import { useSelector } from 'react-redux'

// MUI Imports
import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import CircularProgress from '@mui/material/CircularProgress'
import { useTheme } from '@mui/material/styles'

// Styled Component Imports
const AppReactApexCharts = dynamic(() => import('@/libs/styles/AppReactApexCharts'), { ssr: false })

const ActivityOverview = () => {
  const theme = useTheme()
  const { graphStats, loading } = useSelector(state => state.dashboard)
  const [chartMounted, setChartMounted] = useState(false)

  // console.log(graphStats)

  // Wait until component is mounted before rendering chart
  useEffect(() => {
    setChartMounted(true)
  }, [])

  // Process data for each series
  const processChartData = (type, field = 'count') => {
    const typeData = Array.isArray(graphStats[type]) ? graphStats[type] : []

    if (!typeData || typeData.length === 0)
      return {
        dates: [],
        counts: []
      }

    try {
      const sortedData = [...typeData].sort((a, b) => {
        if (!a._id || !b._id) return 0

        return new Date(a._id) - new Date(b._id)
      })

      const dates = sortedData.map(item => {
        if (!item || !item._id) return ''

        try {
          const date = new Date(item._id)

          return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
        } catch (e) {
          return ''
        }
      })

      const counts = sortedData.map(item => item?.[field] || 0)

      return { dates, counts }
    } catch (error) {
      console.error(`Error processing ${type} data for field "${field}":`, error)

      return { dates: [], counts: [] }
    }
  }

  // Get data for all three series
  const listenerData = processChartData('listener')
  const userData = processChartData('user')

  // const videoReportData = processChartData('report', 'videoReports')
  // const postReportData = processChartData('report', 'postReports')
  // const userReportData = processChartData('report', 'userReports')

  // Get all unique dates across all series
  const getAllDates = () => {
    const allDates = [
      ...listenerData.dates,
      ...userData.dates,

      // ...videoReportData.dates,
      // ...postReportData.dates,
      // ...userReportData.dates
    ]

    const uniqueDates = [...new Set(allDates)].filter(date => date)

    // If we have no data, return some default dates
    if (uniqueDates.length === 0) {
      return ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Day 7']
    }

    return uniqueDates.sort((a, b) => {
      try {
        // Try to interpret as dates
        const dateA = new Date(a)
        const dateB = new Date(b)

        return dateA - dateB
      } catch (e) {
        // If dates can't be compared, sort alphabetically
        return a.localeCompare(b)
      }
    })
  }

  const chartCategories = getAllDates()

  // Create series with aligned data points
  const createAlignedSeries = (data, name, color) => {
    // Create a map of date to count
    const dateCountMap = {}

    data.dates.forEach((date, index) => {
      dateCountMap[date] = data.counts[index]
    })

    // Map through all categories and get corresponding count or 0
    const alignedCounts = chartCategories.map(date => dateCountMap[date] || 0)

    return {
      name,
      type: 'line',
      data: alignedCounts.length > 0 ? alignedCounts : [0, 0, 0, 0, 0, 0, 0],
      color
    }
  }

  // Generate chart series
  const series = [
    createAlignedSeries(userData, 'Users', theme.palette.warning.main),
    createAlignedSeries(listenerData, 'Listeners', theme.palette.success.main),
    
    // createAlignedSeries(videoData, 'Videos', theme.palette.primary.main),
    // createAlignedSeries(userReportData, 'User Reports', theme.palette.error.light),
    // createAlignedSeries(postReportData, 'Post Reports', theme.palette.info.main),
    // createAlignedSeries(videoReportData, 'Video Reports', theme.palette.secondary.main)
  ]

  const isDark = theme.palette.mode === 'dark'

  // Chart options
  const options = {
    chart: {
      parentHeightOffset: 0,
      toolbar: { show: false },
      stacked: false
    },
    plotOptions: {
      bar: {
        borderRadius: 4,
        columnWidth: '20%'
      }
    },
    stroke: {
      width: [2, 2, 2],
      curve: 'smooth'
    },
    legend: {
      show: true,
      position: 'top',
      horizontalAlign: 'left',
      fontSize: '14px',
      fontFamily: theme.typography.fontFamily,
      offsetY: 0,
      labels: {
        colors: isDark ? '#E0E0E0' : '#333333'
      },
      markers: {
        radius: 10,
        width: 10,
        height: 10
      },
      itemMargin: {
        horizontal: 10,
        vertical: 0
      }
    },
    grid: {
      borderColor: isDark ? '#5A5A5A' : '#E0E0E0',
      strokeDashArray: 6,
      padding: {
        top: 10
      },
      xaxis: {
        lines: { show: true }
      }
    },
    colors: [
      theme.palette.warning.main,
      theme.palette.success.main,
      theme.palette.primary.main,
      theme.palette.error.light,
      theme.palette.info.main,
      theme.palette.secondary.main
    ],
    xaxis: {
      categories:
        chartCategories.length > 0 ? chartCategories : ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Day 7'],
      tickAmount: 10,
      tickPlacement: 'on',
      labels: {
        show: true,
        style: {
          colors: isDark ? '#CCCCCC' : '#4B4B4B',
          fontSize: '12px',
          fontFamily: theme.typography.fontFamily
        }
      },
      axisTicks: { show: false, color: isDark ? '#666' : '#999' },
      axisBorder: { show: false }
    },
    yaxis: {
      min: 0,
      max: undefined,
      tickAmount: 4,
      labels: {
        style: {
          colors: isDark ? '#CCCCCC' : '#4B4B4B',
          fontSize: '12px',
          fontFamily: theme.typography.fontFamily
        }
      }
    },
    tooltip: {
      shared: true,
      intersect: false
    }
  }

  const renderChart = () => {
    if (!chartMounted) return null

    return <AppReactApexCharts type='line' height={350} options={options} series={series} />
  }

  const isLoading =
    loading.graphStats.video || loading.graphStats.post || loading.graphStats.user || loading.graphStats.report

  return (
    <Card>
      <CardHeader
        title='Activity Overview'

        // titleTypographyProps={{ sx: { fontWeight: 600, fontSize: '1.25rem' } }}
        subheader='Combined view of users and listeners activity'
        subheaderTypographyProps={{ sx: { color: 'text.disabled'} }}
      />
      <CardContent sx={{ pt: 0 }}>
        {isLoading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}>
            <CircularProgress size={40} />
          </Box>
        ) : (
          renderChart()
        )}
      </CardContent>
    </Card>
  )
}

export default ActivityOverview
