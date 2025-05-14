import React, { useState } from 'react';
import { addArtist } from '../firebase/firebaseService';
import { Music } from 'lucide-react';

interface ArtistFormProps {
  onArtistAdded: () => void;
}

const ArtistForm: React.FC<ArtistFormProps> = ({ onArtistAdded }) => {
  const [artistId, setArtistId] = useState('');
  const [artistName, setArtistName] = useState('');
  const [artistCoverUrl, setArtistCoverUrl] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!artistId.trim() || !artistName.trim() || !artistCoverUrl.trim()) {
      alert('Please fill out all fields');
      return;
    }
    
    setIsSubmitting(true);
    
    try {
      await addArtist(artistId, {
        name: artistName,
        artistCoverUrl
      });
      
      setArtistId('');
      setArtistName('');
      setArtistCoverUrl('');
      
      alert('Artist added successfully!');
      onArtistAdded();
    } catch (error) {
      console.error('Error adding artist:', error);
      alert('Failed to add artist. Check the console for details.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="bg-black/30 p-6 rounded-lg backdrop-blur-sm transform transition duration-300 hover:shadow-xl">
      <div className="flex items-center mb-6">
        <Music size={24} className="text-accent mr-3" />
        <h3 className="text-xl font-semibold text-white">Add Artist</h3>
      </div>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <input
            type="text"
            value={artistId}
            onChange={(e) => setArtistId(e.target.value)}
            placeholder="Enter Artist ID (manual)"
            className="w-full p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white placeholder-gray-400"
            required
          />
        </div>
        
        <div>
          <input
            type="text"
            value={artistName}
            onChange={(e) => setArtistName(e.target.value)}
            placeholder="Enter Artist Name"
            className="w-full p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white placeholder-gray-400"
            required
          />
        </div>
        
        <div>
          <input
            type="text"
            value={artistCoverUrl}
            onChange={(e) => setArtistCoverUrl(e.target.value)}
            placeholder="Enter Artist Cover URL"
            className="w-full p-3 bg-gray-800/50 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent text-white placeholder-gray-400"
            required
          />
        </div>
        
        <button
          type="submit"
          disabled={isSubmitting}
          className="w-full bg-accent hover:bg-accent/90 text-black font-bold py-3 px-4 rounded-lg transition-all transform hover:scale-[1.02] active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed"
        >
          {isSubmitting ? 'Adding...' : 'Add Artist'}
        </button>
      </form>
    </div>
  );
};

export default ArtistForm;