class RailsInfo::System::DirectoriesController < RailsInfoController
  respond_to :json
  
  def index
    commands = []
    
    commands << "cd #{params[:parent_directory]}"  if params[:parent_directory].present?
    commands << "ls -d */"
    
    respond_with IO.popen(commands.join(' && ')).readlines.map{|d| d.strip.gsub('/', '')}
  end
end