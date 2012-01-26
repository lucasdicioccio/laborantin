
require 'tilt'
module Laborantin
  module Templating
    def render(template_path, product_name, raw=true, type=:erb)
      template = case type
                 when :erb
                   Tilt::ERBTemplate.new(template_path)
                 end
      raise RuntimeError, "unkown rendering template (please contact Laborantin's author for request for addition)" unless render
      product_file(product_name, 'w', raw) { |f| f.puts template.render(self) }
    end

    def r(product_name, raw=true)
      path = product_path(product_name, raw)
      cmd = "R -f #{path}"
      log "executing `#{cmd}`"
      Dir.chdir(rundir) { %x{#{cmd}} }
    end

    def render_run(tpl, rfile, sym=:r)
      render tpl, rfile
      send sym, rfile
      export_pictures
    end
  end
end
