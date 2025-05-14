import React, { useState } from 'react';
import Header from './components/Header';
import ArtistForm from './components/ArtistForm';
import SongForm from './components/SongForm';
import ArtistTable from './components/ArtistTable';
import SongTable from './components/SongTable';

function App() {
  const [refreshTables, setRefreshTables] = useState(false);

  const handleRefresh = () => {
    setRefreshTables(prev => !prev);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 to-gray-800 text-gray-100">
      <div className="container mx-auto px-4 py-8">
        <Header />
        
        <div className="grid lg:grid-cols-2 gap-8">
          <div className="space-y-8">
            <ArtistForm onArtistAdded={handleRefresh} />
            <SongForm 
              onSongAdded={handleRefresh}
              onRefreshTables={handleRefresh}
            />
          </div>
          
          <div className="space-y-8">
            <ArtistTable 
              refresh={refreshTables} 
              onArtistDeleted={handleRefresh} 
            />
            <SongTable 
              refresh={refreshTables} 
              onSongDeleted={handleRefresh} 
            />
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;