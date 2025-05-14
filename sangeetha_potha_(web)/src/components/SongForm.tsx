import React, { useState, useEffect } from 'react';
import { addSong, getArtists } from '../firebase/firebaseService';
import { Artist } from '../types/types';
import { Music, RefreshCw } from 'lucide-react';

interface SongFormProps {
  onSongAdded: () => void;
  onRefreshTables: () => void;
}

const SongForm: React.FC<SongFormProps> = ({ onSongAdded, onRefreshTables }) => {
  const [songTitle, setSongTitle] = useState('');
  const [songCoverUrl, setSongCoverUrl] = useState('');
  const [songLyrics, setSongLyrics] = useState('');
  const [artistId, setArtistId] = useState('');
  const [artists, setArtists] = useState<Artist[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const loadArtists = async () => {
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
  }, []);

  useEffect(() => {
    loadArtists();
  }, [onRefreshTables]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!songTitle.trim() || !songCoverUrl.trim() || !songLyrics.trim() || !artistId) {
      alert('Please fill out all fields and select an artist');
      return;
    }
    
    setIsSubmitting(true);
    
    try {
      await addSong({
        title: songTitle,
        songCoverUrl,
        lyrics: songLyrics,
        artistId,
        isFav: false
      });
      
      setSongTitle('');
      setSongCoverUrl('');
      setSongLyrics('');
      setArtistId('');
      
      alert('Song added successfully!');
      onSongAdded();
    } catch (error) {
      console.error('Error adding song:', error);
      alert('Failed to add song. Check the console for details.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="bg-black/30 p-6 rounded-lg backdrop-blur-sm transform transition duration-300 hover:shadow-xl">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center">
          <Music size={24} className="text-accent mr-3" />
          <h3 className="text-xl font-semibold text-white">Add Song</h3>
        </div>
        <button
          onClick={onRefreshTables}
          className="p-2 hover:bg-gray-800/50 rounded-full transition-colors"
          title="Refresh Tables"
        >
          <RefreshCw size={20} className="text-accent" />
        </button>
      </div>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <input
            type="text"
            value={songTitle}
            onChange={(e) => setSongTitle(e.target.value)}
            placeholder="Enter Song Title"
            className="w-full p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white placeholder-gray-400"
            required
          />
        </div>
        
        <div>
          <input
            type="text"
            value={songCoverUrl}
            onChange={(e) => setSongCoverUrl(e.target.value)}
            placeholder="Enter Song Cover URL"
            className="w-full p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white placeholder-gray-400"
            required
          />
        </div>
        
        <div>
          <textarea
            value={songLyrics}
            onChange={(e) => setSongLyrics(e.target.value)}
            placeholder="Enter Song Lyrics"
            className="w-full p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white placeholder-gray-400 min-h-[120px] resize-y"
            required
          />
        </div>
        
        <div>
          <select
            title='Select Artist'
            value={artistId}
            onChange={(e) => setArtistId(e.target.value)}
            className="w-full p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white"
            required
            disabled={isLoading}
          >
            <option value="">Select Artist</option>
            {artists.map((artist) => (
              <option key={artist.id} value={artist.id}>
                {artist.name}
              </option>
            ))}
          </select>
        </div>
        
        <button
          type="submit"
          disabled={isSubmitting}
          className="w-full bg-accent hover:bg-accent/90 text-black font-bold py-3 px-4 rounded-lg transition-all transform hover:scale-[1.02] active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed"
        >
          {isSubmitting ? 'Adding...' : 'Add Song'}
        </button>
      </form>
    </div>
  );
};

export default SongForm;