var listAllTheThings = {

    init: function (regionId, a) {
        apex.debug("listAllTheThings.init", a.attr1, a.attr2);

        apex.jQuery("#"+regionId).bind("apexrefresh",function(){
            listAllTheThings.refresh(regionId, a);
        });

    },
    
    refresh: function (regionId, a) {
        apex.debug("listAllTheThings.refresh", a.attr1, a.attr2);

        apex.server.plugin
          (a.ajaxIdentifier
          ,{ pageItems: a.ajaxItems }
          ,{ dataType: "json"
            ,success: function( pData ) {
              apex.debug("success names="+pData.names);

              $("#"+regionId+"_myregion").html(pData.names);

              apex.jQuery("#"+regionId).trigger("apexafterrefresh");
            }
          } );


    }
};