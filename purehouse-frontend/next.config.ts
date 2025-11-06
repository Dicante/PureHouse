import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Proxy /api requests to backend during local development
  // In production (K8s), Ingress will handle this routing
  async rewrites() {
    // Only apply rewrites if NEXT_PUBLIC_API_URL is not set
    if (process.env.NEXT_PUBLIC_API_URL) {
      return [];
    }
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:3001/api/:path*',
      },
    ];
  },
};

export default nextConfig;
