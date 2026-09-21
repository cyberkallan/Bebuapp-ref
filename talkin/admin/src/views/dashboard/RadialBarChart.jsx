'use client'

// Next Imports
import { useState, useEffect } from 'react'

import dynamic from 'next/dynamic'

// React Imports
import { useSelector } from 'react-redux'

// MUI Imports
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import CardHeader from '@mui/material/CardHeader'
import Box from '@mui/material/Box'
import CircularProgress from '@mui/material/CircularProgress'

// Styled Component Imports
const AppReactApexCharts = dynamic(() => import('@/libs/styles/AppReactApexCharts'), { ssr: false })

const RadialBarChart = () => {
  // State for client-side rendering
  const [chartMounted, setChartMounted] = useState(false)

  // Wait until component is mounted before rendering chart
  useEffect(() => {
    setChartMounted(true)
  }, [])

  // Redux state
  const { graphStats, loading, metrics } = useSelector(state => state.dashboard)
  const userStats = Array.isArray(graphStats.user) ? graphStats.user : []

  // Calculate total users from the API data
  const totalUsers =
    metrics.totalUsers || (userStats.length > 0 ? userStats.reduce((sum, item) => sum + (item.count || 0), 0) : 0)

  // Calculate percentage for the radial bar (using totalUsers as a percentage of target number)
  const targetUsers = 500 // Example target value
  const percentageComplete = Math.min(Math.round((totalUsers / targetUsers) * 100), 100) || 0

  // Series data for the chart
  const series = [percentageComplete]

  // Vars
  const options = {
    chart: {
      sparkline: { enabled: true },
      parentHeightOffset: 0
    },
    grid: {
      padding: {
        bottom: 5
      }
    },
    stroke: {
      lineCap: 'round',
      curve: 'smooth'
    },
    colors: ['var(--mui-palette-warning-main)'],
    plotOptions: {
      radialBar: {
        endAngle: 90,
        startAngle: -90,
        hollow: { size: '60%' },
        track: { background: 'var(--mui-palette-divider)', strokeWidth: '40%' },
        dataLabels: {
          name: { show: false },
          value: {
            offsetY: 0,
            fontWeight: 500,
            fontSize: '1.5rem',
            color: 'var(--mui-palette-text-primary)',
            formatter: function (val) {
              return `${val}%`
            }
          }
        }
      }
    },
    responsive: [
      {
        breakpoint: 1200,
        options: {
          chart: {
            width: 190,
            height: 132
          },
          plotOptions: {
            radialBar: {
              dataLabels: {
                value: {
                  fontSize: '1.5rem'
                }
              }
            }
          }
        }
      },
      {
        breakpoint: 900,
        options: {
          chart: {
            width: 195,
            height: 232
          },
          plotOptions: {
            radialBar: {
              dataLabels: {
                value: {
                  fontSize: '1.5rem'
                }
              }
            }
          }
        }
      }
    ]
  }

  const renderChart = () => {
    if (!chartMounted) return null

    return <AppReactApexCharts type='radialBar' height={148} width='100%' options={options} series={series} />
  }

  return (
    <Card>
      <CardHeader title={`${totalUsers}`} subheader='Total Users' className='pbe-0' />
      <CardContent className='flex flex-col gap-3 items-center'>
        {loading.graphStats.user ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}>
            <CircularProgress size={40} />
          </Box>
        ) : (
          renderChart()
        )}
        <Typography variant='body2' color='text.disabled' className='sm:mbs-2 lg:mbs-0'>
          {totalUsers > 0 ? `${percentageComplete}% of target reached` : 'No user data available'}
        </Typography>
      </CardContent>
    </Card>
  )
}

export default RadialBarChart
