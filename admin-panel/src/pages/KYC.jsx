import { useEffect, useState } from 'react';
import api, { APP_BASE_URL } from '../api';
import { Check, X, ExternalLink } from 'lucide-react';

const KYCPage = () => {
  const [docs, setDocs] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchKYC = async () => {
    try {
      const res = await api.get('/kyc?status=pending');
      setDocs(res.data.data.documents);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      void fetchKYC();
    }, 0);
    return () => clearTimeout(timer);
  }, []);

  const handleVerify = async (id, status) => {
    let notes;
    if (status === 'rejected') {
      notes = window.prompt('Enter a reason for rejecting this KYC request:');
      if (notes === null) {
        return;
      }
      if (!notes.trim()) {
        window.alert('A rejection reason is required.');
        return;
      }
    }

    try {
      await api.patch(`/kyc/${id}/verify`, {
        status,
        notes: notes?.trim(),
      });
      fetchKYC();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="glass-card">
      <div style={{ marginBottom: '24px' }}>
        <h2>KYC Verification Requests</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Review and approve user identification documents.</p>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Document Type</th>
              <th>Document Number</th>
              <th>View Proof</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  Loading KYC requests...
                </td>
              </tr>
            )}
            {docs.map(doc => (
              <tr key={doc.id}>
                <td>
                    <div style={{ fontWeight: '500' }}>{doc.user_id?.name || 'User'}</div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{doc.user_id?.email}</div>
                </td>
                <td>{doc.id_type}</td>
                <td>{doc.id_number}</td>
                <td>
                  <a 
                    href={`${APP_BASE_URL}${doc.image_url}`} 
                    target="_blank" 
                    rel="noreferrer"
                    style={{ color: 'var(--accent-primary)', display: 'flex', alignItems: 'center', gap: '4px', textDecoration: 'none', fontSize: '0.875rem' }}
                  >
                    View Image <ExternalLink size={14} />
                  </a>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '12px' }}>
                    <button 
                      onClick={() => handleVerify(doc.id, 'verified')}
                      style={{ background: 'rgba(34, 197, 94, 0.1)', border: 'none', color: '#4ade80', padding: '6px', borderRadius: '6px', cursor: 'pointer' }}
                    >
                      <Check size={18} />
                    </button>
                    <button 
                      onClick={() => handleVerify(doc.id, 'rejected')}
                      style={{ background: 'rgba(239, 68, 68, 0.1)', border: 'none', color: '#f87171', padding: '6px', borderRadius: '6px', cursor: 'pointer' }}
                    >
                      <X size={18} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
            {!loading && docs.length === 0 && (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  No pending KYC requests.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default KYCPage;
