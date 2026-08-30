import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

// Until a user verifies their email, every protected page bounces them to
// /check-email instead of granting access — pass allowUnverified for the
// handful of pages (check-email itself) that an unverified user must reach.
export default function ProtectedRoute({ children, roles, allowUnverified = false }) {
  const { user } = useAuth();
  const location = useLocation();

  if (!user) return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  if (!allowUnverified && !user.emailVerified) {
    return <Navigate to={`/check-email?redirect=${encodeURIComponent(location.pathname)}`} replace />;
  }
  if (roles && !roles.some((r) => user.roles.includes(r))) {
    return <Navigate to="/" replace />;
  }

  return children;
}
