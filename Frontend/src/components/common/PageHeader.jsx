import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

export default function PageHeader({ title, breadcrumb = [], action }) {
  return (
    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div>
        <h1 className="text-2xl font-semibold text-gray-950">{title}</h1>
        {breadcrumb.length > 0 && (
          <nav className="flex items-center space-x-2 mt-1 text-sm text-gray-500">
            {breadcrumb.map((item, index) => (
              <div key={index} className="flex items-center">
                {index > 0 && <ChevronRight size={14} className="mx-1" />}
                {item.href ? (
                  <Link to={item.href} className="hover:text-navy-900 hover:underline">
                    {item.label}
                  </Link>
                ) : (
                  <span className="text-gray-700 font-medium">{item.label}</span>
                )}
              </div>
            ))}
          </nav>
        )}
      </div>
      {action && <div>{action}</div>}
    </div>
  );
}
