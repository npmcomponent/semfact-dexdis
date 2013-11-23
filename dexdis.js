(function(root, factory) {
    if(typeof exports === 'object') {
        module.exports = factory();
    }
    else if(typeof define === 'function' && define.amd) {
        define('dexdis', [], factory);
    }
    else {
        root.Dexdis = factory();
    }
}(this, function() {
var Dexdis, DexdisCommands, DexdisDb, DexdisTransaction, errs, storenames, _ref,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

errs = {
  transaction: 'Operation not allowed during transaction',
  wrongargs: 'Wrong number of arguments',
  wrongtype: 'Operation against a key holding the wrong kind of value',
  notsupported: 'Operation not supported',
  toomuchop: 'Operation with too much operands'
};

storenames = ['keys', 'simple', 'hash', 'list'];

DexdisCommands = (function() {
  var hamming;

  function DexdisCommands(trans) {
    var s, _i, _len;
    this._stores = {};
    for (_i = 0, _len = storenames.length; _i < _len; _i++) {
      s = storenames[_i];
      this._stores[s] = trans.objectStore(s);
    }
    this.onerror = function() {};
  }

  DexdisCommands.prototype._checkttl = function(key, type, cb) {
    var checktype, error, get, keys;
    keys = this._stores.keys;
    error = this.onerror;
    if (typeof type === 'function') {
      cb = type;
      type = null;
    }
    checktype = function(keyinfo) {
      if ((type != null) && (keyinfo != null) && keyinfo.type !== type) {
        error(new Error(errs.wrongtype));
        return;
      }
      return cb(keyinfo);
    };
    get = keys.get(key);
    get.onsuccess = function() {
      var del, keyinfo;
      keyinfo = get.result;
      if ((keyinfo != null ? keyinfo.expire : void 0) != null) {
        if (Date.now() > keyinfo.expire) {
          del = keys["delete"](key);
          del.onsuccess = function() {
            return cb(void 0);
          };
          return this._delvalue(k, keyinfo.type);
        } else {
          return checktype(keyinfo);
        }
      } else {
        return checktype(keyinfo);
      }
    };
  };

  DexdisCommands.prototype._delvalue = function(key, type, cb) {
    var del, range, stores,
      _this = this;
    stores = this._stores;
    switch (type) {
      case 'simple':
        del = stores.simple["delete"](key);
        del.onsuccess = cb;
        break;
      case 'hash':
        range = IDBKeyRange.bound([key, 0], [key, 1], true, true);
        del = stores.hash["delete"](range);
        del.onsuccess = cb;
        break;
      case 'list':
        this._checkttl(key, 'list', function(keyinfo) {
          if (keyinfo === void 0) {
            cb();
          } else {
            return _lwalk(keyinfo, null, function(index, elem, key) {
              return stores.list["delete"](key);
            }, true, function() {
              del = stores.keys["delete"](key);
              return del.onsuccess = cb;
            });
          }
        });
        break;
      default:
        if (cb != null) {
          cb();
        }
    }
  };

  DexdisCommands.prototype._expiremap = function(key, cb, f) {
    var keys;
    keys = this._stores.keys;
    this._checkttl(key, function(keyinfo) {
      var r;
      if (keyinfo !== void 0) {
        keyinfo.expire = f(keyinfo.expire);
        r = keys.put(keyinfo, key);
        return r.onsuccess = function() {
          return cb(1);
        };
      } else {
        return cb(0);
      }
    });
  };

  DexdisCommands.prototype._getstr = function(key, cb) {
    var error;
    error = this.onerror;
    return this.get(key, function(val) {
      var type;
      if (val != null) {
        type = typeof val;
        if (type !== 'string') {
          if (type === 'number') {
            val = '' + val;
          } else {
            error(Error(errs.wrongtype));
            return;
          }
        }
      } else {
        val = '';
      }
      return cb(val);
    });
  };

  DexdisCommands.prototype._hget = function(key, field, cb) {
    var get, hash;
    hash = this._stores.hash;
    get = hash.get([key, 0, field]);
    return get.onsuccess = function() {
      if (get.result === void 0) {
        return cb(null);
      } else {
        return cb(get.result);
      }
    };
  };

  DexdisCommands.prototype._hset = function(key, field, value, cb) {
    var cnt, hash, hkey, keys, _ref;
    _ref = this._stores, keys = _ref.keys, hash = _ref.hash;
    hkey = [key, 0, field];
    cnt = hash.count(hkey);
    cnt.onsuccess = function() {
      var keyinfo, nex, put;
      nex = cnt.result === 0;
      if (nex) {
        keyinfo = {
          type: 'hash'
        };
        keys.put(keyinfo, key);
      }
      put = hash.put(value, hkey);
      return put.onsuccess = function() {
        if (nex) {
          return cb(1);
        } else {
          return cb(0);
        }
      };
    };
  };

  DexdisCommands.prototype._linsert = function(key, keyinfo, elem, index, moveRight, neighbor, cb) {
    var editNeighbor, getEditNeighbor, keys, list, putNewElem, _ref;
    _ref = this._stores, keys = _ref.keys, list = _ref.list;
    editNeighbor = function(neighborElem, elemKey, left, cb) {
      var putNeighbor;
      if (left) {
        neighbor = elem.prev;
        neighborElem.next = elemKey;
      } else {
        neighbor = elem.next;
        neighborElem.prev = elemKey;
      }
      putNeighbor = list.put(neighborElem, neighbor);
      return putNeighbor.onsuccess = cb;
    };
    getEditNeighbor = function(neighbor, elemKey, left, cb) {
      var getNeighbor;
      if (neighbor === null) {
        return cb();
      } else {
        getNeighbor = list.get(neighbor);
        getNeighbor.onsuccess = function() {
          return editNeighbor(getNeighbor.result, elemKey, left, cb);
        };
      }
    };
    putNewElem = list.add(elem);
    putNewElem.onsuccess = function(ev) {
      var elemKey, putlist;
      elemKey = ev.target.result;
      if ((index === 0) || (index === -keyinfo.len)) {
        keyinfo.first = elemKey;
      }
      if ((index === keyinfo.len) || (index === -1)) {
        keyinfo.last = elemKey;
      }
      if (keyinfo.len === 0) {
        keyinfo.first = elemKey;
        keyinfo.last = elemKey;
      }
      keyinfo.len += 1;
      putlist = keys.put(keyinfo, key);
      putlist.onsuccess = function() {
        var c, leftNeighbor, rightNeighbor;
        if (moveRight) {
          rightNeighbor = neighbor;
        } else {
          leftNeighbor = neighbor;
        }
        c = function() {
          if (leftNeighbor != null) {
            return editNeighbor(leftNeighbor, elemKey, true, function() {
              return cb(keyinfo.len);
            });
          } else {
            return getEditNeighbor(elem.prev, elemKey, true, function() {
              return cb(keyinfo.len);
            });
          }
        };
        if (rightNeighbor != null) {
          return editNeighbor(rightNeighbor, elemKey, false, c);
        } else {
          return getEditNeighbor(elem.next, elemKey, false, c);
        }
      };
    };
  };

  DexdisCommands.prototype._listpop = function(key, left, cb) {
    var keys, list, _ref;
    _ref = this._stores, keys = _ref.keys, list = _ref.list;
    this._checkttl(key, 'list', function(keyinfo) {
      var dellist, elemKey, get, value;
      if (keyinfo === void 0) {
        cb(null);
        return;
      } else {
        value = null;
        dellist = function() {
          var del;
          del = keys["delete"](key);
          del.onsuccess = cb(value);
        };
        if (left) {
          elemKey = keyinfo.first;
        } else {
          elemKey = keyinfo.last;
        }
        if (elemKey !== null) {
          get = list.get(elemKey);
          get.onsuccess = function() {
            var delelem;
            delelem = list["delete"](elemKey);
            delelem.onsuccess = function() {
              var put;
              value = get.result.value;
              if (left) {
                keyinfo.first = get.result.next;
              } else {
                keyinfo.last = get.result.prev;
              }
              keyinfo.len -= 1;
              put = keys.put(keyinfo, key);
              put.onsuccess = function() {
                if (keyinfo.len === 0) {
                  dellist();
                } else {
                  cb(value);
                }
              };
            };
          };
        } else {
          dellist();
        }
      }
    });
  };

  DexdisCommands.prototype._listpush = function(key, values, left, cb) {
    var keys, list, store, _ref,
      _this = this;
    if (values.length === 0) {
      cb(0);
      return;
    }
    _ref = this._stores, keys = _ref.keys, list = _ref.list;
    store = list;
    this._checkttl(key, 'list', function(keyinfo) {
      var add, append, put;
      append = function(value, cb) {
        var elem, index;
        if (left) {
          elem = {
            prev: null,
            value: value,
            next: keyinfo.first
          };
          index = 0;
        } else {
          elem = {
            prev: keyinfo.last,
            value: value,
            next: null
          };
          index = keyinfo.len;
        }
        return _this._linsert(key, keyinfo, elem, index, left, null, cb);
      };
      add = function() {
        var i, next;
        i = 0;
        next = function() {
          return append(values[i], function() {
            i++;
            if (i === values.length) {
              return cb(keyinfo.len);
            } else {
              return next();
            }
          });
        };
        return next();
      };
      if (keyinfo === void 0) {
        keyinfo = {
          type: 'list',
          first: null,
          last: null,
          len: 0
        };
        put = keys.put(keyinfo, key);
        return put.onsuccess = add;
      } else {
        return add();
      }
    });
  };

  DexdisCommands.prototype._lmultiindex = function(keyinfo, leftIndex, rightIndex, cb) {
    var left, len, li, ri;
    li = leftIndex;
    ri = rightIndex;
    len = keyinfo.len;
    if (leftIndex >= 0) {
      left = true;
      if ((rightIndex >= 0) && (rightIndex < leftIndex)) {
        left = false;
        ri = leftIndex - len;
        li = rightIndex - len;
      }
      if (rightIndex < 0) {
        if (leftIndex - len > rightIndex) {
          left = false;
          ri = leftIndex - len;
          li = rightIndex;
        } else {
          ri = rightIndex + len;
        }
      }
    } else {
      ri = leftIndex;
      li = rightIndex;
      left = false;
      if (rightIndex >= 0) {
        if (rightIndex > leftIndex + len) {
          left = true;
          li = leftIndex + len;
          ri = rightIndex;
        } else {
          li = rightIndex - len;
        }
      }
      if ((rightIndex < 0) && (rightIndex > leftIndex)) {
        left = true;
        li = leftIndex + len;
        ri = rightIndex + len;
      }
    }
    return cb(li, ri, left);
  };

  DexdisCommands.prototype._lwalk = function(keyinfo, cond, func, left, cb) {
    var ekey, first, keys, list, start, store, walk, _ref;
    _ref = this._stores, keys = _ref.keys, list = _ref.list;
    store = list;
    walk = function(index, elem, key) {
      if ((cond != null) && cond(index, elem)) {
        cb(index, elem, key);
      } else {
        if (func != null) {
          func(index, elem, key);
        }
        if (left) {
          if (elem.next == null) {
            cb(null);
            return;
          } else {
            key = elem.next;
          }
        } else {
          if (elem.prev == null) {
            cb(null);
            return;
          } else {
            key = elem.prev;
          }
        }
        elem = store.get(key);
        elem.onsuccess = function() {
          if (elem.result === void 0) {
            cb(null);
            return;
          } else {
            if (left) {
              index = index + 1;
            } else {
              index = index - 1;
            }
            walk(index, elem.result, key);
          }
        };
      }
    };
    if (left) {
      if (keyinfo.first === null) {
        cb(null);
        return;
      } else {
        ekey = keyinfo.first;
        start = 0;
      }
    } else {
      if (keyinfo.last === null) {
        cb(null);
      } else {
        ekey = keyinfo.last;
        start = -1;
      }
    }
    first = store.get(ekey);
    return first.onsuccess = function() {
      if (first.result === void 0) {
        cb(null);
        return;
      } else {
        walk(start, first.result, ekey);
      }
    };
  };

  DexdisCommands.prototype._map = function(key, cb, f) {
    var keys, simple, value, _ref,
      _this = this;
    _ref = this._stores, keys = _ref.keys, simple = _ref.simple;
    value = null;
    this._checkttl(key, 'simple', function(keyinfo) {
      var get;
      if (keyinfo != null) {
        get = simple.get(key);
        return get.onsuccess = function() {
          var put;
          value = f(get.result);
          put = simple.put(value, key);
          return put.onsuccess = function() {
            return cb(value);
          };
        };
      } else {
        value = f(null);
        return _this.set(key, value, function() {
          return cb(value);
        });
      }
    });
  };

  DexdisCommands.prototype._ttlmap = function(key, cb, f) {
    this._checkttl(key, function(keyinfo) {
      var ret;
      if (keyinfo !== void 0) {
        ret = -1;
        if (keyinfo.expire != null) {
          ret = keyinfo.expire - Date.now();
          if (f != null) {
            ret = f(ret);
          }
        }
        return cb(ret);
      } else {
        return cb(-2);
      }
    });
  };

  DexdisCommands.prototype.append = function(key, val, cb) {
    var cbmap, l;
    l = 0;
    cbmap = function() {
      return cb(l);
    };
    return this._map(key, cbmap, function(x) {
      var ret;
      if (x != null) {
        ret = x + val;
      } else {
        ret = val;
      }
      l = ret.length;
      return ret;
    });
  };

  hamming = function(x) {
    var m1, m2, m4;
    m1 = 0x55555555;
    m2 = 0x33333333;
    m4 = 0x0f0f0f0f;
    x -= (x >> 1) & m1;
    x = (x & m2) + ((x >> 2) & m2);
    x = (x + (x >> 4)) & m4;
    x += x >> 8;
    x += x >> 16;
    return x & 0x7f;
  };

  DexdisCommands.prototype.bitcount = function() {
    var cb, key, range, _i;
    key = arguments[0], range = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    return this._getstr(key, function(val) {
      var end, start;
      if (range.length === 2) {
        start = range[0];
        end = range[1];
        if (start < 0) {
          start = 4 + start;
        }
        if (end < 0) {
          end = 4 + end + 1;
        }
        val &= -1 >>> (32 - end * 8);
        val >>>= start * 8;
      }
      return cb(hamming(val));
    });
  };

  DexdisCommands.prototype.bitop = function() {
    var cb, dest, f, i, init, next, op, srcs, vals, _i,
      _this = this;
    op = arguments[0], dest = arguments[1], srcs = 4 <= arguments.length ? __slice.call(arguments, 2, _i = arguments.length - 1) : (_i = 2, []), cb = arguments[_i++];
    f = null;
    init = 0;
    switch (op.toUpperCase()) {
      case 'NOT':
        f = function(x, y) {
          return ~y;
        };
        if (srcs.length > 1) {
          this.onerror(Error(errs.toomuchop));
          return;
        }
        break;
      case 'AND':
        f = function(x, y) {
          return x & y;
        };
        init = -1;
        break;
      case 'OR':
        f = function(x, y) {
          return x | y;
        };
        break;
      case 'XOR':
        f = function(x, y) {
          return x ^ y;
        };
    }
    if (f === null) {
      this.onerror(Error(errs.notsupported));
      return;
    }
    vals = [];
    i = 0;
    next = function(v) {
      var key, val;
      if (v !== void 0) {
        vals.push(v);
      }
      i++;
      if (i > srcs.length) {
        val = vals.reduce(f, init);
        _this.set(dest, val, function() {
          return cb(('' + val).length);
        });
        return;
      }
      key = srcs[i - 1];
      return _this.get(key, next);
    };
    return next();
  };

  DexdisCommands.prototype.dbsize = function(cb) {
    var cnt, keys;
    keys = this._stores.keys;
    cnt = keys.count();
    return cnt.onsuccess = function() {
      return cb(cnt.result);
    };
  };

  DexdisCommands.prototype.decr = function(key, cb) {
    return this.decrby(key, 1, cb);
  };

  DexdisCommands.prototype.decrby = function(key, dec, cb) {
    return this.incrby(key, -dec, cb);
  };

  DexdisCommands.prototype.del = function() {
    var called, cb, count, dels, k, max, stores, _fn, _i, _j, _len,
      _this = this;
    dels = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
    stores = this._stores;
    if (dels.length === 0) {
      cb(0);
      return;
    }
    count = 0;
    called = 0;
    max = dels.length;
    _fn = function(k) {
      return _this._checkttl(k, function(keyinfo) {
        called++;
        if (keyinfo != null) {
          count++;
          stores.keys["delete"](k);
          _this._delvalue(k, keyinfo.type);
        }
        if (called === max) {
          return cb(count);
        }
      });
    };
    for (_j = 0, _len = dels.length; _j < _len; _j++) {
      k = dels[_j];
      _fn(k);
    }
  };

  DexdisCommands.prototype.exists = function(key, cb) {
    return this._checkttl(key, function(keyinfo) {
      if (keyinfo != null) {
        return cb(1);
      } else {
        return cb(0);
      }
    });
  };

  DexdisCommands.prototype.expire = function(key, seconds, cb) {
    return this._expiremap(key, cb, function() {
      return Date.now() + seconds * 1000;
    });
  };

  DexdisCommands.prototype.expireat = function(key, tstamp, cb) {
    return this._expiremap(key, cb, function() {
      return tstamp * 1000;
    });
  };

  DexdisCommands.prototype.flushdb = function(cb) {
    var store, stores, _i, _len;
    stores = this._stores;
    stores.keys.clear();
    for (_i = 0, _len = storenames.length; _i < _len; _i++) {
      store = storenames[_i];
      stores[store].clear();
    }
    cb('OK');
  };

  DexdisCommands.prototype.get = function(key, cb) {
    var keys, simple, _ref;
    _ref = this._stores, keys = _ref.keys, simple = _ref.simple;
    this._checkttl(key, 'simple', function(keyinfo) {
      var get;
      if (keyinfo === void 0) {
        return cb(null);
      } else {
        get = simple.get(key);
        return get.onsuccess = function() {
          return cb(get.result);
        };
      }
    });
  };

  DexdisCommands.prototype.getbit = function(key, offset, cb) {
    return this._getstr(key, function(val) {
      if (offset > 31) {
        return cb(0);
      } else {
        return cb((val >>> offset) & 1);
      }
    });
  };

  DexdisCommands.prototype.getrange = function(key, start, end, cb) {
    return this._getstr(key, function(val) {
      var len;
      len = val.length;
      if (start < 0) {
        start = len + start;
      }
      if (end < 0) {
        end = len + end + 1;
      }
      return cb(val.substring(start, end));
    });
  };

  DexdisCommands.prototype.getset = function(key, value, cb) {
    var _this = this;
    return this.get(key, function(val) {
      return _this.set(key, value, function() {
        return cb(val);
      });
    });
  };

  DexdisCommands.prototype.hcursor = function() {
    var args, cb, hash, key, l, lopen, lower, uopen, upper, _i;
    key = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    l = args.length;
    if (l !== 0 && l !== 2 && l !== 4) {
      this.onerror(new Error(errs.wrongargs));
      return;
    }
    if (l > 1) {
      lopen = false;
      uopen = false;
      lower = args[0];
      upper = args[1];
    }
    if (l === 4) {
      lopen = args[2];
      uopen = args[3];
    }
    hash = this._stores.hash;
    this._checkttl(key, 'hash', function(keyinfo) {
      var cursor, range;
      if (keyinfo != null) {
        if (l === 0) {
          range = IDBKeyRange.bound([key, 0], [key, 1], true, true);
        } else {
          range = IDBKeyRange.bound([key, 0, lower], [key, 0, upper], lopen, uopen);
        }
        cursor = hash.openCursor(range);
        cursor.onsuccess = function() {
          if (cursor.result === void 0) {
            return cb(null);
          } else {
            return cb(cursor.result);
          }
        };
      } else {
        cb(null);
      }
    });
  };

  DexdisCommands.prototype.hdel = function() {
    var cb, fields, hash, key, _i;
    key = arguments[0], fields = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    if (fields.length === 0) {
      cb(0);
      return;
    }
    hash = this._stores.hash;
    return this._checkttl(key, 'hash', function(keyinfo) {
      var called, count, field, max, _j, _len, _results;
      if (keyinfo != null) {
        count = 0;
        called = 0;
        max = fields.length;
        _results = [];
        for (_j = 0, _len = fields.length; _j < _len; _j++) {
          field = fields[_j];
          _results.push((function(field) {
            var cnt, hkey;
            hkey = [key, 0, field];
            cnt = hash.count(hkey);
            return cnt.onsuccess = function() {
              var del;
              called++;
              if (cnt.result === 1) {
                count++;
                del = hash["delete"](hkey);
              }
              if (called === max) {
                return cb(count);
              }
            };
          })(field));
        }
        return _results;
      } else {
        return cb(0);
      }
    });
  };

  DexdisCommands.prototype.hexists = function(key, field, cb) {
    var hash;
    hash = this._stores.hash;
    return this._checkttl(key, 'hash', function(keyinfo) {
      var cnt;
      if (keyinfo != null) {
        cnt = hash.count([key, 0, field]);
        return cnt.onsuccess = function() {
          return cb(cnt.result);
        };
      } else {
        return cb(0);
      }
    });
  };

  DexdisCommands.prototype.hget = function(key, field, cb) {
    var hash,
      _this = this;
    hash = this._stores.hash;
    this._checkttl(key, 'hash', function(keyinfo) {
      _this._hget(key, field, cb);
    });
  };

  DexdisCommands.prototype.hgetall = function(key, cb) {
    var ret;
    ret = [];
    return this.hcursor(key, function(cursor) {
      if (cursor != null) {
        if (cursor.key !== void 0) {
          ret.push(cursor.key[2]);
          ret.push(cursor.value);
          return cursor["continue"]();
        } else {
          return cb(ret);
        }
      } else {
        return cb(ret);
      }
    });
  };

  DexdisCommands.prototype.hincrby = function(key, field, inc, cb) {
    var _this = this;
    this.hget(key, field, function(x) {
      var y;
      if (x != null) {
        y = x + inc;
      } else {
        y = inc;
      }
      _this._hset(key, field, y, function() {
        return cb(y);
      });
    });
  };

  DexdisCommands.prototype.hkeys = function(key, cb) {
    var ret;
    ret = [];
    return this.hcursor(key, function(cursor) {
      if (cursor != null) {
        if (cursor.key !== void 0) {
          ret.push(cursor.key[2]);
          return cursor["continue"]();
        } else {
          return cb(ret);
        }
      } else {
        return cb(ret);
      }
    });
  };

  DexdisCommands.prototype.hlen = function(key, cb) {
    var hash;
    hash = this._stores.hash;
    return this._checkttl(key, 'hash', function(keyinfo) {
      var cnt, range;
      if (keyinfo != null) {
        range = IDBKeyRange.bound([key, 0], [key, 1], true, true);
        cnt = hash.count(range);
        return cnt.onsuccess = function() {
          return cb(cnt.result);
        };
      } else {
        return cb(0);
      }
    });
  };

  DexdisCommands.prototype.hmget = function() {
    var args, cb, key, _i,
      _this = this;
    key = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    this._checkttl(key, 'hash', function(keyinfo) {
      var cnt, field, i, ret, _fn, _j, _len;
      ret = [];
      cnt = 0;
      _fn = function(field, i) {
        return _this._hget(key, field, function(res) {
          ret[i] = res;
          cnt++;
          if (cnt === args.length) {
            return cb(ret);
          }
        });
      };
      for (i = _j = 0, _len = args.length; _j < _len; i = ++_j) {
        field = args[i];
        _fn(field, i);
      }
    });
  };

  DexdisCommands.prototype.hmset = function() {
    var args, cb, key, _i,
      _this = this;
    key = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    if (args.length % 2 !== 0) {
      this.onerror(new Error(errs.wrongargs));
      return;
    }
    this._checkttl(key, 'hash', function(keyinfo) {
      var field, i, value, _j, _len;
      for (i = _j = 0, _len = args.length; _j < _len; i = _j += 2) {
        field = args[i];
        value = args[i + 1];
        _this._hset(key, field, value, function() {});
        if (i === args.length - 2) {
          cb('OK');
        }
      }
    });
  };

  DexdisCommands.prototype.hset = function(key, field, value, cb) {
    var _this = this;
    this._checkttl(key, 'hash', function(keyinfo) {
      _this._hset(key, field, value, cb);
    });
  };

  DexdisCommands.prototype.hsetnx = function(key, field, value, cb) {
    var hash,
      _this = this;
    hash = this._stores.hash;
    this.hexists(key, field, function(ex) {
      if (ex === 0) {
        return _this._hset(key, field, value, cb);
      } else {
        return cb(0);
      }
    });
  };

  DexdisCommands.prototype.hvals = function(key, cb) {
    var ret;
    ret = [];
    return this.hcursor(key, function(cursor) {
      if (cursor != null) {
        if (cursor.key !== void 0) {
          ret.push(cursor.value);
          return cursor["continue"]();
        } else {
          return cb(ret);
        }
      } else {
        return cb(ret.sort());
      }
    });
  };

  DexdisCommands.prototype.incr = function(key, cb) {
    return this.incrby(key, 1, cb);
  };

  DexdisCommands.prototype.incrby = function(key, inc, cb) {
    return this._map(key, cb, function(x) {
      return x + inc;
    });
  };

  DexdisCommands.prototype.ldel = function(key, leftIndex, rightIndex, cb) {
    var keys, list, _ref,
      _this = this;
    _ref = this._stores, keys = _ref.keys, list = _ref.list;
    this._checkttl(key, 'list', function(keyinfo) {
      var left, leftEdge, rightEdge, values;
      if (keyinfo === void 0) {
        cb([]);
        return;
      } else {
        left = true;
        leftEdge = keyinfo.first;
        rightEdge = keyinfo.last;
        values = [];
        _this._lmultiindex(keyinfo, leftIndex, rightIndex, function(l, r, dir) {
          leftIndex = l;
          rightIndex = r;
          return left = dir;
        });
        _this._lwalk(keyinfo, function(index, elem) {
          var stop;
          if (left) {
            stop = index === rightIndex + 1;
          } else {
            stop = index === leftIndex - 1;
          }
          return stop;
        }, function(i, elem, k) {
          if (i === leftIndex) {
            leftEdge = elem.prev;
          }
          if (i === rightIndex) {
            rightEdge = elem.next;
          }
          if (i >= leftIndex && i <= rightIndex) {
            values.push(elem.value);
            list["delete"](k);
            return keyinfo.len -= 1;
          }
        }, left, function(i, elem, k) {
          var del, getLeft, getPutRight, putList;
          putList = function() {
            var putlist;
            putlist = keys.put(keyinfo, key);
            return putlist.onsuccess = function() {
              cb(values);
            };
          };
          getPutRight = function(c) {
            var getRight;
            getRight = list.get(rightEdge);
            return getRight.onsuccess = function() {
              var putRight;
              getRight.result.prev = leftEdge;
              putRight = list.put(getRight.result, rightEdge);
              return putRight.onsuccess = c;
            };
          };
          if ((leftEdge === null) && (rightEdge === null)) {
            del = keys["delete"](key);
            del.onsuccess = function() {
              cb(values);
            };
            return;
          }
          if (leftEdge === null) {
            keyinfo.first = rightEdge;
            getPutRight(putList);
          } else {
            getLeft = list.get(leftEdge);
            return getLeft.onsuccess = function() {
              getLeft.result.next = rightEdge;
              if (rightEdge === null) {
                keyinfo.last = leftEdge;
                putList();
              } else {
                getPutRight(putList);
              }
            };
          }
        });
      }
    });
  };

  DexdisCommands.prototype.lget = function(key, leftIndex, rightIndex, cb) {
    var _this = this;
    this._checkttl(key, 'list', function(keyinfo) {
      var left, values;
      if (keyinfo === void 0) {
        cb(null);
      } else {
        values = [];
        left = true;
        _this._lmultiindex(keyinfo, leftIndex, rightIndex, function(l, r, turn) {
          leftIndex = l;
          rightIndex = r;
          return left = turn;
        });
        return _this._lwalk(keyinfo, function(index, elem) {
          var stop;
          if (left) {
            stop = index === keyinfo.len;
          } else {
            stop = index === -keyinfo.len - 1;
          }
          return stop;
        }, function(i, elem, k) {
          if (i >= leftIndex && i <= rightIndex) {
            return values.push(elem.value);
          }
        }, left, function(i, elem, k) {
          return cb(values);
        });
      }
    });
  };

  DexdisCommands.prototype.lindex = function(key, index, cb) {
    var _this = this;
    this._checkttl(key, 'list', function(keyinfo) {
      if (keyinfo === void 0) {
        cb(null);
      } else {
        return _this._lwalk(keyinfo, function(i, elem) {
          return i === index;
        }, null, index >= 0, function(i, elem, k) {
          if (i === null) {
            cb(null);
          } else {
            cb(elem.value);
          }
        });
      }
    });
  };

  DexdisCommands.prototype.linsert = function(key, index, value, cb) {
    var keys, list, _ref,
      _this = this;
    _ref = this._stores, keys = _ref.keys, list = _ref.list;
    this._checkttl(key, 'list', function(keyinfo) {
      if (keyinfo === void 0) {
        cb(null);
        return;
      } else {
        _this._lwalk(keyinfo, function(i, elem) {
          return i === index;
        }, null, index >= 0, function(i, elem, k) {
          var newElem, next, prev;
          if (i === null) {
            cb(null);
          } else {
            if (index >= 0) {
              prev = elem.prev;
              newElem = {
                prev: prev,
                value: value,
                next: k
              };
              return _this._linsert(key, keyinfo, newElem, index, true, elem, function() {
                return cb('OK');
              });
            } else {
              next = elem.next;
              newElem = {
                prev: k,
                value: value,
                next: next
              };
              return _this._linsert(key, keyinfo, newElem, index, false, elem, function() {
                return cb('OK');
              });
            }
          }
        });
      }
    });
  };

  DexdisCommands.prototype.llen = function(key, cb) {
    this._checkttl(key, 'list', function(keyinfo) {
      if (keyinfo === void 0) {
        cb(0);
      } else {
        cb(keyinfo.len);
      }
    });
  };

  DexdisCommands.prototype.lpop = function(key, cb) {
    return this._listpop(key, true, cb);
  };

  DexdisCommands.prototype.lpush = function() {
    var cb, key, values, _i;
    key = arguments[0], values = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    return this._listpush(key, values, true, cb);
  };

  DexdisCommands.prototype.lrpop = function(key, cb) {
    return this._listpop(key, false, cb);
  };

  DexdisCommands.prototype.lrpush = function() {
    var cb, key, values, _i;
    key = arguments[0], values = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    return this._listpush(key, values, false, cb);
  };

  DexdisCommands.prototype.lset = function(key, index, value, cb) {
    var list,
      _this = this;
    list = this._stores.list;
    this._checkttl(key, 'list', function(keyinfo) {
      if (keyinfo === void 0) {
        _this.onerror(new Error(errs.wrongargs));
      } else {
        return _this._lwalk(keyinfo, function(i, elem) {
          return i === index;
        }, null, index >= 0, function(i, elem, key) {
          var put;
          if (i === null) {
            _this.onerror(new Error(errs.wrongargs));
            return;
          } else {
            elem.value = value;
            put = list.put(elem, key);
            put.onsuccess = function() {
              cb('OK');
            };
          }
        });
      }
    });
  };

  DexdisCommands.prototype.persist = function(key, cb) {
    var keys;
    keys = this._stores.keys;
    this._checkttl(key, function(keyinfo) {
      var r, ret;
      if (keyinfo !== void 0) {
        ret = 0;
        if (keyinfo.expire != null) {
          delete keyinfo.expire;
          ret = 1;
        }
        r = keys.put(keyinfo, key);
        return r.onsuccess = function() {
          return cb(ret);
        };
      } else {
        return cb(0);
      }
    });
  };

  DexdisCommands.prototype.pexpire = function(key, milliseconds, cb) {
    return this._expiremap(key, cb, function() {
      return Date.now() + milliseconds;
    });
  };

  DexdisCommands.prototype.pexpireat = function(key, tstamp, cb) {
    return this._expiremap(key, cb, function() {
      return tstamp;
    });
  };

  DexdisCommands.prototype.psetex = function(key, secs, value, cb) {
    var _this = this;
    return this.set(key, value, function() {
      return _this.pexpire(key, secs, function() {
        return cb('OK');
      });
    });
  };

  DexdisCommands.prototype.pttl = function(key, cb) {
    return this._ttlmap(key, cb);
  };

  DexdisCommands.prototype.randomkey = function(cb) {
    var cnt, keys;
    keys = this._stores.keys;
    cnt = keys.count();
    return cnt.onsuccess = function() {
      var adv, cur, rnd;
      rnd = Math.floor(Math.random() * cnt.result);
      cur = keys.openCursor();
      adv = false;
      return cur.onsuccess = function() {
        var cursor;
        cursor = cur.result;
        if (cursor != null) {
          if (adv || rnd === 0) {
            return cb(cursor.key);
          } else {
            adv = true;
            return cursor.advance(rnd);
          }
        }
      };
    };
  };

  DexdisCommands.prototype.set = function(key, value, cb) {
    var keyinfo, keys, put, simple, _ref;
    _ref = this._stores, keys = _ref.keys, simple = _ref.simple;
    keyinfo = {
      type: 'simple'
    };
    keys.put(keyinfo, key);
    put = simple.put(value, key);
    put.onsuccess = function() {
      return cb('OK');
    };
  };

  DexdisCommands.prototype.setbit = function(key, offset, value, cb) {
    var _this = this;
    return this._getstr(key, function(val) {
      var mask, newval;
      value &= 1;
      mask = 1 << offset;
      newval = (val & ~mask) | (value << offset);
      return _this.set(key, newval, function() {
        if ((val & mask) !== 0) {
          return cb(1);
        } else {
          return cb(0);
        }
      });
    });
  };

  DexdisCommands.prototype.setex = function(key, secs, value, cb) {
    var _this = this;
    return this.set(key, value, function() {
      return _this.expire(key, secs, function() {
        return cb('OK');
      });
    });
  };

  DexdisCommands.prototype.setnx = function(key, value, cb) {
    var _this = this;
    this._checkttl(key, 'simple', function(keyinfo) {
      if (keyinfo != null) {
        return cb(0);
      } else {
        return _this.set(key, value, function() {
          return cb(1);
        });
      }
    });
  };

  DexdisCommands.prototype.setrange = function(key, offset, value, cb) {
    var _this = this;
    return this._getstr(key, function(val) {
      var l, left, newval, right;
      l = value.length;
      left = val.substring(0, offset);
      right = val.substr(offset + l);
      newval = left + value + right;
      return _this.set(key, newval, function() {
        return cb(newval.length);
      });
    });
  };

  DexdisCommands.prototype.strlen = function(key, cb) {
    return this._getstr(key, function(val) {
      return cb(val.length);
    });
  };

  DexdisCommands.prototype.ttl = function(key, cb) {
    return this._ttlmap(key, cb, function(x) {
      return Math.round(x / 1000);
    });
  };

  DexdisCommands.prototype.type = function(key, cb) {
    return this._checkttl(key, function(keyinfo) {
      if (keyinfo != null) {
        return cb(keyinfo.type);
      } else {
        return cb('none');
      }
    });
  };

  return DexdisCommands;

})();

DexdisCommands.cmds = Object.keys(DexdisCommands.prototype).filter(function(x) {
  return x[0] !== '_';
});

DexdisDb = (function() {
  function DexdisDb() {}

  DexdisDb.prototype._transaction = function(cb, mode) {
    var trans;
    if (mode == null) {
      mode = 'readwrite';
    }
    trans = this.db.transaction(storenames, mode);
    trans.onerror = function(e) {
      if (cb != null) {
        return cb(e);
      }
    };
    return trans;
  };

  return DexdisDb;

})();

Dexdis = (function(_super) {
  var cmd, _fn, _i, _len, _ref1,
    _this = this;

  __extends(Dexdis, _super);

  function Dexdis() {
    _ref = Dexdis.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Dexdis.prototype._cmd = function(cmd, args, cb, mode) {
    var cmds, error, ret, save, trans;
    ret = null;
    error = null;
    save = function(x) {
      ret = x;
    };
    trans = this._transaction(cb, mode);
    trans.oncomplete = function() {
      if (cb != null) {
        return cb(null, ret);
      }
    };
    trans.onabort = function() {
      if (error != null) {
        return cb(error);
      }
    };
    cmds = new DexdisCommands(trans);
    cmds.onerror = function(err) {
      error = err;
      return trans.abort();
    };
    cmds[cmd].apply(cmds, args.concat([save]));
  };

  Dexdis.prototype.select = function(db, cb) {
    var r,
      _this = this;
    if (typeof db === 'function') {
      cb = db;
      db = 1;
    }
    r = indexedDB.open(db, 1);
    r.onupgradeneeded = function(e) {
      var store, _i, _len, _results;
      db = r.result;
      _results = [];
      for (_i = 0, _len = storenames.length; _i < _len; _i++) {
        store = storenames[_i];
        if (store === 'list') {
          _results.push(db.createObjectStore('list', {
            autoIncrement: true
          }));
        } else {
          _results.push(db.createObjectStore(store));
        }
      }
      return _results;
    };
    r.onsuccess = function(e) {
      _this.db = r.result;
      if (cb != null) {
        return cb(null);
      }
    };
    r.onerror = function(e) {
      cb(r.error);
      return e.preventDefault();
    };
    return this;
  };

  Dexdis.prototype.quit = function(cb) {
    if (this.db != null) {
      this.db.close();
    }
    if (cb != null) {
      cb(null);
    }
    return this;
  };

  Dexdis.prototype.multi = function(cb) {
    return new DexdisTransaction(this.db);
  };

  _ref1 = DexdisCommands.cmds;
  _fn = function(cmd) {
    return Dexdis.prototype[cmd] = function() {
      var args, cb, _j;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _j = arguments.length - 1) : (_j = 0, []), cb = arguments[_j++];
      if (typeof cb === 'function') {
        this._cmd(cmd, args, cb);
      } else {
        args = args.concat([cb]);
        this._cmd(cmd, args, function() {});
      }
      return this;
    };
  };
  for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
    cmd = _ref1[_i];
    _fn(cmd);
  }

  return Dexdis;

}).call(this, DexdisDb);

DexdisTransaction = (function(_super) {
  var cmd, _fn, _i, _len, _ref1,
    _this = this;

  __extends(DexdisTransaction, _super);

  function DexdisTransaction(db) {
    this.db = db;
    this.buffer = [];
  }

  DexdisTransaction.prototype._buffercmd = function(cmd, args) {
    return this.buffer.push({
      cmd: cmd,
      args: args
    });
  };

  DexdisTransaction.prototype.exec = function(cb) {
    var buffer, cmds, i, next, trans, values;
    trans = this._transaction(cb);
    cmds = new DexdisCommands(trans);
    buffer = this.buffer;
    i = 0;
    values = [];
    next = function(val) {
      var b;
      if (val !== void 0) {
        values.push(val);
      }
      i++;
      if (i > buffer.length) {
        return;
      }
      b = buffer[i - 1];
      return cmds[b.cmd].apply(cmds, b.args.concat([next]));
    };
    trans.oncomplete = function() {
      return cb(null, values);
    };
    trans.onerror = function(e) {
      cb(e);
      return e.preventDefault();
    };
    next();
  };

  DexdisTransaction.prototype.discard = function(cb) {
    this.buffer = [];
    return this.trans.abort();
  };

  _ref1 = DexdisCommands.cmds;
  _fn = function(cmd) {
    return DexdisTransaction.prototype[cmd] = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this._buffercmd(cmd, args);
      return this;
    };
  };
  for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
    cmd = _ref1[_i];
    _fn(cmd);
  }

  return DexdisTransaction;

}).call(this, DexdisDb);

/*
//@ sourceMappingURL=dexdis.js.map
*/
    return Dexdis;
}));
