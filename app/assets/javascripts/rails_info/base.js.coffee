$(document).ready ->
  $( ".accordions" ).each (k, v) ->
    $(v).accordion({ autoHeight: false })
    
  $(".tabs").each (k, v) ->
    $(v).tabs({ autoHeight: false })
    
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()