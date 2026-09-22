// MUI Imports
import Pagination from '@mui/material/Pagination'
import Typography from '@mui/material/Typography'

/**
 * TablePaginationComponent - A reusable pagination component for tables
 *
 * @param {Object} props
 * @param {Object} [props.table] - Optional table instance from useReactTable
 * @param {number} props.page - Current page number (1-indexed)
 * @param {number} props.pageSize - Number of items per page
 * @param {number} props.total - Total number of items
 * @param {Function} props.onPageChange - Callback when page changes, receives the new page number (1-indexed)
 * @param {string} [props.customText] - Optional custom text to display instead of default pagination info
 */
const TablePaginationComponent = ({ table, page, pageSize, total, onPageChange, customText }) => {
  // Handle page change
  const handlePageChange = (_, newPage) => {
    if (onPageChange) {
      onPageChange(newPage)
    }
  }

  return (
    <div className='flex justify-between items-center flex-wrap pli-6 border-bs bs-auto plb-[12.5px] gap-2'>
      <Typography color='text.disabled'>
        {customText ||
          `Showing ${total === 0 ? 0 : (page - 1) * pageSize + 1} to
           ${Math.min(page * pageSize, total)} of ${total} entries`}
      </Typography>
      <Pagination
        shape='rounded'
        color='primary'
        variant='tonal'
        count={Math.ceil(total / pageSize)}
        page={page}
        onChange={handlePageChange}
        showFirstButton
        showLastButton
      />
    </div>
  )
}

export default TablePaginationComponent
