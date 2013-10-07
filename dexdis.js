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
var Dexdis, DexdisCommands, DexdisDb, DexdisTransaction, errs, _ref,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

errs = {
  transaction: 'Operation not allowed during transaction',
  wrongtype: 'Operation against a key holding the wrong kind of value',
  notsupported: 'Operation not supported',
  toomuchop: 'Operation with too much operands'
};

DexdisCommands = (function() {
  var hamming;

  function DexdisCommands(trans) {
    var s, stores, _i, _len;
    stores = ['keys', 'values'];
    this._stores = {};
    for (_i = 0, _len = stores.length; _i < _len; _i++) {
      s = stores[_i];
      this._stores[s] = trans.objectStore(s);
    }
  }

  DexdisCommands.prototype._checkttl = function(key, cb) {
    var get, keys, values, _ref;
    _ref = this._stores, keys = _ref.keys, values = _ref.values;
    get = keys.get(key);
    get.onsuccess = function() {
      var del, keyinfo;
      keyinfo = get.result;
      if ((keyinfo != null ? keyinfo.expire : void 0) != null) {
        if (Date.now() > keyinfo.expire) {
          del = keys["delete"](key);
          del.onsuccess = function() {
            return cb(void 0, true);
          };
          return values["delete"](key);
        } else {
          return cb(keyinfo, false);
        }
      } else {
        return cb(keyinfo, false);
      }
    };
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
    return this.get(key, function(val) {
      var type;
      if (val != null) {
        type = typeof val;
        if (type !== 'string') {
          if (type === 'number') {
            val = '' + val;
          } else {
            throw new Error(errs.wrongtype);
          }
        }
      } else {
        val = '';
      }
      return cb(val);
    });
  };

  DexdisCommands.prototype._map = function(key, cb, f) {
    var keys, value, values, _ref,
      _this = this;
    _ref = this._stores, keys = _ref.keys, values = _ref.values;
    value = null;
    this._checkttl(key, function(keyinfo) {
      var get;
      if (keyinfo != null) {
        if (keyinfo.type === 'simple') {
          get = values.get(key);
          return get.onsuccess = function() {
            var put;
            value = f(get.result);
            put = values.put(value, key);
            return put.onsuccess = function() {
              return cb(value);
            };
          };
        } else {
          return cb(new Error(errs.wrongtype));
        }
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
          throw new Error(errs.toomuchop);
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
      throw new Error(errs.notsupported);
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
    var cb, count, dels, i, k, keys, values, _i, _j, _len, _ref, _results;
    dels = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
    _ref = this._stores, keys = _ref.keys, values = _ref.values;
    if (dels.length === 0) {
      cb(0);
      return;
    }
    count = 0;
    _results = [];
    for (i = _j = 0, _len = dels.length; _j < _len; i = ++_j) {
      k = dels[i];
      _results.push(this._checkttl(k, function(keyinfo) {
        var del;
        if (keyinfo != null) {
          count++;
          keys["delete"](k);
          del = values["delete"](k);
          if (i === dels.length) {
            return del.onsuccess = function() {
              return cb(count);
            };
          }
        }
      }));
    }
    return _results;
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
    var keys, values, _ref;
    _ref = this._stores, keys = _ref.keys, values = _ref.values;
    keys.clear();
    values.clear();
    cb('OK');
  };

  DexdisCommands.prototype.get = function(key, cb) {
    var keys, values, _ref;
    _ref = this._stores, keys = _ref.keys, values = _ref.values;
    this._checkttl(key, function(keyinfo) {
      var get;
      if (keyinfo === void 0) {
        return cb(null);
      } else if (keyinfo.type !== 'simple') {
        throw new Error(errs.wrongtype);
      } else {
        get = values.get(key);
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
    var keyinfo, keys, put, values, _ref;
    _ref = this._stores, keys = _ref.keys, values = _ref.values;
    keyinfo = {
      type: 'simple'
    };
    keys.put(keyinfo, key);
    put = values.put(value, key);
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
    this._checkttl(key, function(keyinfo) {
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
    trans = this.db.transaction(['keys', 'values'], mode);
    trans.onerror = function(e) {
      if (cb != null) {
        return cb(e);
      }
    };
    trans.onabort = function(e) {
      if (cb != null) {
        return cb(new Error('Transaction Aborted'));
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
    var cmds, ret, save, trans;
    ret = null;
    save = function(x) {
      ret = x;
    };
    trans = this._transaction(cb, mode);
    trans.oncomplete = function() {
      if (cb != null) {
        return cb(null, ret);
      }
    };
    cmds = new DexdisCommands(trans);
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
      db = r.result;
      db.createObjectStore('keys');
      return db.createObjectStore('values');
    };
    r.onsuccess = function(e) {
      _this.db = r.result;
      if (cb != null) {
        return cb(null);
      }
    };
    r.onerror = function(e) {
      return cb(r.error);
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
      return cb(e);
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

    return Dexdis;
}));
