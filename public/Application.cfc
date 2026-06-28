component {

	this.name = "gentlyBlog";
	this.applicationTimeout = createTimeSpan(1, 0, 0, 0);
	this.sessionManagement   = true;
	this.sessionTimeout      = createTimeSpan(0, 8, 0, 0);
	this.setClientCookies    = true;

	// db/ lives one directory up from this webroot (public/).
	this.mappings["/db"] = getDirectoryFromPath(getCurrentTemplatePath()) & "../db";

	// --- config from environment (works locally and in the Gently sandbox) ---
	variables.sysEnv = server.system.environment;
	this.datasources["blog"] = {
		type:     "MySQL",
		host:     env("DB_HOST", "127.0.0.1"),
		port:     env("DB_PORT", "3306"),
		database: env("DB_NAME", "blog"),
		username: env("DB_USER", "root"),
		password: env("DB_PASSWORD", ""),
		custom:   "useUnicode=true&characterEncoding=UTF-8&allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC"
	};
	this.datasource = "blog";

	private string function env(required string key, required string fallback) {
		var e = server.system.environment;
		return ( structKeyExists(e, arguments.key) && len(e[arguments.key]) ) ? e[arguments.key] : arguments.fallback;
	}

	public boolean function onApplicationStart() {
		application.adminPassword = env("ADMIN_PASSWORD", "admin123");
		// Idempotent: create tables + seed sample data the first time the app boots.
		try {
			new db.Seeder().migrate();
		} catch (any e) {
			systemOutput("[blog] seed-on-start failed: " & e.message, true);
		}
		return true;
	}

	public boolean function onRequestStart(required string target) {
		if ( structKeyExists(url, "reinit") ) applicationStop();
		return true;
	}

	public void function onError(required any exception, required string eventName) {
		if ( findNoCase("/api/", cgi.script_name) ) {
			cfheader(statusCode = 500);
			cfcontent(type = "application/json; charset=utf-8");
			writeOutput( serializeJSON({ error: arguments.exception.message }) );
		} else {
			writeOutput("<h1>Application error</h1><pre>" & encodeForHTML(arguments.exception.message) & "</pre>");
		}
	}
}
