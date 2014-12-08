var MetaElement;

MetaElement = (function() {
  function MetaElement(ctx, el) {
    this.ctx = ctx;
    this._extractMeta(el);
    this._denormalizeRepeat();
    this._attachDirectives();
  }

  MetaElement.prototype._extractMeta = function(el) {
    var nodes, _ref;
    if (el.tagName) {
      this.tag = el.tagName.toLowerCase();
      this.attrs = this._extractAttributes(el);
      nodes = this._extractChildrens(el);
      if (nodes.length > 0) {
        return this.nodes = nodes;
      }
    } else {
      this.text = true;
      if (((_ref = el.data) != null ? _ref.trim().length : void 0) > 0) {
        this.data = el.data;
      }
      if (this.data && this.data.match(/{{.+}}/) !== null) {
        return this.interpolate = this._splitInterpolated(this.data);
      }
    }
  };

  MetaElement.prototype._extractChildrens = function(parent) {
    var el, meta, nodes, _i, _len, _ref;
    nodes = [];
    _ref = parent.childNodes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      el = _ref[_i];
      meta = new MetaElement(this.ctx, el);
      if (meta._isValid()) {
        nodes.push(meta);
      }
    }
    return nodes;
  };

  MetaElement.prototype._extractAttributes = function(el) {
    var attrs, i, key, length, value, _i;
    attrs = {};
    if (!(el.attributes && el.attributes.length > 0)) {
      return attrs;
    }
    length = el.attributes.length - 1;
    for (i = _i = 0; 0 <= length ? _i <= length : _i >= length; i = 0 <= length ? ++_i : --_i) {
      key = el.attributes[i].name;
      value = el.attributes[i].value;
      if (key === "class") {
        key = "className";
      }
      attrs[key] = value;
    }
    return attrs;
  };

  MetaElement.prototype._splitInterpolated = function(content) {
    var childs, lastPos;
    childs = [];
    lastPos = 0;
    content.replace(/{{([\s\w\d\[\]_\(\)\.\$"']+)}}/g, (function(_this) {
      return function(match, capture, pos) {
        if (pos > lastPos) {
          childs.push({
            t: "text",
            v: content.substr(lastPos, pos - lastPos)
          });
        }
        lastPos = pos + match.length;
        return childs.push({
          t: "exp",
          v: capture
        });
      };
    })(this));
    if (lastPos < content.length) {
      childs.push({
        t: "text",
        v: content.substr(lastPos, content.length - lastPos)
      });
    }
    return childs;
  };

  MetaElement.prototype._isValid = function() {
    return this.tag || this.data;
  };

  MetaElement.prototype.prepareIgnition = function(ctx) {
    var d, _i, _len, _ref, _results;
    if (this.directives != null) {
      _ref = this.directives;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        d = _ref[_i];
        d.instance = new d.clazz();
        if (d.instance.build != null) {
          _results.push(d.instance.build(ctx, this));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }
  };

  MetaElement.prototype._attachDirectives = function() {
    var key, mountedCallback, renderCallback, value, _ref;
    if (!this.attrs) {
      return;
    }
    _ref = this.attrs;
    for (key in _ref) {
      value = _ref[key];
      if (this.ctx.app.directives[key] != null) {
        this.directives || (this.directives = []);
        this.directives.push({
          clazz: this.ctx.app.directives[key]
        });
      }
    }
    if (this.directives == null) {
      return;
    }
    renderCallback = function() {
      return ReactFactory.buildElement(this.props.meta, this.props.ctx);
    };
    mountedCallback = function() {
      var d, _i, _len, _ref1, _ref2, _results;
      _ref1 = this.props.meta.directives;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        d = _ref1[_i];
        if ((_ref2 = d.instance) != null ? _ref2.link : void 0) {
          _results.push(d.instance.link(this.props.ctx, this.getDOMNode(), this.props.meta));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    return this.reactClass = React.createClass({
      componentDidMount: mountedCallback,
      render: renderCallback
    });
  };

  MetaElement.prototype._denormalizeRepeat = function() {
    var collectionExpression, exp, exp_1, exp_2, _ref;
    if (!((_ref = this.attrs) != null ? _ref.repeat : void 0)) {
      return;
    }
    exp = this.attrs.repeat.match(/([\w\d_\$]+)\s?,?\s?([\w\d_\$]+)?\s+in\s+([\s\w\d\[\]_\(\)\.\$"']+)/);
    if (!exp) {
      return;
    }
    exp_1 = exp[1];
    exp_2 = exp[2];
    collectionExpression = exp[3];
    this.repeat = true;
    this.repeatExp = {
      src: collectionExpression
    };
    if (exp_2) {
      this.repeatExp.key = exp_1;
      return this.repeatExp.value = exp_2;
    } else {
      return this.repeatExp.value = exp_1;
    }
  };

  return MetaElement;

})();

var ReactFactory;

ReactFactory = {
  buildClass: function(meta, ctx) {
    return React.createClass({
      render: function() {
        return ReactFactory.buildElement(meta, ctx);
      }
    });
  },
  buildNodes: function(nodes, ctx) {
    var meta, r, _i, _len;
    r = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      meta = nodes[_i];
      r.push(this.buildElement(meta, ctx));
    }
    return r;
  },
  buildElement: function(meta, ctx) {
    var content, metaDup;
    if (meta.text) {
      return this.buildTextElement(meta, ctx);
    }
    meta.prepareIgnition(ctx);
    if (meta.attrs.hide) {
      return null;
    }
    if (meta.reactClass) {
      metaDup = Object.create(meta);
      metaDup.reactClass = false;
      return React.createElement(meta.reactClass, {
        meta: metaDup,
        ctx: ctx
      });
    }
    if (meta.repeat) {
      content = this._buildRepeatNodes(meta, ctx);
    } else if (meta.nodes != null) {
      content = this.buildNodes(meta.nodes, ctx);
    } else {
      content = meta.data;
    }
    return React.DOM[meta.tag](meta.attrs, content);
  },
  buildTextElement: function(meta, ctx) {
    var exp, nodes, _i, _len, _ref;
    if (meta.interpolate == null) {
      return meta.data;
    }
    nodes = [];
    _ref = meta.interpolate;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      exp = _ref[_i];
      if (exp.t === 'text') {
        nodes.push(exp.v);
      } else {
        nodes.push(ctx.evalAndWatch(exp.v));
      }
    }
    return nodes;
  },
  _buildRepeatNodes: function(meta, ctx) {
    var childCtx, childNodes, k, nodes, scope, src, v, _i, _len;
    nodes = [];
    src = ctx.evalAndWatch(meta.repeatExp.src);
    if (src instanceof Array) {
      for (_i = 0, _len = src.length; _i < _len; _i++) {
        v = src[_i];
        scope = {};
        scope[meta.repeatExp.value] = v;
        childCtx = ctx.child(scope);
        childNodes = Object.create(meta.nodes);
        nodes.push(this.buildNodes(childNodes, childCtx));
      }
    } else {
      for (k in src) {
        v = src[k];
        scope = {};
        scope[meta.repeatExp.value] = v;
        if (meta.repeatExp.key) {
          scope[meta.repeatExp.key] = k;
        }
        childCtx = ctx.child(scope);
        childNodes = Object.create(meta.nodes);
        nodes.push(this.buildNodes(childNodes, childCtx));
      }
    }
    return nodes;
  }
};

var UnicoApp;

UnicoApp = (function() {
  function UnicoApp() {
    this.controllers = {};
    this.directives = UnicoApp.builtInDirectives || {};
  }

  UnicoApp.prototype.addController = function(name, clazz) {
    return this.controllers[name] = clazz;
  };

  UnicoApp.prototype.addDirective = function(name, clazz) {
    return this.directives[name] = clazz;
  };

  UnicoApp.prototype.build = function() {
    var clazz, ctrl, el, name, _i, _len, _ref;
    this.instances = [];
    _ref = document.querySelectorAll("[controller]");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      el = _ref[_i];
      name = el.getAttribute('controller');
      clazz = this.controllers[name];
      ctrl = new clazz();
      this.instances.push(new UnicoInstance(this, ctrl, el));
    }
    return this;
  };

  UnicoApp.prototype.refresh = function() {
    var instance, _i, _len, _ref;
    _ref = this.instances;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      instance = _ref[_i];
      instance.changed();
    }
    return true;
  };

  return UnicoApp;

})();

var UnicoContext;

UnicoContext = (function() {
  function UnicoContext(instance, ctrl, scope) {
    this.instance = instance;
    this.ctrl = ctrl;
    this.scope = scope != null ? scope : {};
    this.app = this.instance.app;
    this._watchExpressions = {};
    this._changeListeners = [];
    this._childsScopes = [];
  }

  UnicoContext.prototype.child = function(scope, opt) {
    var childEv, key, newScope, value;
    if (opt == null) {
      opt = {};
    }
    newScope = Object.create(this.scope);
    for (key in scope) {
      value = scope[key];
      newScope[key] = value;
    }
    childEv = new UnicoContext(this.instance, this.ctrl, newScope);
    this._childsScopes.push(childEv);
    return childEv;
  };

  UnicoContext.prototype["eval"] = function(expression) {
    var cmd, error, func, p, value;
    p = this._extractParams();
    try {
      cmd = "return " + expression + ";";
      func = Function(p.keys, cmd);
      value = func.apply(this.ctrl, p.values);
      return value;
    } catch (_error) {
      error = _error;
      if (this.app.debug) {
        console.error(error.stack);
      }
      return null;
    }
  };

  UnicoContext.prototype.interpolate = function(html) {
    return html.replace(/{{([\s\w\d\[\]_\(\)\.\$"']+)}}/g, (function(_this) {
      return function(match, capture) {
        return _this["eval"](capture);
      };
    })(this));
  };

  UnicoContext.prototype._extractParams = function() {
    var ctx, k, keys, v, values, _i, _len, _ref;
    keys = [];
    values = [];
    _ref = [this.ctrl, this.scope];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ctx = _ref[_i];
      for (k in ctx) {
        v = ctx[k];
        keys.push(k);
        if (typeof v === "function") {
          values.push(this._buildFunctionProxy(k, v, this.ctrl));
        } else {
          values.push(ctx[k]);
        }
      }
    }
    return {
      keys: keys,
      values: values
    };
  };

  UnicoContext.prototype._buildFunctionProxy = function(k, v, ctrl) {
    return function() {
      return v.apply(ctrl, arguments);
    };
  };

  UnicoContext.prototype.evalAndWatch = function(exp) {
    var value, w;
    if (w = this._watchExpressions[exp]) {
      return w;
    }
    value = this["eval"](exp);
    this._watchExpressions[exp] = value;
    return value;
  };

  UnicoContext.prototype.addChangeListener = function(callback) {
    return this._changeListeners.push(callback);
  };

  UnicoContext.prototype.changed = function() {
    var c, _i, _len, _ref, _results;
    this._cleanWatched();
    _ref = this._changeListeners;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      _results.push(c());
    }
    return _results;
  };

  UnicoContext.prototype.digest = function() {
    if (this.hasChanges()) {
      return this.changed();
    }
  };

  UnicoContext.prototype.hasChanges = function() {
    var c, exp, newValue, old, _i, _len, _ref, _ref1;
    _ref = this._watchExpressions;
    for (exp in _ref) {
      old = _ref[exp];
      newValue = this["eval"](exp);
      if (newValue !== old) {
        return true;
      }
    }
    _ref1 = this._childsScopes;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      c = _ref1[_i];
      if (c.hasChanges()) {
        return true;
      }
    }
    return false;
  };

  UnicoContext.prototype._cleanWatched = function() {
    var c, _i, _len, _ref;
    _ref = this._childsScopes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      c._cleanWatched();
    }
    this._childsScopes = [];
    return this._watchExpressions = {};
  };

  return UnicoContext;

})();

var UnicoInstance;

UnicoInstance = (function() {
  function UnicoInstance(app, ctrl, el) {
    this.app = app;
    this.ctrl = ctrl;
    this.el = el;
    this.ctx = new UnicoContext(this, this.ctrl);
    this.ctx.addChangeListener((function(_this) {
      return function() {
        return _this.refresh();
      };
    })(this));
    this.metaRoot = new MetaElement(this.ctx, this.el);
    this.reactClass = ReactFactory.buildClass(this.metaRoot, this.ctx);
    this.reactElement = React.createElement(this.reactClass);
    this.reactRender = React.render(this.reactElement, this.el);
  }

  UnicoInstance.prototype.refresh = function() {
    this.reactRender.setProps();
    return true;
  };

  UnicoInstance.prototype.digest = function() {
    return this.ctx.digest();
  };

  UnicoInstance.prototype.changed = function() {
    return this.ctx.changed();
  };

  return UnicoInstance;

})();

var ClickDirective;

ClickDirective = (function() {
  function ClickDirective() {}

  ClickDirective.prototype.build = function(ctx, meta) {
    return meta.attrs['onClick'] = function() {
      var ret;
      ret = ctx["eval"](meta.attrs['click']);
      ctx.instance.digest();
      return ret;
    };
  };

  return ClickDirective;

})();

UnicoApp.builtInDirectives || (UnicoApp.builtInDirectives = {});

UnicoApp.builtInDirectives['click'] = ClickDirective;

var IfDirective;

IfDirective = (function() {
  function IfDirective() {}

  IfDirective.prototype.build = function(ctx, meta) {
    var val;
    val = ctx["eval"](meta.attrs["if"]);
    return meta.attrs.hide = !val;
  };

  return IfDirective;

})();

UnicoApp.builtInDirectives || (UnicoApp.builtInDirectives = {});

UnicoApp.builtInDirectives['if'] = IfDirective;

var ModelDirective;

ModelDirective = (function() {
  function ModelDirective() {}

  ModelDirective.prototype.build = function(ctx, meta) {
    return meta.attrs.valueLink = {
      value: ctx["eval"](meta.attrs.model),
      requestChange: function(v) {
        var exp, value;
        value = v;
        if (typeof n !== "number") {
          value = "'" + value + "'";
        }
        exp = "" + meta.attrs.model + " = " + value;
        ctx["eval"](exp);
        if (ctx["eval"](meta.attrs.model) !== v) {
          exp = "this." + meta.attrs.model + " = " + value;
          ctx["eval"](exp);
        }
        ctx.instance.changed();
        return true;
      }
    };
  };

  return ModelDirective;

})();

UnicoApp.builtInDirectives || (UnicoApp.builtInDirectives = {});

UnicoApp.builtInDirectives['model'] = ModelDirective;
