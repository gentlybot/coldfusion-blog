component {

	this.name = "gentlyBlog";
	this.applicationTimeout = createTimeSpan(1, 0, 0, 0);
	this.sessionManagement   = true;
	this.sessionTimeout      = createTimeSpan(0, 8, 0, 0);
	this.setClientCookies    = true;

	// db/ lives one directory up from this webroot (public/).
	this.mappings["/db"] = getDirectoryFromPath(getCurrentTemplatePath()) & "../db";

	// --- datasource from environment (works locally and in the Gently sandbox) ---
	this.datasources["blog"] = {
		type:     "MySQL",
		host:     env("DB_HOST", "127.0.0.1"),
		port:     env("DB_PORT", "3306"),
		database: env("DB_NAME", "blog"),
		username: env("DB_USER", "root"),
		password: env("DB_PASSWORD", ""),
		// validate: test each pooled connection (SELECT 1) before handing it out, so a
		// connection opened while MySQL was still starting can't poison the pool forever.
		validate: true,
		connectionTimeout: 1,
		custom: "useUnicode=true&characterEncoding=UTF-8&allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC&connectTimeout=8000&socketTimeout=30000"
	};
	this.datasource = "blog";

	private string function env(required string key, required string fallback) {
		var e = server.system.environment;
		var v = ( structKeyExists(e, arguments.key) && len(e[arguments.key]) ) ? e[arguments.key] : arguments.fallback;
		// Defensive: strip any stray surrounding quotes an env layer may have wrapped on.
		return reReplace(v, "^[""']+|[""']+$", "", "all");
	}

	public boolean function onApplicationStart() {
		application.adminPassword = env("ADMIN_PASSWORD", "admin123");
		application.dbReady = false;
		return true;
	}

	public boolean function onRequestStart(required string target) {
		if ( structKeyExists(url, "reinit") ) {
			applicationStop();
			location(url = cgi.script_name, addToken = false);
		}
		// Self-healing idempotent seed: keep trying until MySQL accepts a connection.
		// Each request makes at most one attempt; once it succeeds we set the flag and
		// stop. This survives MySQL still warming up when the app first boots.
		if ( !( application.dbReady ?: false ) ) {
			try {
				new db.Seeder().migrate();
				application.dbReady = true;
			} catch (any e) {
				// MySQL not ready yet — a later request will retry. Don't break page loads.
			}
		}
		return true;
	}

	public void function onError(required any exception, required string eventName) {
		if ( findNoCase("/api/", cgi.script_name) ) {
			cfheader(statusCode = 500);
			cfcontent(type = "application/json; charset=utf-8");
			writeOutput( serializeJSON({ "error": arguments.exception.message }) );
		} else {
			writeOutput("<h1>Application error</h1><pre>" & encodeForHTML(arguments.exception.message) & "</pre>");
		}
	}
}
