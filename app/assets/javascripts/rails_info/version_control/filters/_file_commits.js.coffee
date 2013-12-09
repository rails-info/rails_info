jQuery ->
  $('.file_commits input').change (event) ->
    event.preventDefault()
    
    fields = {}
    
    $.each $(this.form).serializeArray(), (index, field) ->
      fields[field.name] = field.value
      
    $.each $(this.form).find('a.diff'), (index, link) ->
      url = 'https://projects.mtvnn.com/projects/' + fields['project_slug'] + '/repository'
      
      if fields['rev'] == fields['rev_to']
        url += '/revisions/' + fields['rev'] + '/entry/' + fields['path']
      else
        #url += '/diff/' + fields['path'] + '?rev=' + fields['rev'] + '&rev_to=' + fields['rev_to']
        url = '/rails/info/version_control/diffs/new?repository_path=' + fields['repository_path'] + '&path=' + fields['path'] + '&'
        url += 'rev=' + fields['rev'] + '&rev_to=' + fields['rev_to']
        
      $(link).attr('href', url)
