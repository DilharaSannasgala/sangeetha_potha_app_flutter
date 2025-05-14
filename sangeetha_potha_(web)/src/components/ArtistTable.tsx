import React, { useState, useEffect } from 'react';
import { getArtists, deleteArtist } from '../firebase/firebaseService';
import { Artist } from '../types/types';
import { Search, Trash2, RefreshCw } from 'lucide-react';

interface ArtistTableProps {
  refresh: boolean;
  onArtistDeleted: () => void;
}

const ArtistTable: React.FC<ArtistTableProps> = ({ refresh, onArtistDeleted }) => {
  const [artists, setArtists] = useState<Artist[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const loadArtists = async () => {
    setIsLoading(true);
    try {
      const artistsData = await getArtists();
      setArtists(artistsData);
    } catch (error) {
      console.error('Error loading artists:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadArtists();
  }, [refresh]);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await loadArtists();
    setIsRefreshing(false);
  };

  const handleDelete = async (artistId: string) => {
    if (window.confirm('Are you sure you want to delete this artist?')) {
      setDeletingId(artistId);
      try {
        await deleteArtist(artistId);
        setArtists(artists.filter(artist => artist.id !== artistId));
        onArtistDeleted();
        alert('Artist deleted successfully');
      } catch (error) {
        console.error('Error deleting artist:', error);
        alert('Failed to delete artist');
      } finally {
        setDeletingId(null);
      }
    }
  };

  const filteredArtists = artists.filter(artist => 
    artist.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    artist.id?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="bg-black/30 p-6 rounded-lg backdrop-blur-sm">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xl font-semibold text-white">Artists</h3>
        <button
          onClick={handleRefresh}
          disabled={isRefreshing}
          className="p-2 hover:bg-gray-800/50 rounded-full transition-colors disabled:opacity-50"
          title="Refresh Artists"
        >
          <RefreshCw size={20} className={`text-accent ${isRefreshing ? 'animate-spin' : ''}`} />
        </button>
      </div>
      
      <div className="relative mb-4">
        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Search size={18} className="text-gray-400" />
        </div>
        <input
          type="text"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Search Artists..."
          className="w-full pl-10 p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white placeholder-gray-400"
        />
      </div>
      
      <div className="max-h-[300px] overflow-y-auto rounded-lg border border-gray-700">
        {isLoading ? (
          <div className="p-4 text-center text-gray-400">Loading artists...</div>
        ) : filteredArtists.length > 0 ? (
          <div className="relative">
            <table className="min-w-full divide-y divide-gray-700">
              <thead className="bg-gray-800/80 sticky top-0 z-10">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">
                    Artist ID
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">
                    Name
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-400 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-transparent divide-y divide-gray-700">
                {filteredArtists.map((artist) => (
                  <tr key={artist.id} className="hover:bg-gray-800/30 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                      {artist.id}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                      {artist.name}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        onClick={() => artist.id && handleDelete(artist.id)}
                        disabled={deletingId === artist.id}
                        className="text-red-400 hover:text-red-300 disabled:opacity-50 transition-colors"
                        title="Delete Artist"
                      >
                        <Trash2 size={18} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="p-4 text-center text-gray-400">No artists found</div>
        )}
      </div>
    </div>
  );
};

export default ArtistTable;