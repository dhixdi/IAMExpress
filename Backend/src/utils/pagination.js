/**
 * Parse pagination parameters from the request query string.
 *
 * @param {object} query — req.query
 * @returns {{ page: number, per_page: number, offset: number, limit: number }}
 */
const getPaginationParams = (query) => {
  let page = parseInt(query.page, 10);
  if (!page || page < 1) page = 1;

  let per_page = parseInt(query.per_page, 10);
  if (!per_page || per_page < 1) per_page = 10;
  if (per_page > 100) per_page = 100;

  const offset = (page - 1) * per_page;
  const limit = per_page;

  return { page, per_page, offset, limit };
};

/**
 * Parse and validate sort parameters from the request query string.
 *
 * @param {object}   query          — req.query
 * @param {string[]} allowedColumns — whitelist of sortable column names
 * @param {string}   defaultSort    — fallback column (default 'created_at')
 * @returns {{ sort_by: string, order: string }}
 */
const getSortParams = (query, allowedColumns, defaultSort = 'created_at') => {
  let sort_by = query.sort_by;
  if (!sort_by || !allowedColumns.includes(sort_by)) {
    sort_by = defaultSort;
  }

  let order = (query.order || '').toLowerCase();
  if (order !== 'asc' && order !== 'desc') {
    order = 'desc';
  }

  return { sort_by, order };
};

/**
 * Build pagination meta object for the response.
 *
 * @param {number} page
 * @param {number} per_page
 * @param {number} total
 * @returns {{ page: number, per_page: number, total: number, total_pages: number }}
 */
const buildPaginationMeta = (page, per_page, total) => {
  return {
    page,
    per_page,
    total,
    total_pages: Math.ceil(total / per_page),
  };
};

module.exports = { getPaginationParams, getSortParams, buildPaginationMeta };
