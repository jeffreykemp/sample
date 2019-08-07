//Sample Region Plugin v0.1 Aug 2019

$( function() {
  $.widget( "sample.myregionplugin", {
    
    // default options
    options: {
      regionId:"",
      ajaxIdentifier:"",
      ajaxItems:"",
      pluginFilePrefix:"",
      initFn:null,
      noDataMessage:"No data to show",

      // Callbacks - these can be called via javascript in apex
      // e.g. $("#regionid_widget").myregionplugin("refresh");
      refresh: null
    },
    
    // The constructor
    _create: function() {
      apex.debug("myregionplugin._create "+this.element.prop("id"));
      apex.debug("options: "+JSON.stringify(this.options));

      // initialisation code goes here
      this.foo = 'bar';

      // bind the apexrefresh event to run the widget's refresh function
      apex.jQuery("#"+this.options.regionId).bind("apexrefresh",function(){
        $("#"+_this.options.regionId+"_widget").myregionplugin("refresh");
      });

      // run any JavaScript Initialisation code set on the region attribute
      if (this.options.initFn) {
        apex.debug("running init_javascript_code...");
        //inside the init() function we want "this" to refer to this
        this.init=this.options.initFn;
        this.init();
      }
      
      // do the initial refresh to get the data
      this.refresh();

      // trigger an event; a dynamic action can respond to this event to add custom behaviour
      // Note: other events can be triggered the same way using code like this.
      apex.jQuery("#"+this.options.regionId).trigger("loaded", {foo:this.foo});

      apex.debug("myregionplugin._create finished");
    },
    
    // Called when created, and later when changing options
    refresh: function() {
      apex.debug("myregionplugin.refresh");
      
      apex.jQuery("#"+this.options.regionId).trigger("apexbeforerefresh");

      var _this = this;

      // call the ajax PL/SQL function to pull the data
      apex.server.plugin
        (this.options.ajaxIdentifier
        ,{ pageItems: this.options.ajaxItems }
        ,{ dataType: "json"
          ,success: function( d ) {
            apex.debug("success");
            apex.jQuery("#"+_this.options.regionId).trigger("apexafterrefresh");
            
            // put the code here to render the data for display
            apex.debug("row count", d.data.count);
            
            d.data.forEach(function(e,i) {
              
              apex.debug("row #", i, "colA", e.colA, "colB", e.colB);

            } );
          }
        } );

      apex.debug("myregionplugin.refresh finished");
      // Trigger a callback/event
      this._trigger( "change" );
    },

    // Events bound via _on are removed automatically
    // revert other modifications here
    _destroy: function() {
      // remove generated elements
    },

    // _setOptions is called with a hash of all options that are changing
    // always refresh when changing options
    _setOptions: function() {
      // _super and _superApply handle keeping the right this-context
      this._superApply( arguments );
      this.refresh();
    },

    // _setOption is called for each individual option that is changing
    _setOption: function( key, value ) {
      this._super( key, value );
    }      

  });
});