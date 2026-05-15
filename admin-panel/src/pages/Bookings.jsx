import { useEffect, useState } from 'react';
import api from '../api';

const badgeClassForStatus = (status) => {
  switch (status) {
    case 'completed':
      return 'badge-success';
    case 'cancelled':
    case 'rejected':
      return 'badge-error';
    case 'active':
    case 'paid':
      return 'badge-success';
    case 'requested':
    case 'approved':
    case 'return_pending':
    case 'expired':
    default:
      return 'badge-warning';
  }
};

const BookingsPage = () => {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchBookings = async () => {
    try {
      const res = await api.get('/bookings');
      setBookings(res.data.data.bookings);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      void fetchBookings();
    }, 0);
    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="glass-card">
      <div style={{ marginBottom: '24px' }}>
        <h2>Booking Management</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Track all rental transactions on the platform.</p>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Product</th>
              <th>Renter</th>
              <th>Owner</th>
              <th>Amount</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  Loading bookings...
                </td>
              </tr>
            )}
            {bookings.map(b => (
              <tr key={b.id}>
                <td style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{b.id.slice(-6).toUpperCase()}</td>
                <td>{b.product_title}</td>
                <td>{b.renter_id?.name || 'User'}</td>
                <td>{b.owner_id?.name || 'Owner'}</td>
                <td>₹{b.total_amount}</td>
                <td>
                  <span className={`badge ${badgeClassForStatus(b.status)}`}>
                    {b.status}
                  </span>
                </td>
              </tr>
            ))}
            {!loading && bookings.length === 0 && (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  No bookings found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default BookingsPage;
