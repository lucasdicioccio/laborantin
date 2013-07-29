
require 'tilt'
module Laborantin
  module Metaprog
    module Templating
      ExtensionsMapping = {'.r' => :r, '.R' => :r, '.hs' => :haskell}

      def render(template_path, product_name, raw=true, type=:erb)
        template = case type
                   when :erb
                     Tilt::ERBTemplate.new(template_path)
                   end
        raise RuntimeError, "unkown rendering template (please contact Laborantin's author for request for addition)" unless type
        product_file(product_name, 'w', raw) { |f| f.puts template.render(self) }
      end

      def r(product_name, raw=true)
        path = product_path(product_name, raw)
        cmd = "R -f #{path}"
        log "executing `#{cmd}`"
        Dir.chdir(rundir) { %x{#{cmd}} }
      end

      def haskell(product_name, raw=true)
        path = product_path(product_name, raw)
        cmd = "runhaskell #{path}"
        log "executing `#{cmd}`"
        Dir.chdir(rundir) { %x{#{cmd}} }
      end 

      def render_run(tpl, rfile, sym=nil)
        sym ||= ExtensionsMapping[File.extname(rfile)]
        raise ArgumentError, "cannot determine method for extension: #{File.extname(rfile)}" unless sym
        render tpl, rfile
        send sym, rfile
        export_pictures
      end
    end
  end
end
