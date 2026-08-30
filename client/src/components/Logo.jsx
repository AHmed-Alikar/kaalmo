import { Link } from 'react-router-dom';

export default function Logo({ className = '' }) {
  return (
    <Link to="/" className={`flex items-center gap-sm ${className}`}>
      <img src="/logo.png" alt="Kaalmo" className="h-16 w-auto object-contain" />
      <span className="text-[20px] font-bold text-primary"></span>
    </Link>
  );
}
