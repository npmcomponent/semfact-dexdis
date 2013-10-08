
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

var addConsole = function(el, db) {
	if (window.indexedDB === undefined) {
		el.addClass('error');
		el.append('<span>Your browser doesn\'t support IndexedDB :(</span>');
		return;
	}
	var dexdis = new Dexdis();
	dexdis.select(db, function(err) {
		if (err != null) {
			el.addClass('error');
			el.append('<span>Error while opening database :(</span>');
			return;
		} else {
			dexdis.flushdb(function() {
				el.console({
					prompt: 'dexdis>&nbsp;',
					handle: function(line, report) {
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
			});
		}
	});
};

var regex = /^(\w*)\((.*)\);?$/;
$('.dexdisrepl').each(function() {
	var el = $(this);
	var db = el.attr('data-db');
	if (db == null) {
		db = 1;
	}
	addConsole(el, db);
});

})(jQuery);
