import { useState } from 'react';
import { BrowserRouter as Router, Link, Route, Routes, useLocation } from 'react-router-dom';
import {
  AlertTriangle,
  CreditCard,
  LayoutDashboard,
  LogOut,
  ShieldCheck,
  ShoppingBag,
  Users,
} from 'lucide-react';

import Dashboard from './pages/Dashboard';
import UsersPage from './pages/Users';
import KYCPage from './pages/KYC';
import BookingsPage from './pages/Bookings';
import PaymentsPage from './pages/Payments';
import DisputesPage from './pages/Disputes';
import { publicApi } from './api';

const parseStoredAdmin = () => {
  try {
    const raw = localStorage.getItem('adminUser');
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
};

const Login = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleLogin = async () => {
    setSubmitting(true);
    setError('');

    try {
      const res = await publicApi.post('/auth/login', { email, password });
      const { token, user } = res.data;

      if (user.role !== 'admin') {
        setError('Access denied. Admin only.');
        setSubmitting(false);
        return;
      }

      localStorage.setItem('adminToken', token);
      localStorage.setItem('adminUser', JSON.stringify(user));
      onLogin(user);
    } catch {
      setError('Invalid credentials');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div
      style={{
        display: 'flex',
        height: '100vh',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'var(--bg-primary)',
      }}
    >
      <div className="glass-card" style={{ width: '400px' }}>
        <h2 style={{ marginBottom: '24px', textAlign: 'center' }}>Rento Admin</h2>
        {error && (
          <div
            className="badge badge-error"
            style={{ width: '100%', marginBottom: '16px', textAlign: 'center' }}
          >
            {error}
          </div>
        )}
        <input
          type="email"
          placeholder="Email"
          className="glass-card"
          style={{ width: '100%', marginBottom: '16px', padding: '12px' }}
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          className="glass-card"
          style={{ width: '100%', marginBottom: '24px', padding: '12px' }}
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              handleLogin();
            }
          }}
        />
        <button
          className="btn-primary"
          style={{ width: '100%' }}
          onClick={handleLogin}
          disabled={submitting}
        >
          {submitting ? 'Signing In...' : 'Login Control Panel'}
        </button>
      </div>
    </div>
  );
};

const Sidebar = ({ adminUser, onLogout }) => {
  const location = useLocation();
  const menuItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Users', path: '/users', icon: Users },
    { name: 'KYC', path: '/kyc', icon: ShieldCheck },
    { name: 'Bookings', path: '/bookings', icon: ShoppingBag },
    { name: 'Payments', path: '/payments', icon: CreditCard },
    { name: 'Disputes', path: '/disputes', icon: AlertTriangle },
  ];

  return (
    <div
      className="sidebar"
      style={{
        width: '260px',
        height: '100vh',
        position: 'fixed',
        left: 0,
        top: 0,
        background: 'var(--bg-secondary)',
        borderRight: '1px solid var(--border-color)',
        padding: '24px 16px',
        zIndex: 1000,
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          marginBottom: '40px',
          paddingLeft: '8px',
        }}
      >
        <div
          style={{
            width: '32px',
            height: '32px',
            background: 'var(--accent-primary)',
            borderRadius: '8px',
          }}
        />
        <span style={{ fontSize: '1.25rem', fontWeight: '700', letterSpacing: '-0.025em' }}>
          RENTO ADMIN
        </span>
      </div>

      <nav style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
        {menuItems.map((item) => (
          <Link
            key={item.name}
            to={item.path}
            className={`sidebar-item ${location.pathname === item.path ? 'active' : ''}`}
          >
            <item.icon size={20} />
            {item.name}
          </Link>
        ))}
      </nav>

      <div style={{ position: 'absolute', bottom: '24px', left: '16px', right: '16px' }}>
        <div
          style={{
            padding: '12px',
            border: '1px solid var(--border-color)',
            borderRadius: '12px',
            marginBottom: '12px',
          }}
        >
          <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Signed in as</div>
          <div style={{ fontWeight: '600' }}>{adminUser?.name || 'Admin User'}</div>
          <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
            {adminUser?.email || 'admin@rento.app'}
          </div>
        </div>
        <button
          className="sidebar-item"
          style={{ width: '100%', background: 'transparent', border: 'none', cursor: 'pointer' }}
          onClick={onLogout}
        >
          <LogOut size={20} />
          Logout
        </button>
      </div>
    </div>
  );
};

function App() {
  const [adminUser, setAdminUser] = useState(parseStoredAdmin);
  const [isAuthenticated, setIsAuthenticated] = useState(
    Boolean(localStorage.getItem('adminToken') && parseStoredAdmin()),
  );

  const handleLogin = (user) => {
    setAdminUser(user);
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
    setAdminUser(null);
    setIsAuthenticated(false);
  };

  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  return (
    <Router>
      <div style={{ display: 'flex' }}>
        <Sidebar adminUser={adminUser} onLogout={handleLogout} />
        <main
          style={{
            flex: 1,
            marginLeft: '260px',
            padding: '40px',
            minHeight: '100vh',
          }}
        >
          <header
            style={{
              marginBottom: '32px',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
            }}
          >
            <h2 style={{ fontSize: '1.5rem', fontWeight: '600' }}>Platform Overview</h2>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '0.875rem', fontWeight: '600' }}>
                  {adminUser?.name || 'Admin User'}
                </div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                  {adminUser?.role || 'admin'}
                </div>
              </div>
              <div
                style={{
                  width: '40px',
                  height: '40px',
                  borderRadius: '50%',
                  background: 'var(--bg-secondary)',
                  border: '1px solid var(--border-color)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontWeight: '700',
                }}
              >
                {(adminUser?.name || 'A').charAt(0).toUpperCase()}
              </div>
            </div>
          </header>

          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/users" element={<UsersPage />} />
            <Route path="/kyc" element={<KYCPage />} />
            <Route path="/bookings" element={<BookingsPage />} />
            <Route path="/payments" element={<PaymentsPage />} />
            <Route path="/disputes" element={<DisputesPage />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
