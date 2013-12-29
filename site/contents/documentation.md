---
template: page.jade
---

## Documentation

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
