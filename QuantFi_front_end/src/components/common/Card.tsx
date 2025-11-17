import type { ReactNode } from 'react';

interface CardProps {
  children: ReactNode;
  className?: string;
  title?: string;
}

export const Card = ({ children, className = '', title }: CardProps) => {
  return (
    <div
      className={`bg-dark-card/40 backdrop-blur-sm border border-dark-border/50 rounded-xl p-5 shadow-card hover:border-dark-border transition-all ${className}`}
    >
      {title && (
        <h3 className="text-base font-semibold text-gray-100 mb-4 pb-3 border-b border-dark-border/30">{title}</h3>
      )}
      {children}
    </div>
  );
};
