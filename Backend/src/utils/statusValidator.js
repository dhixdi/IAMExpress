/**
 * Valid status transitions for a package.
 * Key = current status, Value = array of allowed next statuses.
 */
const VALID_TRANSITIONS = {
  'Created': ['Assigned to Linehaul', 'Assigned to Courier', 'Received at Warehouse'],
  'Received at Warehouse': ['Assigned to Linehaul', 'Assigned to Courier', 'Arrived at Warehouse'],
  'Assigned to Linehaul': ['Picked Up', 'Arrived at Warehouse'],
  'Picked Up': ['In Transit'],
  'In Transit': ['Arrived at Warehouse'],
  'Arrived at Warehouse': ['Assigned to Courier', 'Assigned to Linehaul'],
  'Assigned to Courier': ['Out For Delivery'],
  'Out For Delivery': ['Delivered', 'Failed Delivery'],
  'Failed Delivery': ['Assigned to Courier'],
};

/**
 * Which statuses each role is allowed to set.
 */
const ROLE_ALLOWED_STATUSES = {
  'WAREHOUSE_ADMIN': ['Received at Warehouse', 'Assigned to Linehaul', 'Assigned to Courier', 'Arrived at Warehouse', 'Failed Delivery'],
  'LINEHAUL': ['Picked Up', 'In Transit', 'Arrived at Warehouse'],
  'COURIER': ['Out For Delivery', 'Delivered', 'Failed Delivery'],
};

/**
 * Check whether transitioning from currentStatus to newStatus is valid.
 *
 * @param {string} currentStatus
 * @param {string} newStatus
 * @returns {boolean}
 */
const isValidTransition = (currentStatus, newStatus) => {
  const allowed = VALID_TRANSITIONS[currentStatus];
  if (!allowed) return false;
  return allowed.includes(newStatus);
};

/**
 * Get the list of statuses a given role is permitted to set.
 *
 * @param {string} role
 * @returns {string[]}
 */
const getAllowedStatuses = (role) => {
  return ROLE_ALLOWED_STATUSES[role] || [];
};

/**
 * Check whether a role is allowed to set a specific status.
 *
 * @param {string} role
 * @param {string} status
 * @returns {boolean}
 */
const canRoleSetStatus = (role, status) => {
  const allowed = ROLE_ALLOWED_STATUSES[role];
  if (!allowed) return false;
  return allowed.includes(status);
};

module.exports = {
  VALID_TRANSITIONS,
  ROLE_ALLOWED_STATUSES,
  isValidTransition,
  getAllowedStatuses,
  canRoleSetStatus,
};
