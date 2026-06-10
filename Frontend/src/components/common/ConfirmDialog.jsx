import { X } from 'lucide-react';

export default function ConfirmDialog({
  open,
  title,
  description,
  onConfirm,
  onCancel,
  confirmLabel = 'Konfirmasi',
  variant = 'default',
}) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-xl shadow-modal w-full max-w-md overflow-hidden">
        <div className="flex items-center justify-between p-4 border-b border-gray-100">
          <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
          <button onClick={onCancel} className="p-1 text-gray-500 hover:text-gray-700 rounded-md hover:bg-gray-100 transition-colors">
            <X size={20} />
          </button>
        </div>
        <div className="p-4">
          <p className="text-sm text-gray-600">{description}</p>
        </div>
        <div className="flex items-center justify-end gap-3 p-4 bg-gray-50 border-t border-gray-100">
          <button
            onClick={onCancel}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-navy-900"
          >
            Batal
          </button>
          <button
            onClick={onConfirm}
            className={`px-4 py-2 text-sm font-medium text-white rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 ${
              variant === 'destructive'
                ? 'bg-red-600 hover:bg-red-700 focus:ring-red-600'
                : 'bg-navy-950 hover:bg-navy-900 focus:ring-navy-950'
            }`}
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
