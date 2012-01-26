

module Laborantin
  module Metaprog
    module Exports

      def save_exports
        log "saving exports: #{exports}" if respond_to? :log
        export_file('w') do |f|
          f.puts YAML.dump(exports)
        end
      end

      def load_exports
        path = export_path
        if File.file?(path)
          YAML.load_file(path)
        end
      end

      def export_path
        raise NotImplementedError, "should override"
      end

      def export_file
        raise NotImplementedError, "should override"
      end

      def exports
        @exports ||= load_exports || {}
      end

      def export(name, mime='plain/text')
        log "#{mime}: #{name}" if respond_to? :log
        exports[name] ||= mime
      end

      def export_all(ext, mime, dir=nil)
        dir ||= rundir if respond_to? :rundir
        dir ||= output_dirpath if respond_to? :output_dirpath
        Dir.entries(rundir).select{|e| File.extname(e) == ext}.each do |file|
          export file, mime
        end
      end

      def export_pngs
        export_all '.png', 'image/png'
      end

      def export_svgs
        export_all '.svg', 'image/svg+xml'
      end

      def export_eps
        export_all '.eps', 'application/postscript'
      end

      def export_pdfs
        export_all '.pdf', 'application/pdf'
      end

      def export_pictures
        export_pngs
        export_eps
        export_svgs
        export_pdfs
      end
    end
  end
end
