$ = jQuery

$.fn.console = (opts) ->
	container = this
	defopts =
		prompt: '> '
		handle: (x,y) -> y x
	opts = $.extend defopts, opts
	output    = $ '<div class="jquery-console-output"></div>'
	inputcon  = $ '<form class="jquery-console-input-container"></form>'
	prompt    = $ '<span class="jquery-console-prompt"></span>'
	input     = $ '<input class="jquery-console-input" type="text"
	                autocomplete="no" spellcheck="false" size="18" />'
	
	container.append output
	container.append inputcon
	inputcon.append  prompt
	inputcon.append  input
	prompt.html      opts.prompt
	
	hpointer = 0
	history  = []
	hbackup  = ''
	updatehist = ->
		line = history[hpointer]
		if line?
			input.val line
	
	clear = ->
		output.empty()
		history.push 'clear'
		hpointer = history.length
		input.val ''
	
	input.keypress (e) ->
		switch e.keyCode
			when 38
				hpointer--
				if hpointer < 0
					hpointer = 0
				if hpointer is history.length - 1
					hbackup = input.val()
				updatehist()
			when 40
				hpointer++
				if hpointer >= history.length
					hpointer = history.length
					input.val hbackup
				else
					updatehist()
	
	report = (res, val, cb) ->
		if val is undefined
			val = input.val()
		history.push val
		hpointer = history.length
		inc = $ '<div class="in"></div>'
		inp = $ '<span class="jquery-console-input"></span>'
		out = $ '<div class="result"></div>'
		inp.text val
		inc.append prompt.clone()
		inc.append inp
		out.text res
		output.append inc
		output.append out
		input.val ''
		container.scrollTop container[0].scrollHeight
		do cb if cb?
	
	container.click ->
		input.focus()
	
	inputcon.submit (e) ->
		val = input.val()
		if val is 'clear' or val is 'reset'
			do clear
		else
			opts.handle val, report
		e.preventDefault()
		return false
	
	cmds = container.attr 'data-cmds'
	if cmds?
		try
			cmds = JSON.parse cmds
			i = 0
			next = ->
				if i >= cmds.length
					return
				line = cmds[i]
				opts.handle line, (res) ->
					report res, line, next
				i++
			next()
		catch e
	
	this
