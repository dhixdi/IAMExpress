export default function EmptyState({ title, description, icon, action }) {
  return (
    <div className="flex flex-col items-center justify-center py-12 px-4 text-center border-2 border-dashed border-gray-200 rounded-lg bg-gray-50">
      {icon && <div className="mb-4 text-gray-400">{icon}</div>}
      <h3 className="text-sm font-medium text-gray-900">{title}</h3>
      {description && <p className="mt-1 text-sm text-gray-500 max-w-sm">{description}</p>}
      {action && <div className="mt-6">{action}</div>}
    </div>
  );
}
