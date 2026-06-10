export default function DataTable({ data = [], columns = [], isLoading, emptyMessage = 'Tidak ada data' }) {
  if (isLoading) {
    return (
      <div className="w-full border border-gray-200 rounded-lg overflow-hidden animate-pulse">
        <div className="bg-gray-50 h-10 w-full border-b border-gray-200"></div>
        {[...Array(5)].map((_, i) => (
          <div key={i} className="bg-white h-12 w-full border-b border-gray-100 px-4 flex items-center">
            <div className="h-4 bg-gray-200 rounded w-full max-w-[80%]"></div>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div className="w-full border border-gray-200 rounded-lg overflow-hidden bg-white shadow-sm">
      <div className="overflow-x-auto">
        <table className="w-full text-sm text-left text-gray-700">
          <thead className="text-xs text-gray-700 uppercase bg-gray-50 border-b border-gray-200">
            <tr>
              {columns.map((col, index) => (
                <th key={index} className="px-6 py-3 font-medium tracking-wider">
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.length === 0 ? (
              <tr>
                <td colSpan={columns.length} className="px-6 py-8 text-center text-gray-500">
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              data.map((row, rowIndex) => (
                <tr key={rowIndex} className="border-b border-gray-100 hover:bg-gray-50 transition-colors">
                  {columns.map((col, colIndex) => (
                    <td key={colIndex} className="px-6 py-4 whitespace-nowrap">
                      {col.render ? col.render(row) : row[col.accessor]}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
