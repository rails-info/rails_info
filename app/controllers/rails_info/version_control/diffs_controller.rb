class RailsInfo::VersionControl::DiffsController < RailsInfoController
  def new
    repository = Grit::Repo.new(params[:repository_path])

    diff = repository.diff(
      repository.commit(params[:rev_to]), repository.commit(params[:rev]), params[:path]
    )
    
    unless diff.length == 1
      raise NotImplementedError.new("Diff length != 1 but #{diff.length}")
    end
    
    render text: DiffToHtml::GitConverter.new.get_single_file_diff_body(diff.first.diff)
  rescue Exception => e
    if Rails.env.development?
      raise e.class.name + ': ' + e.message + ' ... ' + e.backtrace.join("\n")
    else
      logger.error e.class.name + ': ' + e.message + ' ... ' + e.backtrace.join("\n")
      render text: 'Internal server error.'
    end
  end
end