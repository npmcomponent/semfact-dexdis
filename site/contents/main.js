
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
