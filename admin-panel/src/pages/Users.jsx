import { useEffect, useState } from 'react';
import api from '../api';
import { Shield, ShieldOff, Search } from 'lucide-react';

const UsersPage = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    const timer = setTimeout(async () => {
      try {
        const res = await api.get(`/users?search=${search}`);
        setUsers(res.data.data.users);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }, 300);
    return () => clearTimeout(timer);
  }, [search]);

  const fetchUsers = async (searchTerm = search) => {
    try {
      const res = await api.get(`/users?search=${searchTerm}`);
      setUsers(res.data.data.users);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleBan = async (id, currentStatus) => {
    try {
      await api.put(`/users/${id}/ban`, { ban: !currentStatus });
      fetchUsers();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="glass-card">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <h2>User Management</h2>
        <div style={{ position: 'relative' }}>
          <Search size={18} style={{ position: 'absolute', left: '12px', top: '10px', color: 'var(--text-secondary)' }} />
          <input 
            type="text" 
            placeholder="Search name or email..." 
            className="glass-card" 
            style={{ padding: '8px 16px 8px 40px', fontSize: '0.875rem' }}
            value={search}
            onChange={(e) => {
              setLoading(true);
              setSearch(e.target.value);
            }}
          />
        </div>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Status</th>
              <th>KYC</th>
              <th>Trust Score</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  Loading users...
                </td>
              </tr>
            )}
            {users.map(user => (
              <tr key={user.id}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <div style={{ width: '32px', height: '32px', borderRadius: '50%', background: 'var(--bg-secondary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      {(user.name || user.email || 'U').charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <div style={{ fontWeight: '500' }}>{user.name || 'Unnamed User'}</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{user.email}</div>
                    </div>
                  </div>
                </td>
                <td>
                  <span className={`badge ${user.is_banned ? 'badge-error' : 'badge-success'}`}>
                    {user.is_banned ? 'Banned' : 'Active'}
                  </span>
                </td>
                <td>
                  <span className={`badge ${
                    user.kyc_status === 'verified'
                      ? 'badge-success'
                      : user.kyc_status === 'rejected'
                        ? 'badge-error'
                        : 'badge-warning'
                  }`}>
                    {user.kyc_status || 'not_submitted'}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <div style={{ width: '60px', height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px' }}>
                      <div style={{ width: `${user.trust_score}%`, height: '100%', background: 'var(--accent-primary)', borderRadius: '3px' }}></div>
                    </div>
                    <span style={{ fontSize: '0.75rem' }}>{user.trust_score}%</span>
                  </div>
                </td>
                <td>
                  <button 
                    onClick={() => handleBan(user.id, user.is_banned)}
                    style={{ background: 'transparent', border: 'none', color: user.is_banned ? '#4ade80' : '#f87171', cursor: 'pointer' }}
                  >
                    {user.is_banned ? <Shield size={18} /> : <ShieldOff size={18} />}
                  </button>
                </td>
              </tr>
            ))}
            {!loading && users.length === 0 && (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  No users found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default UsersPage;
