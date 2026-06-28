<cfinclude template="_util.cfm">
<cfscript>
	// GET /api/me.cfm → current admin session status
	respond({ "isAdmin": isAdmin() });
</cfscript>
