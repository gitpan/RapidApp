
// --------
// http://www.sencha.com/forum/showthread.php?33475-Tip-Long-menu-overflow/page2
Ext.override(Ext.menu.Menu, {
    // See http://extjs.com/forum/showthread.php?t=33475&page=2
    showAt : function(xy, parentMenu, /* private: */_e) {
        this.parentMenu = parentMenu;
        if (!this.el) {
            this.render();
        }
        if (_e !== false) {
            this.fireEvent("beforeshow", this);
            xy = this.el.adjustForConstraints(xy);
        }
        this.el.setXY(xy);

        // Start of extra logic to what is in Ext source code...
        // See http://www.extjs.com/deploy/ext/docs/output/Menu.jss.html
        // get max height from body height minus y cordinate from this.el
        var maxHeight = this.maxHeight || Ext.getBody().getHeight() - xy[1];
        if (this.el.getHeight() > maxHeight) {
            // set element with max height and apply vertical scrollbar
            this.el.setHeight(maxHeight);
            this.el.applyStyles('overflow-y: auto;');
        }
        // .. end of extra logic to what is in Ext source code

        this.el.show();
        this.hidden = false;
        this.focus();
        this.fireEvent("show", this);
    },
	 
	// Added 2012-04-02 by HV: further turn off the default tiny menu scroller functions:
	enableScrolling: false
	 
});
// --------


// Mouse-over/hover fix:
// http://www.sencha.com/forum/showthread.php?69090-Ext.ux.form.SuperBoxSelect-as-seen-on-facebook-and-hotmail&p=515731#post515731
Ext.override(Ext.ux.form.SuperBoxSelectItem, {
	enableElListeners : function() {
		this.el.on('click', this.onElClick, this, {stopEvent:true});
		//this.el.addClassOnOver('x-superboxselect-item x-superboxselect-item-hover');
		this.el.addClassOnOver('x-superboxselect-item-hover');
	}
});


// Override to get rid of the input cursor if editable is false
Ext.override(Ext.ux.form.SuperBoxSelect,{
	initComponent_orig: Ext.ux.form.SuperBoxSelect.prototype.initComponent,
	initComponent: function () {
		this.initComponent_orig.apply(this,arguments);
		this.on('afterrender',function(combo) {
			if(combo.editable === false && combo.hideInput === true) {
				combo.inputEl.removeClass("x-superboxselect-input");
				combo.inputEl.setVisible(false);
			}
		});
	}
});

Ext.override(Ext.BoxComponent, {
	initComponent: function() {


		// All-purpose override allowing eval code in config
		var thisB = this;
		if (thisB.afterRender_eval) { this.on('afterrender', function() { eval(thisB.afterRender_eval); }) }
		var config = this;
		if (this.init_evalOverrides) {
			for ( var i in this.init_evalOverrides ) {
				config[i] = eval(this.init_evalOverrides[i]);
			}
			Ext.apply(this, Ext.apply(this.initialConfig, config));
		}
		Ext.BoxComponent.superclass.initComponent.apply(this, arguments);
	}
	//,afterRender: function() {
		//this.superclass.afterRender.call(this);
	//	if (this.afterRender_eval) { eval(this.afterRender_eval); }

	//}
});



Ext.override(Ext.Container, {
	onRender: function() {
		Ext.Container.superclass.onRender.apply(this, arguments);
		
		if (this.onRender_eval) { eval(this.onRender_eval); }

		var thisC = this;

		if (this.ajaxitems && Ext.isArray(this.ajaxitems)) {

			for (i in this.ajaxitems) {
				if (this.ajaxitems[i]['url']) {

					alert(this.ajaxitems[i]['url']);

					Ext.Ajax.request({
						disableCaching: true,
						url: this.ajaxitems[i]['url'],
						params: this.ajaxitems[i]['params'],
						success: function(response, opts) {
							var imported_data = eval('(' + response.responseText + ')');
							thisC.add(new Ext.Container(imported_data));
							thisC.doLayout();
						},
						failure: function(response, opts) {
							alert('AJAX ajaxitems FAILED!!!!!!');
						}
					});
				}
			}
		}
	}
});




Ext.override(Ext.ux.grid.GridFilters, {

	initOrig: Ext.ux.grid.GridFilters.prototype.init,

	init: function(grid) {
		this.initOrig.apply(this, arguments);

		if (this.init_state) {

			for (i in this.init_state.filters) {
				for (p in this.init_state.filters[i]) {
					var orig = this.init_state.filters[i][p];
					if (p == 'before' || p == 'after' || p == 'on') {
						this.init_state.filters[i][p] = Date.parseDate(orig,"Y-m-d\\TH:i:s");
					}
				}
			}

			this.applyState(grid,this.init_state);
			grid.applyState(this.init_state);
			//console.dir(this.init_state);
		}
	},

	getState: function () {
		var filters = {};
		this.filters.each(function (filter) {
			if (filter.active) {
				filters[filter.dataIndex] = filter.getValue();
			}
		});
		return filters;
	}
});



// Tweaks to Saki's "CheckTree" (http://checktree.extjs.eu/) -- 2010-03-27 by HV
Ext.override(Ext.ux.tree.CheckTreePanel, {
	// This is required in order to get initial checked state:
	afterRender:function() {
		Ext.ux.tree.CheckTreePanel.superclass.afterRender.apply(this, arguments);
		this.updateHidden();
	 },

	 // This adds unchecked items to the posted list... Unchecked start with '-', checked start with '+'
	 getValue:function() {
		var a = [];
		this.root.cascade(function(n) {
			if(true === n.attributes.checked) {
				if(false === this.deepestOnly || !this.isChildChecked(n)) {
					a.push('+' + n.id);
				}
			}
			else {
				a.push('-' + n.id);
			}
		}, this);
		a.shift(); // Remove root element
		return a;
	}
});


/* Override to force it to not display the checkbox if "checkbox" is null */
Ext.override(Ext.ux.tree.CheckTreeNodeUI, {

	renderElements:function(n, a, targetNode, bulkRender){

		/* This override was required to support NO checkbox */
		var checkbox_class = 'x-tree-checkbox';
		if (n.attributes.checked == null) { checkbox_class = 'x-tree-checkbox-no-checkbox'; }
		/* ------------------------------------------------- */

		this.indentMarkup = n.parentNode ? n.parentNode.ui.getChildIndent() :'';
		var checked = n.attributes.checked;
		var href = a.href ? a.href : Ext.isGecko ? "" :"#";
		  var buf = [
			 '<li class="x-tree-node"><div ext:tree-node-id="',n.id,'" class="x-tree-node-el x-tree-node-leaf x-unselectable ', a.cls,'" unselectable="on">'
			,'<span class="x-tree-node-indent">',this.indentMarkup,"</span>"
			,'<img src="', this.emptyIcon, '" class="x-tree-ec-icon x-tree-elbow" />'
			,'<img src="', a.icon || this.emptyIcon, '" class="x-tree-node-icon',(a.icon ? " x-tree-node-inline-icon" :""),(a.iconCls ? " "+a.iconCls :""),'" unselectable="on" />'
			,'<img src="'+this.emptyIcon+'" class="' + checkbox_class +(true === checked ? ' x-tree-node-checked' :'')+'" />'
			,'<a hidefocus="on" class="x-tree-node-anchor" href="',href,'" tabIndex="1" '
			,a.hrefTarget ? ' target="'+a.hrefTarget+'"' :"", '><span unselectable="on">',n.text,"</span></a></div>"
			,'<ul class="x-tree-node-ct" style="display:none;"></ul>'
			,"</li>"
		].join('');
		var nel;
		if(bulkRender !== true && n.nextSibling && (nel = n.nextSibling.ui.getEl())){
			this.wrap = Ext.DomHelper.insertHtml("beforeBegin", nel, buf);
		}else{
			this.wrap = Ext.DomHelper.insertHtml("beforeEnd", targetNode, buf);
		}
		this.elNode = this.wrap.childNodes[0];
		this.ctNode = this.wrap.childNodes[1];
		var cs = this.elNode.childNodes;
		this.indentNode = cs[0];
		this.ecNode = cs[1];
		this.iconNode = cs[2];
		this.checkbox = cs[3];
		this.cbEl = Ext.get(this.checkbox);
		this.anchor = cs[4];
		this.textNode = cs[4].firstChild;
	} // eo function renderElements
});




/*
Ext.override(Ext.chart.LineChart, {
	initComponent: function() {
		var config = this;
		if (this.xAxis && this.xAxis['xtype']) {
			if(this.xAxis['xtype'] == 'categoryaxis') { config['xAxis'] = new Ext.chart.CategoryAxis(this.xAxis); }
			if(this.xAxis['xtype'] == 'numericaxis') { config['xAxis'] = new Ext.chart.NumericAxis(this.xAxis); }
		}
		if (this.yAxis && this.yAxis['xtype']) {
			if(this.yAxis['xtype'] == 'categoryaxis') { config['yAxis'] = new Ext.chart.CategoryAxis(this.yAxis); }
			if(this.yAxis['xtype'] == 'numericaxis') { config['yAxis'] = new Ext.chart.NumericAxis(this.yAxis); }
		}
		Ext.apply(this, Ext.apply(this.initialConfig, config));
		Ext.chart.LineChart.superclass.initComponent.apply(this, arguments);
	}
});
*/


var pxMatch = /(\d+(?:\.\d+)?)px/;
Ext.override(Ext.Element, {
		  getViewSize : function(contentBox){
				var doc = document,
					 me = this,
					 d = me.dom,
					 extdom = Ext.lib.Dom,
					 isDoc = (d == doc || d == doc.body),
					 isBB, w, h, tbBorder = 0, lrBorder = 0,
					 tbPadding = 0, lrPadding = 0;
				if (isDoc) {
					 return { width: extdom.getViewWidth(), height: extdom.getViewHeight() };
				}
				isBB = me.isBorderBox();
				tbBorder = me.getBorderWidth('tb');
				lrBorder = me.getBorderWidth('lr');
				tbPadding = me.getPadding('tb');
				lrPadding = me.getPadding('lr');

				// Width calcs
				// Try the style first, then clientWidth, then offsetWidth
				if (w = me.getStyle('width').match(pxMatch)){
					 if ((w = Math.round(w[1])) && isBB){
						  // Style includes the padding and border if isBB
						  w -= (lrBorder + lrPadding);
					 }
					 if (!contentBox){
						  w += lrPadding;
					 }
					 // Minimize with clientWidth if present
					 d.clientWidth && (d.clientWidth < w) && (w = d.clientWidth);
				} else {
					 if (!(w = d.clientWidth) && (w = d.offsetWidth)){
						  w -= lrBorder;
					 }
					 if (w && contentBox){
						  w -= lrPadding;
					 }
				}

				// Height calcs
				// Try the style first, then clientHeight, then offsetHeight
				if (h = me.getStyle('height').match(pxMatch)){
					 if ((h = Math.round(h[1])) && isBB){
						  // Style includes the padding and border if isBB
						  h -= (tbBorder + tbPadding);
					 }
					 if (!contentBox){
						  h += tbPadding;
					 }
					 // Minimize with clientHeight if present
					 d.clientHeight && (d.clientHeight < h) && (h = d.clientHeight);
				} else {
					 if (!(h = d.clientHeight) && (h = d.offsetHeight)){
						  h -= tbBorder;
					 }
					 if (h && contentBox){
						  h -= tbPadding;
					 }
				}

				return {
					 width : w,
					 height : h
				};
		  }
});

Ext.override(Ext.layout.ColumnLayout, {
	 onLayout : function(ct, target, targetSize){
		  var cs = ct.items.items, len = cs.length, c, i;

		  if(!this.innerCt){
				// the innerCt prevents wrapping and shuffling while
				// the container is resizing
				this.innerCt = target.createChild({cls:'x-column-inner'});
				this.innerCt.createChild({cls:'x-clear'});
		  }
		  this.renderAll(ct, this.innerCt);

		  var size = targetSize || target.getViewSize(true);

		  if(size.width < 1 && size.height < 1){ // display none?
				return;
		  }

		  var w = size.width - this.scrollOffset,
				h = size.height,
				pw = w;

		  this.innerCt.setWidth(w);

		  // some columns can be percentages while others are fixed
		  // so we need to make 2 passes

		  for(i = 0; i < len; i++){
				c = cs[i];
				if(!c.columnWidth){
					 pw -= (c.getSize().width + c.getPositionEl().getMargins('lr'));
				}
		  }

		  pw = pw < 0 ? 0 : pw;

		  for(i = 0; i < len; i++){
				c = cs[i];
				if(c.columnWidth){
					 c.setSize(Math.floor(c.columnWidth * pw) - c.getPositionEl().getMargins('lr'));
				}
		  }
		  // Do a second pass if the layout resulted in a vertical scrollbar (changing the available width)
		  if (!targetSize && ((size = target.getViewSize(true)).width != w)) {
				this.onLayout(ct, target, size);
		  }
	 }
});

/* http://www.sencha.com/forum/showthread.php?95486-Cursor-Position-in-TextField&p=609639&viewfull=1#post609639 */
Ext.override(Ext.form.Field, {

    setCursorPosition: function(pos) {
       var el = this.getEl().dom;
		 if(!el) { return; } // <-- rare cases this is undef and throws error
       if (el.createTextRange) {
          var range = el.createTextRange();
          range.move("character", pos);
          range.select();
       } else if(typeof el.selectionStart == "number" ) { 
          el.focus(); 
          el.setSelectionRange(pos, pos); 
       } else {
         //alert('Method not supported');
         return;
       }
    },

    getCursorPosition: function() {
       var el = this.getEl().dom;
       var rng, ii=-1;
       if (typeof el.selectionStart=="number") {
          ii=el.selectionStart;
       } else if (document.selection && el.createTextRange){
          rng=document.selection.createRange();
          rng.collapse(true);
          rng.moveStart("character", -el.value.length);
          ii=rng.text.length;
       }
       return ii;
    }
   
});



// We never want Windows to render larger than the browser. I can't imagine any situation
// where this would be wanted, so this is being implemented as a global override for now:
var orig_Window_initComponent = Ext.Window.prototype.initComponent;
Ext.override(Ext.Window, {
  initComponent: function() {

    var browserSize = Ext.getBody().getViewSize();
    var maxW = browserSize.width  - 10;
    var maxH = browserSize.height - 10;

    // For now, only handle the case of supplied/set height & width values:
    if(Ext.isNumber(this.height)) { this.height = this.height < maxH ? this.height : maxH; }
    if(Ext.isNumber(this.width))  { this.width  = this.width  < maxW ? this.width  : maxW; }

    return orig_Window_initComponent.call(this);
  }
});
