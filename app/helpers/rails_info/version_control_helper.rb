module RailsInfo
  module VersionControlHelper
    # replaces / and . by underscore
    def version_control_path_id(path)
      path.gsub(/\/|\./, '_')
    end
    
    def version_control_diff_link(path, rev)
      rev = params['rev'] || rev
      rev_to = params['rev_to'] || @filter.previous_revision_by_file[path]
      
      #url = 'https://projects.mtvnn.com/projects/' + @filter.project_slug + '/repository'
      
      url = if rev == rev_to 
        'https://projects.mtvnn.com/projects/' + @filter.project_slug + '/repository/revisions/' + rev + '/entry/' + path
      else 
        #'/diff/' + path + '?rev=' + rev + '&rev_to=' + rev_to
        "/rails/info/version_control/diffs/new?repository_path=#{@filter.repository_path}&path=#{path}&rev=#{rev}&rev_to=#{rev_to}"
      end
      
      link_to 'Diff', url, class: 'modal_link diff', target: '_blank'
    end
    
    def version_control_file_revision_link(text, rev, path, options = {})
      method = options[:method] ? options[:method] : 'entry'
      
      url = 'https://projects.mtvnn.com/projects/' + @filter.project_slug + '/repository'
      url += '/revisions/' + rev + '/' + method + '/' + path
      
      link_to text, url, target: '_blank'
    end
  end
end