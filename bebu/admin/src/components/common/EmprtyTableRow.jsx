const EmprtyTableRow = ({ limit = 10, data , columns , noDataLebel , paddingClass }) => {
  return limit > data.length
  
    // ? new Array(limit - data.length).fill(null).map((_, index) => (
    //     <tr key={`empty-row-${index}`} style={{ border: 'none' }}>
    //       <td colSpan={columns.length} className='text-center py-4 text-gray-400 '></td>
    //     </tr>
    //   ))
    ?  [...Array(limit -data.length)].map((_, index) => (
        <tr key={index} className="border-t border-b">
          <td colSpan={columns.length || 25} className={`text-center py-4 ` + paddingClass}>
            {(index === 3 && !data.length)? ( // Show message in the middle row (5th of 10)
              <div className="text-gray-500 font-medium">{noDataLebel || "No Data Found"}</div>
            ) : ""}
          </td>
        </tr>
      ))
    : null
}

export default EmprtyTableRow
