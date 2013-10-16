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

storenames = ['keys', 'simple', 'hash'];

storenames = ['keys', 'simple', 'hash'];

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
    var del, range, stores;
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
        _results.push(db.createObjectStore(store));
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
