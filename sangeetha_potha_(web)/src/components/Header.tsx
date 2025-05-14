import React from 'react';
import { Music } from 'lucide-react';

const Header: React.FC = () => {
  return (
    <div className="flex items-center mb-8 bg-black/30 p-6 rounded-lg backdrop-blur-sm">
      <Music size={40} className="text-accent mr-4" />
      <div>
        <h1 className="text-4xl font-bold text-white">Sangeetha Potha</h1>
        <p className="text-gray-400 mt-1">Manage Sangeetha Potha app</p>
      </div>
    </div>
  );
};

export default Header;