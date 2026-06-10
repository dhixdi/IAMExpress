import { PACKAGE_STATUS } from '../constants/packageStatus';

export function statusColor(status) {
  switch (status) {
    case PACKAGE_STATUS.CREATED:
      return 'bg-status-created-bg text-status-created-text border-status-created-border';
    case PACKAGE_STATUS.RECEIVED_AT_WAREHOUSE:
      return 'bg-status-received-bg text-status-received-text border-status-received-border';
    case PACKAGE_STATUS.ASSIGNED_TO_LINEHAUL:
      return 'bg-status-linehaul-bg text-status-linehaul-text border-status-linehaul-border';
    case PACKAGE_STATUS.PICKED_UP:
      return 'bg-status-pickedup-bg text-status-pickedup-text border-status-pickedup-border';
    case PACKAGE_STATUS.IN_TRANSIT:
      return 'bg-status-transit-bg text-status-transit-text border-status-transit-border';
    case PACKAGE_STATUS.ARRIVED_AT_WAREHOUSE:
      return 'bg-status-arrived-bg text-status-arrived-text border-status-arrived-border';
    case PACKAGE_STATUS.ASSIGNED_TO_COURIER:
      return 'bg-status-courier-bg text-status-courier-text border-status-courier-border';
    case PACKAGE_STATUS.OUT_FOR_DELIVERY:
      return 'bg-status-outdelivery-bg text-status-outdelivery-text border-status-outdelivery-border';
    case PACKAGE_STATUS.DELIVERED:
      return 'bg-status-delivered-bg text-status-delivered-text border-status-delivered-border';
    case PACKAGE_STATUS.FAILED_DELIVERY:
      return 'bg-status-failed-bg text-status-failed-text border-status-failed-border';
    default:
      return 'bg-gray-100 text-gray-800 border-gray-300';
  }
}
