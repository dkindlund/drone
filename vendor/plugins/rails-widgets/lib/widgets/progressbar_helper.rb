module Widgets
  module ProgressbarHelper  
    include CssTemplate
    
    # show a progressbar
    #
    # eg: <%= progressbar 35, :generate_css => true %>
    # or  <%= progressbar [35,78,15] %>
    #
    # options
    # ===
    #   :generate_css defaults to false 
    #   :adjust       defaults to false
    #   :class        name of div class
    def progressbar values, options={}
      raise ArgumentError, "Missing value(s) parameter in progressbar call" unless values
      raise ArgumentError, "The value parameter has to be a Numeric o Array" unless values.kind_of?(Array) or values.kind_of?(Numeric)
      if values.kind_of? Numeric # single value
        total = 100 
        values = [values]
      else # Array of values
        total = values.sum
      end
      if !options.key?(:class)
        options[:class] = "progressbar"
      end

      html = ""
      html << render_css('progressbar') if options[:generate_css] == true
      html << '<div id="' + options[:class].to_s + '" class="' + options[:class].to_s + '">'          
      values.dup.each_with_index do |value, index|
        if total == 0
          percentage = 0
        else
          percentage = options[:adjust] ? (value * 100 / total) : value
        end 
        css_class = options[:class].to_s + "_color_#{index.modulo(10)}"
        html << "<div style='width: #{percentage}%;' class='#{css_class}'></div>"
      end 
      html << "</div>" 
    end
  end
end
