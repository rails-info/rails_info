class RailsInfo::VersionControl::FiltersController < RailsInfoController
  before_filter :build_resource, only: ['new', 'create']
  
  def new
  end

  def create
    render 'new'
  end
  
  private
  
  def build_resource
    params['filter'] ||= {}
    
    @filter = ::VersionControl::Filter.create(params['filter'].merge(logger: logger))
  end
end