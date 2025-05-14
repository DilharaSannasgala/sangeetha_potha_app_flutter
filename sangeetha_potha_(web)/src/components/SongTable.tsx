import React, { useState, useEffect } from 'react';
import { getSongs, deleteSong } from '../firebase/firebaseService';
import { Song } from '../types/types';
import { Search, Trash2, RefreshCw } from 'lucide-react';

interface SongTableProps {
  refresh: boolean;
  onSongDeleted: () => void;
}

const SongTable: React.FC<SongTableProps> = ({ refresh, onSongDeleted }) => {
  const [songs, setSongs] = useState<Song[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const loadSongs = async () => {
    setIsLoading(true);
    try {
      const songsData = await getSongs();
      setSongs(songsData);
    } catch (error) {
      console.error('Error loading songs:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadSongs();
  }, [refresh]);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await loadSongs();
    setIsRefreshing(false);
  };

  const handleDelete = async (songId: string) => {
    if (window.confirm('Are you sure you want to delete this song?')) {
      setDeletingId(songId);
      try {
        await deleteSong(songId);
        setSongs(songs.filter(song => song.id !== songId));
        onSongDeleted();
        alert('Song deleted successfully');
      } catch (error) {
        console.error('Error deleting song:', error);
        alert('Failed to delete song');
      } finally {
        setDeletingId(null);
      }
    }
  };

  const filteredSongs = songs.filter(song => 
    song.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    song.artistId.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="bg-black/30 p-6 rounded-lg backdrop-blur-sm">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xl font-semibold text-white">Songs</h3>
        <button
          onClick={handleRefresh}
          disabled={isRefreshing}
          className="p-2 hover:bg-gray-800/50 rounded-full transition-colors disabled:opacity-50"
          title="Refresh Songs"
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
          placeholder="Search Songs..."
          className="w-full pl-10 p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white placeholder-gray-400"
        />
      </div>
      
      <div className="max-h-[300px] overflow-y-auto rounded-lg border border-gray-700">
        {isLoading ? (
          <div className="p-4 text-center text-gray-400">Loading songs...</div>
        ) : filteredSongs.length > 0 ? (
          <div className="relative">
            <table className="min-w-full divide-y divide-gray-700">
              <thead className="bg-gray-800/80 sticky top-0 z-10">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">
                    Title
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">
                    Artist ID
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-400 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-transparent divide-y divide-gray-700">
                {filteredSongs.map((song) => (
                  <tr key={song.id} className="hover:bg-gray-800/30 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                      {song.title}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                      {song.artistId}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        onClick={() => song.id && handleDelete(song.id)}
                        disabled={deletingId === song.id}
                        className="text-red-400 hover:text-red-300 disabled:opacity-50 transition-colors"
                        title="Delete Song"
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
          <div className="p-4 text-center text-gray-400">No songs found</div>
        )}
      </div>
    </div>
  );
};

export default SongTable;