---
template: index.jade
---

<div class="col-xs-12">
<p class="lead">
Dexdis is a thin wrapper around the browser database
[IndexedDB](https://developer.mozilla.org/en-US/docs/IndexedDB) that is heavily
inspired by the popular key/value database [redis](http://redis.io).
</p>
</div>

<div class="row">
<div class="col-md-3 col-xs-6 row-xs">
<h3 class="header-icon">Fast
<span class="icon-background icon-dashboard"></span></h3>
<p class="text-justify">
Dexdis is a thin wrapper around the browser
database [IndexedDB](https://developer.mozilla.org/en-US/docs/IndexedDB) and
leverages the full power of the asynchronous API.
</p>
</div>

<div class="col-md-3 col-xs-6 row-xs">
<h3 class="header-icon">Small<span class="icon-background icon-resize-small"></span></h3>
<p class="text-justify">
Dexdis has no dependencies and comes as a single JavaScript file ready to
power your storage needs. It weights only 10kB minified and 2.8kB gzipped.
</p>
</div>

<div class="col-md-3 col-xs-6 row-xs">
<h3 class="header-icon">Easy
<span class="icon-background icon-html5"></span></h3>
<p class="text-justify">
Dexdis supports all keys and values just as IndexedDB which means, that it
is e.g. possible to store a whole blob just as easy as a string.
</p>
</div>

<div class="col-md-3 col-xs-6 row-xs">
<h3 class="header-icon">Persistent
<span class="icon-background icon-hdd"></span></h3>
<p class="text-justify">
By using IndexedDB every command runs transactional and is fully
persisted after completion. Multiple commands can be chained for more
flexibility.
</p>
</div>
</div>

<div class="row">
	<div class="col-xs-12">
		<h3>Compatibility</h3>
	</div>
</div>

<div class="row">
	<div class="col-md-6">
		<p>
		Dexdis supports every browser that implements IndexedDB. For older
		browsers (iOS, Android) that just implement the deprecated WebSQL
		standard you can use a
		[polyfill](http://nparashuram.com/IndexedDBShim/).
		</p>
	</div>
	<div class="col-md-6 col-overflow">
		<p>
			<a href="https://saucelabs.com/u/dexdis">
				<img id="saucematrix" src="https://saucelabs.com/browser-matrix/dexdis.svg" alt="Selenium Tests Status">
			</a>
		</p>
	</div>
</div>
