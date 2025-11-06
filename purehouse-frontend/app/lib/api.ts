// Runtime helper to resolve the API base URL for client-side code.
// Prefer NEXT_PUBLIC_API_URL (inlined at build time). If that's empty,
// fall back to the browser origin + "/api" so client requests go to
// the same origin under /api. This helps local k8s/testing where an
// ingress or proxy routes /api to the backend, or when you want to
// avoid rebuilding the frontend for different backends during development.
export function getApiBase(): string {
  const env = typeof process !== 'undefined' ? process.env.NEXT_PUBLIC_API_URL : undefined;
  if (env && env.trim() !== '') return env;

  if (typeof window !== 'undefined' && window.location) {
    // Ensure no trailing slash
    return `${window.location.origin}/api`;
  }

  // Last resort: empty string. Callsites should handle this case.
  return '';
}

export function joinApi(path: string): string {
  const base = getApiBase();
  if (!base) return path.startsWith('/') ? path : `/${path}`;
  // avoid double slashes
  return base.replace(/\/$/, '') + (path.startsWith('/') ? path : `/${path}`);
}
