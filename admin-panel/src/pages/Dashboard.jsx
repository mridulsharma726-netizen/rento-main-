import { useState, useEffect } from 'react';
import api from '../api';
import { Users, ShoppingBag, CreditCard, AlertTriangle } from 'lucide-react';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalBookings: 0,
    totalPayments: 0,
    openDisputes: 0
  });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await api.get('/stats');
        setStats({
          totalUsers: res.data.data.totalUsers,
          totalBookings: res.data.data.totalBookings,
          totalPayments: res.data.data.totalPayments,
          openDisputes: res.data.data.openDisputes
        });
      } catch (err) {
        console.error(err);
      }
    };
    fetchStats();
  }, []);

  const statCards = [
    { name: 'Total Users', value: stats.totalUsers, icon: Users, color: '#3b82f6' },
    { name: 'Total Bookings', value: stats.totalBookings, icon: ShoppingBag, color: '#f43f5e' },
    { name: 'Payment Records', value: stats.totalPayments, icon: CreditCard, color: '#10b981' },
    { name: 'Open Disputes', value: stats.openDisputes, icon: AlertTriangle, color: '#f59e0b' },
  ];

  return (
    <div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '24px', marginBottom: '32px' }}>
        {statCards.map((card) => (
          <div key={card.name} className="glass-card" style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
            <div style={{ 
              width: '48px', 
              height: '48px', 
              borderRadius: '12px', 
              background: `${card.color}20`, 
              display: 'flex', 
              alignItems: 'center', 
              justifyContent: 'center',
              color: card.color
            }}>
              <card.icon size={24} />
            </div>
            <div>
              <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>{card.name}</div>
              <div style={{ fontSize: '1.5rem', fontWeight: '700' }}>{card.value}</div>
            </div>
          </div>
        ))}
      </div>

      <div className="glass-card">
        <h3>Platform Activity</h3>
        <div style={{ height: '300px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)' }}>
          [Activity Chart Mockup]
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
