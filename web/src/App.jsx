import React, { useEffect, useState, useCallback } from 'react'
import { api } from './api.js'

export default function App() {
  const [route, setRoute] = useState({ name: 'home' })
  const [isAdmin, setIsAdmin] = useState(false)

  useEffect(() => {
    api.me().then((r) => setIsAdmin(!!r.isAdmin)).catch(() => {})
  }, [])

  const go = useCallback((name, params = {}) => {
    window.scrollTo(0, 0)
    setRoute({ name, ...params })
  }, [])

  return (
    <div className="app">
      <header className="topbar">
        <div className="wrap topbar-inner">
          <a className="brand" onClick={() => go('home')}>
            <span className="brand-mark">✶</span> Gently Blog
          </a>
          <nav>
            <a onClick={() => go('home')}>Posts</a>
            <a onClick={() => go('admin')}>{isAdmin ? 'Admin ✓' : 'Admin'}</a>
          </nav>
        </div>
      </header>

      <main className="wrap">
        {route.name === 'home' && <Home go={go} />}
        {route.name === 'post' && <Post id={route.id} go={go} />}
        {route.name === 'admin' && <Admin isAdmin={isAdmin} setIsAdmin={setIsAdmin} go={go} />}
      </main>

      <footer className="wrap footer">
        ColdFusion (Lucee) · MySQL · React — running in a Gently sandbox
      </footer>
    </div>
  )
}

function Home({ go }) {
  const [posts, setPosts] = useState(null)
  const [err, setErr] = useState('')

  useEffect(() => {
    api.listPosts().then((r) => setPosts(r.posts)).catch((e) => setErr(e.message))
  }, [])

  if (err) return <Error msg={err} />
  if (!posts) return <Loading />

  return (
    <>
      <h1 className="page-title">Latest posts</h1>
      {posts.length === 0 && <p className="muted">No posts yet.</p>}
      <div className="post-list">
        {posts.map((p) => (
          <article key={p.id} className="card post-card" onClick={() => go('post', { id: p.id })}>
            <h2>{p.title}</h2>
            <div className="meta">
              by {p.author} · {p.created_at} · {p.comment_count} comment{p.comment_count == 1 ? '' : 's'}
            </div>
            <p className="excerpt">{p.excerpt}…</p>
            <span className="read-more">Read more →</span>
          </article>
        ))}
      </div>
    </>
  )
}

function Post({ id, go }) {
  const [data, setData] = useState(null)
  const [err, setErr] = useState('')

  const load = useCallback(() => {
    api.getPost(id).then(setData).catch((e) => setErr(e.message))
  }, [id])

  useEffect(() => { load() }, [load])

  if (err) return <Error msg={err} />
  if (!data) return <Loading />

  const { post, comments } = data
  return (
    <article className="single">
      <a className="back" onClick={() => go('home')}>← All posts</a>
      <h1 className="page-title">{post.title}</h1>
      <div className="meta">by {post.author} · {post.created_at}</div>
      <div className="body">{post.body.split('\n\n').map((para, i) => <p key={i}>{para}</p>)}</div>

      <section className="comments">
        <h3>{comments.length} comment{comments.length == 1 ? '' : 's'}</h3>
        {comments.map((c) => (
          <div key={c.id} className="card comment">
            <div className="comment-head"><strong>{c.author}</strong> <span className="muted">· {c.created_at}</span></div>
            <p>{c.body}</p>
          </div>
        ))}
        <CommentForm postId={post.id} onAdded={(cs) => setData({ post, comments: cs })} />
      </section>
    </article>
  )
}

function CommentForm({ postId, onAdded }) {
  const [author, setAuthor] = useState('')
  const [body, setBody] = useState('')
  const [busy, setBusy] = useState(false)
  const [err, setErr] = useState('')

  async function submit(e) {
    e.preventDefault()
    setBusy(true); setErr('')
    try {
      const r = await api.addComment(postId, author, body)
      setBody('')
      onAdded(r.comments)
    } catch (e) { setErr(e.message) } finally { setBusy(false) }
  }

  return (
    <form className="card form" onSubmit={submit}>
      <h4>Leave a comment</h4>
      {err && <div className="alert">{err}</div>}
      <input placeholder="Your name" value={author} onChange={(e) => setAuthor(e.target.value)} />
      <textarea placeholder="Say something nice…" rows={3} value={body} onChange={(e) => setBody(e.target.value)} />
      <button disabled={busy}>{busy ? 'Posting…' : 'Post comment'}</button>
    </form>
  )
}

function Admin({ isAdmin, setIsAdmin, go }) {
  const [password, setPassword] = useState('')
  const [err, setErr] = useState('')
  const [busy, setBusy] = useState(false)

  async function login(e) {
    e.preventDefault()
    setBusy(true); setErr('')
    try { await api.login(password); setIsAdmin(true) }
    catch (e) { setErr(e.message) } finally { setBusy(false) }
  }
  async function logout() { await api.logout().catch(() => {}); setIsAdmin(false) }

  if (!isAdmin) {
    return (
      <div className="narrow">
        <h1 className="page-title">Admin login</h1>
        <form className="card form" onSubmit={login}>
          {err && <div className="alert">{err}</div>}
          <input type="password" placeholder="Admin password" value={password} onChange={(e) => setPassword(e.target.value)} />
          <button disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
          <p className="hint">Demo password: <code>admin123</code> (set via <code>ADMIN_PASSWORD</code>)</p>
        </form>
      </div>
    )
  }

  return (
    <div className="narrow">
      <div className="admin-head">
        <h1 className="page-title">New post</h1>
        <button className="link-btn" onClick={logout}>Sign out</button>
      </div>
      <NewPost go={go} />
    </div>
  )
}

function NewPost({ go }) {
  const [title, setTitle] = useState('')
  const [author, setAuthor] = useState('')
  const [body, setBody] = useState('')
  const [busy, setBusy] = useState(false)
  const [err, setErr] = useState('')

  async function submit(e) {
    e.preventDefault()
    setBusy(true); setErr('')
    try {
      const r = await api.createPost(title, author, body)
      go('post', { id: r.post.id })
    } catch (e) { setErr(e.message) } finally { setBusy(false) }
  }

  return (
    <form className="card form" onSubmit={submit}>
      {err && <div className="alert">{err}</div>}
      <input placeholder="Post title" value={title} onChange={(e) => setTitle(e.target.value)} />
      <input placeholder="Author (optional)" value={author} onChange={(e) => setAuthor(e.target.value)} />
      <textarea placeholder="Write your post… (blank lines separate paragraphs)" rows={10} value={body} onChange={(e) => setBody(e.target.value)} />
      <button disabled={busy}>{busy ? 'Publishing…' : 'Publish post'}</button>
    </form>
  )
}

const Loading = () => <div className="muted pad">Loading…</div>
const Error = ({ msg }) => <div className="alert pad">Couldn’t load: {msg}</div>
