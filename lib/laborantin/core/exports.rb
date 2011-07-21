

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

      def plots
        hash = exports
        hash.keys.select{|k| hash[k] =~ /^image/}
      end

    end
  end
end
