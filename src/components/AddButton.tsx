import React from 'react';

interface Props {
  onClick: () => void;
}

const AddButton: React.FC<Props> = ({ onClick }) => {
  return (
    <button
      onClick={onClick}
      className="fixed bottom-4 right-4 w-14 h-14 rounded-full bg-blue-500 
        hover:bg-blue-600 text-white text-3xl flex items-center justify-center 
        shadow-lg transition-all duration-200 hover:scale-105 
        focus:outline-none focus:ring-4 focus:ring-blue-300 focus:ring-opacity-50"
    >
      +
    </button>
  );
};

export default AddButton;
