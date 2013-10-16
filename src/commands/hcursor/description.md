Returns a cursor that can be used to iterate over all fields in the hash.
The returned cursor is a [`IDBCursorWithValue`](https://developer.mozilla.org/en-US/docs/Web/API/IDBCursor)
object.

### Keys

As the cursor object is a native IndexedDB object, the keys of the cursor
have a special internal format. Each key is of the form

```javascript
[<key>, 0, <field>]
```

The first element of the combined key is the original key of the hash. The
second element is always `0`. The third element is the field (which
correspondents to the current position of the cursor).

