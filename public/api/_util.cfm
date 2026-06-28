<cfscript>
	// Shared helpers for the JSON API. Included at the top of every endpoint.

	// Parse a JSON request body into a struct (empty struct when absent/invalid).
	function readBody() {
		var raw = toString( getHttpRequestData().content );
		return ( len(trim(raw)) && isJSON(raw) ) ? deserializeJSON(raw) : {};
	}

	// Send a JSON response and stop.
	function respond(required any data, numeric status = 200) {
		cfheader(statusCode = arguments.status);
		cfcontent(type = "application/json; charset=utf-8");
		writeOutput( serializeJSON(arguments.data) );
		abort;
	}

	// Convert a query into a clean array of structs (lower-cased keys → tidy JSON).
	function rows(required query q) {
		var out = [];
		for ( var row in arguments.q ) {
			var item = {};
			for ( var col in listToArray(arguments.q.columnList) ) {
				item[ lCase(col) ] = row[col];
			}
			out.append(item);
		}
		return out;
	}

	function isAdmin() {
		return structKeyExists(session, "isAdmin") && session.isAdmin == true;
	}

	function requireAdmin() {
		if ( !isAdmin() ) respond({ "error": "Not authorized" }, 401);
	}

	variables.DS = { datasource: "blog" };
</cfscript>
