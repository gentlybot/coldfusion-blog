<cfinclude template="_util.cfm">
<cfscript>
	// POST /api/logout.cfm → ends the admin session
	session.isAdmin = false;
	respond({ "ok": true, "isAdmin": false });
</cfscript>
