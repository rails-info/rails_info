$(document).ready ->
  $( ".accordions" ).each (k, v) ->
    #$(v).accordion({ autoHeight: true })
    $(v).accordion()
    
  $(".bootstrap_accordion").accordion header: "h3", heightStyle: 'content' 
    
  $(".tabs").each (k, v) ->
    $(v).tabs({ autoHeight: true })
    $(v).attr('style', 'height: auto;') unless $('#version_control_filter').attr('id')
  
  index = 1
  
  $("#actions .tabs").each (k, v) ->
    $(v).attr('style', 'display: none;') unless index == 1 || $(v).parent().attr('class').match('ui-tabs')
    
    index += 1
  
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  
  $( '.datepicker' ).datepicker dateFormat: 'yy-mm-dd'
  
  $('#dialog').dialog
    autoOpen: false, modal: true, width: 800, height: 525
    buttons:
      Cancel: ->
        $(this).dialog 'close'
    
  $('.modal_link').click (event) ->
    event.preventDefault()
    $('.ui-dialog-title').text($(this).attr('title'))
    $('#dialog').dialog('open')
    
    target = 'dialog_body'
    
    $.ajax $(this).attr('href'),
      type: 'GET', dataType: 'html', timeout: 5000,
      success: (html) ->
        if $.type(target) is 'string' 
          $('#' + target).empty()
          $('#' + target).append html
          $('#' + target + '_spinner').hide()
          
      error: (jqXHR, textStatus, errorThrown) ->
        message = errorThrown
        message = 'Timeout of 5 seconds exceeded. Please try again.' if textStatus == 'timeout'
        message = textStatus if message == ''
        
        $('#' + target).empty()
        $('#' + target).append '<div class="alert alert-error"><button data-dismiss="alert" class="close">×</button>' + message + '</div>'
        $('#' + target + '_spinner').hide()