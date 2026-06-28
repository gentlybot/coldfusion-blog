// Tiny fetch wrapper for the CFML API. Same-origin, so session cookies ride along.
async function req(path, options = {}) {
  const res = await fetch(`/api/${path}`, {
    credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    ...options,
  })
  let data = null
  try { data = await res.json() } catch { /* non-JSON */ }
  if (!res.ok) throw new Error((data && data.error) || `Request failed (${res.status})`)
  return data
}

export const api = {
  listPosts: () => req('posts.cfm'),
  getPost: (id) => req(`posts.cfm?id=${encodeURIComponent(id)}`),
  addComment: (post_id, author, body) =>
    req('comments.cfm', { method: 'POST', body: JSON.stringify({ post_id, author, body }) }),
  me: () => req('me.cfm'),
  login: (password) => req('login.cfm', { method: 'POST', body: JSON.stringify({ password }) }),
  logout: () => req('logout.cfm', { method: 'POST' }),
  createPost: (title, author, body) =>
    req('posts-create.cfm', { method: 'POST', body: JSON.stringify({ title, author, body }) }),
}
