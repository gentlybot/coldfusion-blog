# Gently ColdFusion Blog

A small **blog** built with **ColdFusion (Lucee)** + **MySQL** + **React** — all in one repo.

- Public site: read posts, leave comments (no login needed).
- Admin area: password-protected, publish new posts.
- **Idempotent seeding**: tables are created and sample posts/comments are seeded
  automatically on first boot (and via `GET /api/seed.cfm`), safe to run repeatedly.

## Stack & layout

```
public/            ← Lucee webroot (served by CommandBox)
  index.html       ← built React SPA (committed, so no Node build needed to run)
  assets/          ← built React JS/CSS
  Application.cfc  ← datasource (from env) + seed-on-start
  api/*.cfm        ← JSON API (posts, comments, login, create post)
db/Seeder.cfc      ← idempotent schema + seed
web/               ← React source (Vite); `npm run build` outputs into ../public
server.json        ← CommandBox/Lucee server (Lucee 6, webroot=public, port 8080)
```

The React app and the CFML API are same-origin, so session cookies (admin login) just work.

## Configuration (environment variables)

| Var | Default | Purpose |
|-----|---------|---------|
| `DB_HOST` / `DB_PORT` / `DB_NAME` / `DB_USER` / `DB_PASSWORD` | `127.0.0.1` / `3306` / `blog` / `root` / *(empty)* | MySQL connection |
| `ADMIN_PASSWORD` | `admin123` | Admin login password |

## Run locally

```bash
# 1. a MySQL 8 with a `blog` database
docker run -d --name blog-mysql -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=blog -e MYSQL_DATABASE=blog mysql:8.0

# 2. (optional) rebuild the React app
cd web && npm install && npm run build && cd ..

# 3. start the server (CommandBox)
DB_PASSWORD=blog box server start
# → http://localhost:8080   (admin: password `admin123`)
```

## Develop the front end

```bash
cd web && npm run dev    # Vite dev server, proxies /api to :8080
```
