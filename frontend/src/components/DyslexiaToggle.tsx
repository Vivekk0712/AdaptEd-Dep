import { motion } from 'framer-motion';
import { BookOpen } from 'lucide-react';
import { useDyslexia } from '@/contexts/DyslexiaContext';

export const DyslexiaToggle = () => {
  const { isDyslexiaMode, toggleDyslexiaMode } = useDyslexia();

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      className="fixed bottom-5 right-5 z-50"
      style={{ fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif' }}
    >
      <button
        onClick={toggleDyslexiaMode}
        className="flex items-center gap-3 px-5 py-3 rounded-full shadow-lg transition-all duration-300 hover:scale-105 hover:shadow-xl"
        style={{
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          color: 'white',
        }}
      >
        <BookOpen className="w-5 h-5" />
        <span className="font-semibold text-sm">Dyslexia Mode</span>
        <div
          className={`w-11 h-6 rounded-full transition-all duration-300 relative ${
            isDyslexiaMode ? 'bg-white/50' : 'bg-white/30'
          }`}
        >
          <motion.div
            className="absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow-md"
            animate={{
              x: isDyslexiaMode ? 20 : 0,
            }}
            transition={{ type: 'spring', stiffness: 500, damping: 30 }}
          />
        </div>
      </button>
    </motion.div>
  );
};
