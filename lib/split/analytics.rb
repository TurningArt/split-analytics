require "split/helper"

module Split
  module Analytics
    def tracking_code(options={})
      # needs more options: http://code.google.com/apis/analytics/docs/gaJS/gaJSApi.html
      account = options.delete(:account)
      custom_variable_start_index = options.delete(:start_index)

      code = <<-EOF
        <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{account}']);
          #{custom_variables(custom_variable_start_index)}
          _gaq.push(['_trackPageview']);
          _gaq.push(['_trackPageLoadTime']);

          (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
        </script>
      EOF
      code = raw(code)if defined?(raw)
      code
    end

    def custom_variables(start_index = nil)
      return nil if session[:split].nil?
      arr = []
      session[:split].each_with_index do |h,i|
        arr << "_gaq.push(['_setCustomVar', #{i+(start_index || 1)}, '#{h[0]}', '#{h[1]}', 1]);"
      end
      arr.reverse[0..4].reverse.join("\n")
    end
  end
end

module Split::Helper
  include Split::Analytics
end

if defined?(Rails)
  class ActionController::Base
    ActionController::Base.send :include, Split::Analytics
    ActionController::Base.helper Split::Analytics
  end
end
