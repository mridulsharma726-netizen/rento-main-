import axios from 'axios';

const rawBaseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api';

export const PUBLIC_API_BASE = rawBaseUrl.replace(/\/$/, '');
export const APP_BASE_URL = PUBLIC_API_BASE.replace(/\/api$/, '');

const defaultHeaders = {
  'Content-Type': 'application/json',
};

const attachAuthToken = (config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
};

const api = axios.create({
  baseURL: `${PUBLIC_API_BASE}/admin`,
  headers: defaultHeaders,
});

export const publicApi = axios.create({
  baseURL: PUBLIC_API_BASE,
  headers: defaultHeaders,
});

api.interceptors.request.use(attachAuthToken);
publicApi.interceptors.request.use(attachAuthToken);

export default api;
