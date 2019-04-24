require 'active_support/core_ext/hash/conversions'
Dir['../lib/readers/*.rb'].each {|file| require_relative file}
Dir['../lib/sorters/*.rb'].each {|file| require_relative file}
Dir['../lib/parsers/*.rb'].each {|file| require_relative file}
Dir['../lib/converters/*.rb'].each {|file| require_relative file}



module Main
  Readers = Dir.children("../lib/readers").map { |reader| File.basename(reader, ".rb").classify.constantize }
  Sorters = Dir.children("../lib/sorters").map { |sorter| File.basename(sorter, ".rb").classify.constantize }
  Parsers = Dir.children("../lib/parsers").map { |parser| File.basename(parser, ".rb").classify.constantize }
  Converters = Dir.children("../lib/converters").map { |converter| File.basename(converter, ".*").classify.constantize }
  def self.program_scenario(options, path)
    begin
      reader = Readers.find{ |reader| reader.can_read?(path) }
      doc = reader.read(path)
    rescue NoMethodError
      puts 'Сorresponding reader is not find'
      exit
    end

    begin
      parser = Parsers.find{ |parser| parser.can_parse?(doc) }
      ceil_parser = parser.new
      content = ceil_parser.parse(doc)
    rescue  NoMethodError
      puts 'Сorresponding parser is not find'
      exit
    end

    # sort_types = options.select{ |key, value| value.eql?(true) }.keys

    options[:content].each_key do |sort, value|
      Sorters.each do |operator|
        operator.applicable?(sort) ? content = operator.sort_data(content) : next
      end
    end

    converter = Converters.find{ |converter| converter.applicable?(options) }
    converted_data = converter.convert(content)

    File.open('../output_files/output_file.xml', 'w') { |file| file.write(converted_data) }
  end
end