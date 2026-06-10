import { MapContainer, TileLayer, Marker, Tooltip } from 'react-leaflet';
import L from 'leaflet';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

// Fix for default marker in Vite
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
});

export default function PackageMap({ receiverLat, receiverLng, label, height = '300px' }) {
  const center = receiverLat && receiverLng ? [receiverLat, receiverLng] : [-0.7893, 113.9213];
  const zoom = receiverLat && receiverLng ? 13 : 4;

  const mapTileUrl = import.meta.env.VITE_MAP_TILE_URL || 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  return (
    <div style={{ height, width: '100%', borderRadius: '8px', overflow: 'hidden', border: '1px solid #E5E7EB', zIndex: 0 }}>
      <MapContainer center={center} zoom={zoom} style={{ height: '100%', width: '100%' }}>
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url={mapTileUrl}
        />
        {receiverLat && receiverLng && (
          <Marker position={[receiverLat, receiverLng]}>
            {label && (
              <Tooltip permanent={false} direction="top">
                <div className="max-w-[200px] whitespace-normal text-xs">{label}</div>
              </Tooltip>
            )}
          </Marker>
        )}
      </MapContainer>
    </div>
  );
}
