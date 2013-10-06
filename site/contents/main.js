
(function($){

$('#mainnav > li > a').each(function() {
	var el   = $(this);
	var href = el.attr('href');
	var li   = el.parent();
	if (location.pathname.indexOf(href) !== -1) {
		li.addClass('active');
	} else {
		li.removeClass('active');
	}
});

var addConsole = function(el, db, cb) {
	var dexdis = new Dexdis();
	dexdis.select(db, function() {
		dexdis.flushdb(function() {
			var con = el.console({
				promptLabel: 'dexdis> ',
				autofocus: false,
				animateScroll: false,
				promptHistory: true,
				commandValidate: function(line) {
					return line.length > 0;
				},
				commandHandle: function(line, report) {
					var l = line.toLowerCase();
					switch(l) {
						case 'clear':
						case 'reset':
						case 'exit':
							dexdis.flushdb(function() {
								con.reset();
							});
							return;
						break;
					}
					var notfound  = 'ERR: command not found';
					var syntaxerr = 'ERR: syntax error';
					line = line.trim();
					var match = regex.exec(line);
					if (match === null) {
						report(syntaxerr);
						return;
					} else if (dexdis[match[1].toLowerCase()] === undefined) {
						report(notfound);
						return;
					}
					var cb = function(err, res) {
						if (err != null) {
							report(err);
						} else {
							report('(' + typeof(res) + ') ' + res);
						}
					};
					var cmd = 'dexdis.' + match[1].toLowerCase();
					if (match[2].length > 0) {
						cmd += '(' + match[2] + ', cb)';
					} else {
						cmd += '(cb)';
					}
					try {
						eval(cmd);
					} catch(e) {
						report('ERR: ' + e.message);
					}
					return;
				}
			});
			cb(con);
		});
	});
};

var regex = /^(\w*)\((.*)\);?$/;
$('.dexdisrepl').each(function() {
	var el = $(this);
	var db = el.attr('data-db');
	if (db == null) {
		db = 1;
	}
	addConsole(el, db, function(con) {
		window.c = con;
		var cmds = el.attr('data-cmds');
		if (cmds != null) {
			try {
				var cmds = JSON.parse(cmds);
				var i = 0;
				var next = function() {
					if (i > cmds.length) {
						return;
					}
					var line = cmds[i];
					con.promptText(line, true, next);
					i++;
				};
				next();
			} catch(e) {
			}
		}
	});
});

})(jQuery);
