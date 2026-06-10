import { MapContainer, TileLayer, Marker, Tooltip } from 'react-leaflet';
import L from 'leaflet';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';
import { useEffect } from 'react';

// Fix for default marker in Vite
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
});

export default function WarehouseMap({ warehouses = [], height = '350px' }) {
  // Center map on Indonesia if no warehouses
  const center = warehouses.length > 0 
    ? [warehouses[0].lat, warehouses[0].lng] 
    : [-0.7893, 113.9213]; 
    
  const zoom = warehouses.length > 0 ? 5 : 4;

  const mapTileUrl = import.meta.env.VITE_MAP_TILE_URL || 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  return (
    <div style={{ height, width: '100%', borderRadius: '8px', overflow: 'hidden', border: '1px solid #E5E7EB', zIndex: 0 }}>
      <MapContainer center={center} zoom={zoom} style={{ height: '100%', width: '100%' }}>
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url={mapTileUrl}
        />
        {warehouses.map((w) => (
          w.lat && w.lng && (
            <Marker key={w.warehouse_id} position={[w.lat, w.lng]}>
              <Tooltip>
                <div className="font-semibold">{w.nama_gudang}</div>
                <div className="text-xs text-gray-500 max-w-[200px] whitespace-normal">{w.alamat}</div>
              </Tooltip>
            </Marker>
          )
        ))}
      </MapContainer>
    </div>
  );
}
