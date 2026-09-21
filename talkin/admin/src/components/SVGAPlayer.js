'use client'
import React, { useEffect, useRef, useState } from 'react'

import SVGA from 'svgaplayerweb'

const SVGAPlayer = ({ url, width = 300, height = 200, onError }) => {
  const canvasRef = useRef(null)
  const playerRef = useRef(null)
  const [loading, setLoading] = useState(true)
  const [loadError, setLoadError] = useState(null)

  useEffect(() => {
    setLoading(true)
    setLoadError(null)

    const player = new SVGA.Player(canvasRef.current)
    const parser = new SVGA.Parser()

    player.loops = 0 // 0 = infinite
    player.clearsAfterStop = true
    playerRef.current = player

    const loadTimeout = setTimeout(() => {
      if (loading && !loadError) {
        const errorMessage = 'Loading timed out. Please check your connection and try again.'

        setLoadError(errorMessage)
        if (onError) onError(new Error(errorMessage))
      }
    }, 15000) // 15 seconds timeout

    parser.load(
      url,
      videoItem => {
        clearTimeout(loadTimeout)
        player.setVideoItem(videoItem)
        player.startAnimation()
        setLoading(false)
      },
      error => {
        clearTimeout(loadTimeout)
        const errorMessage = 'Failed to load animation'

        console.error('Failed to load SVGA:', error)
        setLoadError(errorMessage)
        setLoading(false)
        if (onError) onError(error || new Error(errorMessage))
      }
    )

    return () => {
      clearTimeout(loadTimeout)

      if (player) {
        player.stopAnimation()
        player.clear()
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [url, onError])

  // Function to retry loading
  const handleRetry = () => {
    setLoading(true)
    setLoadError(null)

    const player = playerRef.current

    if (player) {
      player.stopAnimation()
      player.clear()
    }

    const parser = new SVGA.Parser()

    parser.load(
      url,
      videoItem => {
        player.setVideoItem(videoItem)
        player.startAnimation()
        setLoading(false)
      },
      error => {
        console.error('Failed to reload SVGA:', error)
        setLoadError('Failed to load animation')
        setLoading(false)
        if (onError) onError(error || new Error('Failed to reload animation'))
      }
    )
  }

  return (
    <div style={{ position: 'relative', width, height }}>
      <canvas
        ref={canvasRef}
        width={width}
        height={height}
        style={{ opacity: loading ? 0 : 1, transition: 'opacity 0.3s ease-in-out' }}
      />

      {loading && (
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: '100%',
            height: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: '#f5f5f5',
            borderRadius: '8px'
          }}
        >
          <div className='spinner'>
            <style jsx>{`
              .spinner {
                width: 40px;
                height: 40px;
                margin-bottom: 16px;
                border: 3px solid rgba(0, 0, 0, 0.1);
                border-radius: 50%;
                border-top-color: #3498db;
                animation: spin 1s ease-in-out infinite;
              }

              @keyframes spin {
                to {
                  transform: rotate(360deg);
                }
              }

              .pulse {
                animation: pulse 1.5s ease-in-out infinite;
              }

              @keyframes pulse {
                0% {
                  opacity: 0.6;
                }
                50% {
                  opacity: 1;
                }
                100% {
                  opacity: 0.6;
                }
              }
            `}</style>
          </div>
          <div className='pulse' style={{ fontSize: '14px', color: '#666' }}>
            {loadError ? loadError : 'Loading animation...'}
          </div>
        </div>
      )}

      {!loading && loadError && (
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: '100%',
            height: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: '#fff0f0',
            borderRadius: '8px'
          }}
        >
          <svg
            width='40'
            height='40'
            viewBox='0 0 24 24'
            fill='none'
            stroke='#e74c3c'
            strokeWidth='2'
            strokeLinecap='round'
            strokeLinejoin='round'
            style={{ marginBottom: '16px' }}
          >
            <circle cx='12' cy='12' r='10' />
            <line x1='12' y1='8' x2='12' y2='12' />
            <line x1='12' y1='16' x2='12.01' y2='16' />
          </svg>
          <div style={{ fontSize: '14px', color: '#e74c3c' }}>{loadError}</div>
          <button
            onClick={handleRetry}
            style={{
              marginTop: '16px',
              padding: '8px 16px',
              backgroundColor: '#e74c3c',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '14px'
            }}
          >
            Retry
          </button>
        </div>
      )}
    </div>
  )
}

export default SVGAPlayer
