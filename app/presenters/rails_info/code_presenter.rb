class RailsInfo::CodePresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    @code = options[:text]
    @line_number = options[:number]
    @line_numbers = options[:line_numbers]
    @highlighted_line_numbers = options[:highlighted_line_numbers] || []
    @highlighted_line_numbers = @highlighted_line_numbers.is_a?(Array) ? @highlighted_line_numbers : [@highlighted_line_numbers]
    @highlighted_number_name = options[:highlighted_number_name]
  end
  
  def table
    outer_html = ''
    
    unless @line_numbers.include?(@line_number)
      outer_html = content_tag(:p) do 
        content_tag :strong do 
          raw(
            "Line number #{@line_number.inspect} is either an empty line or not included (anymore).<br/>" +
            "So highlighting the nearest line."
          )
        end
      end
    end
    
    outer_html + content_tag(:table, cellspacing: 0, cellpadding: 0) do
      html, visible_line_number = '', 1
      
      @line_numbers.each do |line_number|
        html += content_tag :tr do
          tr_html = ''
          
          if @highlighted_line_numbers.include?(visible_line_number)
            #line_number_link = link_to line_number.to_s, "#top", name: @highlighted_number_name.parameterize
            tr_html = content_tag :td, line_number, class: 'hll'
          else
            tr_html = content_tag :td, line_number
          end
          
          if line_number == @line_numbers.first
            options = @highlighted_line_numbers ? {hl_lines: @highlighted_line_numbers } : {}
            
            # 1) This Ruby wrapped Python code can cause Ruby segmentation faults. 
            #    If you can abandon syntax highlighting deactivate 1) and use 2) instead
            code = ::Pygments.highlight(@code, lexer: 'ruby', options: options) rescue @code.gsub(/\n/, '<br/>').gsub(' ', '&nbsp;')

            # 2) 
            # code = @code.gsub(/\n/, '<br/>').gsub(' ', '&nbsp;')

            tr_html += content_tag :td, raw(code), rowspan: @line_numbers.length
          end
          
          raw tr_html
        end  
        
        visible_line_number += 1
      end  
      
      raw html
    end
  end
end