
# Dexdis

*The simplest way to use IndexedDB in the browser.*

[![Build Status](https://travis-ci.org/semfact/dexdis.png?branch=master)] (https://travis-ci.org/semfact/dexdis) [![Coverage Status] (https://coveralls.io/repos/semfact/dexdis/badge.png?branch=master)] (https://coveralls.io/r/semfact/dexdis?branch=master) [![Dependency Status](https://gemnasium.com/semfact/dexdis.png)] (https://gemnasium.com/semfact/dexdis) [![NPM version](https://badge.fury.io/js/dexdis.png)] (http://badge.fury.io/js/dexdis) [![Stories in Ready](https://badge.waffle.io/semfact/dexdis.png?label=ready)](https://waffle.io/semfact/dexdis) 

## Usage

```js
var d = new Dexdis();

d.select(0);
d.set('foo', 42, function(err, res) {
	d.get('foo', function(err, res) {
		console.log(res); // 42
	});
});

d.select(1);
var trans = d.multi();
trans.set('foo', 42);
trans.set('bar', 23);
trans.get('bar');
trans.get('foo');
trans.exec(function(err, res) {
	console.log(res); // ['OK', 'OK', 23, 42]
});
```

### Commands

For a list of available commands see the [command list](http://semfact.github.io/dexdis/commands/)
on the website.

## Installation

#### Standalone

Download as standalone JavaScript file diretly from the
[download page](http://semfact.github.io/dexdis/download.html)

#### Bower

```bash
$ bower install dexdis
```

#### Component

```bash
$ component install semfact/dexdis
```

#### Jam

```bash
$ jam install dexdis
```

#### Volo

```bash
$ volo add dexdis
```

#### NPM

```bash
$ npm install dexdis
```

## License

Apache 2.0 see [LICENSE.md](https://github.com/semfact/dexdis/blob/master/LICENSE.md)
file.

