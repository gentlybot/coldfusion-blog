<cfinclude template="_util.cfm">
<cfscript>
	// GET/POST /api/seed.cfm → run the idempotent migrate + seed on demand.
	// Creates tables if missing and seeds sample data only when the blog is empty.
	result = new db.Seeder();
	result.migrate();
	respond({ ok: true, result: result.seed() });
</cfscript>
