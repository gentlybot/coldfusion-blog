<cfinclude template="_util.cfm">
<cfscript>
	// GET /api/posts.cfm            → list posts
	// GET /api/posts.cfm?id=123     → single post + its comments
	if ( structKeyExists(url, "id") && isNumeric(url.id) ) {
		post = queryExecute("
			SELECT id, title, slug, author, body,
			       DATE_FORMAT(created_at, '%b %e, %Y') AS created_at
			FROM posts WHERE id = :id
		", { id: url.id }, variables.DS);

		if ( !post.recordCount ) respond({ "error": "Post not found" }, 404);

		comments = queryExecute("
			SELECT id, author, body, DATE_FORMAT(created_at, '%b %e, %Y at %l:%i %p') AS created_at
			FROM comments WHERE post_id = :id ORDER BY created_at ASC
		", { id: url.id }, variables.DS);

		respond({ "post": rows(post)[1], "comments": rows(comments) });
	}

	posts = queryExecute("
		SELECT p.id, p.title, p.slug, p.author,
		       DATE_FORMAT(p.created_at, '%b %e, %Y') AS created_at,
		       LEFT(p.body, 220) AS excerpt,
		       (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) AS comment_count
		FROM posts p ORDER BY p.created_at DESC, p.id DESC
	", {}, variables.DS);

	respond({ "posts": rows(posts) });
</cfscript>
