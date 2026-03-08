import React, { createContext, useContext, useState, useEffect } from 'react';

interface DyslexiaContextType {
  isDyslexiaMode: boolean;
  toggleDyslexiaMode: () => void;
  isRulerActive: boolean;
  rulerPosition: number;
  setRulerPosition: (position: number) => void;
}

const DyslexiaContext = createContext<DyslexiaContextType | undefined>(undefined);

export const useDyslexia = () => {
  const context = useContext(DyslexiaContext);
  if (!context) {
    throw new Error('useDyslexia must be used within a DyslexiaProvider');
  }
  return context;
};

export const DyslexiaProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isDyslexiaMode, setIsDyslexiaMode] = useState(false);
  const [isRulerActive, setIsRulerActive] = useState(false);
  const [rulerPosition, setRulerPosition] = useState(0);

  // Load saved state from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('dyslexiaModeActive');
    if (saved === 'true') {
      setIsDyslexiaMode(true);
      setIsRulerActive(true);
    }
  }, []);

  // Apply/remove dyslexia mode class to body
  useEffect(() => {
    if (isDyslexiaMode) {
      document.body.classList.add('dyslexia-active');
    } else {
      document.body.classList.remove('dyslexia-active');
    }
  }, [isDyslexiaMode]);

  const toggleDyslexiaMode = () => {
    const newState = !isDyslexiaMode;
    setIsDyslexiaMode(newState);
    setIsRulerActive(newState);
    localStorage.setItem('dyslexiaModeActive', String(newState));
  };

  return (
    <DyslexiaContext.Provider
      value={{
        isDyslexiaMode,
        toggleDyslexiaMode,
        isRulerActive,
        rulerPosition,
        setRulerPosition,
      }}
    >
      {children}
    </DyslexiaContext.Provider>
  );
};
