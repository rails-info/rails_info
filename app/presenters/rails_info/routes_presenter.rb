class RailsInfo::RoutesPresenter < ::RailsInfo::Presenter
  def accordion
    routes = request.env['action_dispatch.routes'].routes.map do |route|
      {
        source: (route.verb.respond_to?(:source) ? route.verb.source : route.verb).gsub(/[$^]/, ''),
        spec: route.path.respond_to?(:spec) ? route.path.spec.to_s : route.path,
        name: route.name,
        requirements: route.requirements.inspect
      }
    end
    
    namespaced_routes = {}
    
    routes.each do |route|
      namespace = '/'
      
      unless route[:spec] == namespace
        spec = route[:spec].split('/')
        spec.shift
        namespace = spec.shift
      end
      
      namespaced_routes[namespace] ||= []
      namespaced_routes[namespace] << route 
    end
    
    content_tag :div, class: 'accordions' do
      html = ''
      
      namespaced_routes.each do |namespace, routes|
        html += content_tag(
          :h3, raw("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#{namespace}")
        )
        table = render partial: 'rails_info/routes/table', locals: { routes: routes }
        html += content_tag :div, raw(table), style: "max-height:300px; overflow: auto"
      end  
      
      raw html
    end  
  end  
end