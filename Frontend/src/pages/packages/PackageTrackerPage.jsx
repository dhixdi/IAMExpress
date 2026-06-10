import { useParams } from 'react-router-dom';
import { usePackage, usePackageTracker } from '../../hooks/usePackages';
import PageHeader from '../../components/common/PageHeader';
import PackageStatusTimeline from '../../components/packages/PackageStatusTimeline';
import PackageMap from '../../components/maps/PackageMap';
import StatusBadge from '../../components/common/StatusBadge';

export default function PackageTrackerPage() {
  const { id } = useParams();
  
  const { data: pkg, isLoading: isLoadingPkg } = usePackage(id);
  const { data: trackerResp, isLoading: isLoadingTracker } = usePackageTracker(id);

  if (isLoadingPkg || isLoadingTracker) return <div>Loading...</div>;
  if (!pkg) return <div>Paket tidak ditemukan</div>;

  const entries = trackerResp?.data || [];

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <PageHeader 
        title={`Tracker: ${pkg.resi}`} 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Packages', href: '/packages' }, { label: 'Tracker' }]}
      />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-card border border-gray-200 p-6">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-semibold text-gray-900">Riwayat Status</h3>
            <StatusBadge status={pkg.status} />
          </div>
          <PackageStatusTimeline entries={entries} />
        </div>

        <div className="space-y-6">
          <div className="bg-white rounded-xl shadow-card border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Peta Tujuan</h3>
            <PackageMap 
              receiverLat={pkg.receiver_lat} 
              receiverLng={pkg.receiver_lng} 
              label={pkg.receiver_name} 
              height="350px" 
            />
          </div>
          
          <div className="bg-white rounded-xl shadow-card border border-gray-200 p-6">
             <h3 className="text-sm font-semibold text-gray-900 uppercase tracking-wider mb-2">Informasi Rute (Estimasi)</h3>
             <p className="text-sm text-gray-600 mb-2"><strong>Asal:</strong> {pkg.sender_address}</p>
             <p className="text-sm text-gray-600"><strong>Tujuan:</strong> {pkg.receiver_address}</p>
             
             {pkg.receiver_lat && pkg.receiver_lng && (
                <div className="mt-4 text-xs text-gray-500 bg-gray-50 p-3 rounded border">
                  Geocoded Dest: [{pkg.receiver_lat}, {pkg.receiver_lng}]
                </div>
             )}
          </div>
        </div>
      </div>
    </div>
  );
}
