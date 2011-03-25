require 'pasteboard'
require 'pp'

pb = Pasteboard.new

pb.each.with_index do |item, index|
  puts "item #{index}"
  item.map do |flavor, data|
    puts "flavor: #{flavor}"
    puts "encoding: #{data.encoding} valid: #{data.valid_encoding?}" if
      defined?(Encoding)
    puts "data: #{data.inspect[0, 70]}"
    puts
  end
  puts
end
