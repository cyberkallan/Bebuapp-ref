// Date formatting functions

/**
 * Format a date string to a readable format
 * @param {string|Date} date - The date to format
 * @returns {string} Formatted date string
 */
export const formatDate = date => {
  if (!date) return '--'

  const dateObj = typeof date === 'string' ? new Date(date) : date

  if (isNaN(dateObj.getTime())) return '--'

  return dateObj.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

/**
 * Format a date string to a readable format with time
 * @param {string|Date} date - The date to format
 * @returns {string} Formatted date and time string
 */
export const formatDateTime = date => {
  if (!date) return '--'

  const dateObj = typeof date === 'string' ? new Date(date) : date

  if (isNaN(dateObj.getTime())) return '--'

  return dateObj.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

/**
 * Format duration in seconds to readable format
 * @param {number} seconds - Duration in seconds
 * @returns {string} Formatted duration string
 */
export const formatDuration = seconds => {
  if (!seconds || isNaN(seconds)) return '--'

  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60

  if (mins < 60) {
    return `${mins}m ${secs}s`
  }

  const hours = Math.floor(mins / 60)
  const remainingMins = mins % 60

  return `${hours}h ${remainingMins}m ${secs}s`
}
