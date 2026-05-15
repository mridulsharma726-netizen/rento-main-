import { useEffect, useState } from 'react';
import api from '../api';

const DisputesPage = () => {
  const [disputes, setDisputes] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchDisputes = async () => {
    try {
      const res = await api.get('/disputes');
      setDisputes(res.data.data.disputes);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      void fetchDisputes();
    }, 0);
    return () => clearTimeout(timer);
  }, []);

  const resolveDispute = async (id, status, winnerId) => {
    try {
      await api.put(`/disputes/${id}/resolve`, { status, winner_id: winnerId, notes: 'Resolved by admin' });
      fetchDisputes();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="glass-card">
      <div style={{ marginBottom: '24px' }}>
        <h2>Dispute Resolution</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Review conflicts and decide on fund allocation.</p>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Reporter</th>
              <th>Reason</th>
              <th>Booking</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  Loading disputes...
                </td>
              </tr>
            )}
            {disputes.map(d => (
              <tr key={d.id}>
                <td>{d.reporter_id?.name}</td>
                <td>{d.reason}</td>
                <td>{d.booking_id?._id?.slice(-6).toUpperCase()}</td>
                <td>
                  <span className={`badge ${d.status === 'open' ? 'badge-error' : 'badge-success'}`}>
                    {d.status}
                  </span>
                </td>
                <td>
                  {d.status === 'open' && (
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button 
                        onClick={() => resolveDispute(d.id, 'resolved', d.booking_id?.owner_id)}
                        className="btn-primary" 
                        style={{ padding: '4px 8px', fontSize: '0.7rem' }}
                      >
                        Owner Wins
                      </button>
                      <button 
                        onClick={() => resolveDispute(d.id, 'resolved', d.booking_id?.renter_id)}
                        className="btn-primary" 
                        style={{ padding: '4px 8px', fontSize: '0.7rem', background: 'var(--bg-secondary)', border: '1px solid var(--border-color)' }}
                      >
                        Renter Wins
                      </button>
                    </div>
                  )}
                </td>
              </tr>
            ))}
            {!loading && disputes.length === 0 && (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  No active disputes.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default DisputesPage;
