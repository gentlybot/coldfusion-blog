/**
 * Idempotent schema + seed for the blog.
 *  - migrate(): creates tables IF NOT EXISTS, then seeds sample data only when empty.
 * Safe to run repeatedly (on every app start, or via /api/seed.cfm).
 */
component {

	variables.ds = { datasource: "blog" };

	public void function migrate() {
		queryExecute("
			CREATE TABLE IF NOT EXISTS posts (
				id INT AUTO_INCREMENT PRIMARY KEY,
				title VARCHAR(255) NOT NULL,
				slug VARCHAR(255) NOT NULL,
				author VARCHAR(120) NOT NULL DEFAULT 'Admin',
				body MEDIUMTEXT NOT NULL,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
			) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
		", {}, variables.ds);

		queryExecute("
			CREATE TABLE IF NOT EXISTS comments (
				id INT AUTO_INCREMENT PRIMARY KEY,
				post_id INT NOT NULL,
				author VARCHAR(120) NOT NULL,
				body TEXT NOT NULL,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				INDEX idx_comments_post (post_id)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
		", {}, variables.ds);

		seed();
	}

	public struct function seed() {
		var existing = queryExecute("SELECT COUNT(*) AS c FROM posts", {}, variables.ds);
		if ( existing.c GT 0 ) {
			return { seeded: false, reason: "posts already present (#existing.c#)" };
		}

		var posts = [
			{
				title: "Welcome to the Gently Blog",
				author: "Ada Lovelace",
				body: "This little blog is built with ColdFusion (Lucee) on the server, MySQL for storage, and a React single-page app on the front end — all in one repo, running inside a Gently sandbox.

Browse the posts, leave a comment, or head to the Admin area to publish a new post."
			},
			{
				title: "Why ColdFusion still gets the job done",
				author: "Grace Hopper",
				body: "CFML is a remarkably productive language for data-backed web apps. A few lines of `queryExecute` and you have a typed, parameterized query talking to MySQL. No ORM ceremony required.

Pair it with a modern React front end and you get the best of both worlds: a fast, pleasant UI and a tiny, readable backend."
			},
			{
				title: "Leaving comments",
				author: "Linus T.",
				body: "Every post on this blog accepts comments from anyone — no login required. Try it out below!

The Admin area (password-protected) is where new posts get written. Everything you see was created by the idempotent seeder the first time the app booted."
			}
		];

		for ( var p in posts ) {
			queryExecute(
				"INSERT INTO posts (title, slug, author, body) VALUES (:t, :s, :a, :b)",
				{ t: p.title, s: slugify(p.title), a: p.author, b: p.body },
				variables.ds
			);
		}

		var first = queryExecute("SELECT id FROM posts ORDER BY id ASC LIMIT 1", {}, variables.ds);
		var seedComments = [
			{ author: "Margaret", body: "Love seeing CFML and React together. Clean!" },
			{ author: "Dennis", body: "The comment box works great. Nice demo." }
		];
		for ( var c in seedComments ) {
			queryExecute(
				"INSERT INTO comments (post_id, author, body) VALUES (:p, :a, :b)",
				{ p: first.id, a: c.author, b: c.body },
				variables.ds
			);
		}

		return { seeded: true, posts: arrayLen(posts) };
	}

	public string function slugify(required string text) {
		var s = lCase( trim(arguments.text) );
		s = reReplace(s, "[^a-z0-9]+", "-", "all");
		s = reReplace(s, "(^-+|-+$)", "", "all");
		return len(s) ? s : "post";
	}
}
