<cfinclude template="_util.cfm">
<cfscript>
	// POST /api/comments.cfm  body: { post_id, author, body }  → adds a comment (no login required)
	b = readBody();
	postId = val( b.post_id ?: 0 );
	author = trim( b.author ?: "" );
	body   = trim( b.body ?: "" );

	if ( !postId )       respond({ "error": "post_id is required" }, 400);
	if ( !len(author) )  respond({ "error": "Please enter your name" }, 400);
	if ( !len(body) )    respond({ "error": "Comment cannot be empty" }, 400);

	exists = queryExecute("SELECT id FROM posts WHERE id = :id", { id: postId }, variables.DS);
	if ( !exists.recordCount ) respond({ "error": "Post not found" }, 404);

	queryExecute(
		"INSERT INTO comments (post_id, author, body) VALUES (:p, :a, :b)",
		{ p: postId, a: left(author, 120), b: body },
		variables.DS
	);

	comments = queryExecute("
		SELECT id, author, body, DATE_FORMAT(created_at, '%b %e, %Y at %l:%i %p') AS created_at
		FROM comments WHERE post_id = :id ORDER BY created_at ASC
	", { id: postId }, variables.DS);

	respond({ "ok": true, "comments": rows(comments) });
</cfscript>
