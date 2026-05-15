import { useEffect, useState } from 'react';
import api, { publicApi } from '../api';
import { Landmark } from 'lucide-react';

const PaymentsPage = () => {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchPayments = async () => {
    try {
      const res = await api.get('/payments');
      setPayments(res.data.data.payments);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      void fetchPayments();
    }, 0);
    return () => clearTimeout(timer);
  }, []);

  const handleRelease = async (bookingId) => {
    try {
      await publicApi.post(`/payments/release/${bookingId}`);
      fetchPayments();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="glass-card">
      <div style={{ marginBottom: '24px' }}>
        <h2>Payment & Escrow</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Manage payouts to owners and security deposits.</p>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Booking</th>
              <th>Total</th>
              <th>Commission</th>
              <th>Deposit</th>
              <th>Payment Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  Loading payments...
                </td>
              </tr>
            )}
            {payments.map(p => (
              <tr key={p.id}>
                <td>{p.booking_id?._id?.slice(-6).toUpperCase() || 'N/A'}</td>
                <td>₹{p.amount}</td>
                <td style={{ color: 'var(--accent-primary)' }}>₹{p.booking_id?.commissionAmount || 0}</td>
                <td>₹{p.booking_id?.depositAmount || 0}</td>
                <td>
                  <span className={`badge ${p.booking_id?.paymentStatus === 'released' ? 'badge-success' : 'badge-warning'}`}>
                    {p.booking_id?.paymentStatus}
                  </span>
                </td>
                <td>
                  {p.booking_id?.paymentStatus === 'paid' && p.booking_id?.status === 'completed' && (
                    <button 
                      onClick={() => handleRelease(p.booking_id?._id)}
                      className="btn-primary" 
                      style={{ padding: '6px 12px', fontSize: '0.75rem', display: 'flex', alignItems: 'center', gap: '6px' }}
                    >
                      <Landmark size={14} /> Release Payout
                    </button>
                  )}
                </td>
              </tr>
            ))}
            {!loading && payments.length === 0 && (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  No payments found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default PaymentsPage;
