<cfinclude template="_util.cfm">
<cfscript>
	// POST /api/posts-create.cfm  body: { title, author, body }  → publishes a post (admin only)
	requireAdmin();

	b = readBody();
	title  = trim( b.title ?: "" );
	author = trim( b.author ?: "" );
	body   = trim( b.body ?: "" );

	if ( !len(title) ) respond({ "error": "Title is required" }, 400);
	if ( !len(body) )  respond({ "error": "Body is required" }, 400);
	if ( !len(author) ) author = "Admin";

	seeder = new db.Seeder();
	queryExecute(
		"INSERT INTO posts (title, slug, author, body) VALUES (:t, :s, :a, :b)",
		{ t: left(title, 255), s: seeder.slugify(title), a: left(author, 120), b: body },
		variables.DS
	);

	created = queryExecute("
		SELECT id, title, slug, author, DATE_FORMAT(created_at, '%b %e, %Y') AS created_at
		FROM posts ORDER BY id DESC LIMIT 1
	", {}, variables.DS);

	respond({ "ok": true, "post": rows(created)[1] });
</cfscript>
