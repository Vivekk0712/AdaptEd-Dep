import { useEffect } from 'react';
import { useDyslexia } from '@/contexts/DyslexiaContext';

export const ReadingRuler = () => {
  const { isRulerActive, rulerPosition, setRulerPosition } = useDyslexia();

  useEffect(() => {
    if (!isRulerActive) return;

    const handleMouseMove = (e: MouseEvent) => {
      setRulerPosition(e.clientY);
    };

    document.addEventListener('mousemove', handleMouseMove);

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
    };
  }, [isRulerActive, setRulerPosition]);

  if (!isRulerActive) return null;

  return (
    <div
      className="fixed left-0 w-full h-10 pointer-events-none z-40 transition-all duration-75 ease-linear"
      style={{
        top: `${rulerPosition - 20}px`,
        backgroundColor: 'rgba(255, 255, 0, 0.3)',
      }}
    />
  );
};
