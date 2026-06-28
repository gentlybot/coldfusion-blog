<cfinclude template="_util.cfm">
<cfscript>
	// POST /api/login.cfm  body: { password }  → starts an admin session
	b = readBody();
	if ( ( b.password ?: "" ) == application.adminPassword ) {
		session.isAdmin = true;
		respond({ "ok": true, "isAdmin": true });
	}
	respond({ "ok": false, "error": "Incorrect password" }, 401);
</cfscript>
