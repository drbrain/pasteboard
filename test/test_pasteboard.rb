# coding: utf-8

require 'minitest/unit'
require 'pasteboard'

class TestPasteboard < MiniTest::Unit::TestCase

  def setup
    @pb = Pasteboard.new nil
    @encoding = defined?(Encoding)
  end

  def test_initialize
    pb = Pasteboard.new

    assert_equal 'Apple CFPasteboard general', pb.name
  end

  def test_initialize_find
    pb = Pasteboard.new Pasteboard::FIND

    assert_equal 'Apple CFPasteboard find', pb.name
  end

  def test_initialize_nil
    pb = Pasteboard.new nil

    assert_match %r%^CFPasteboardUnique-%, pb.name
  end

  def test_clear
    util_put

    @pb.clear

    assert_equal 0, @pb.get_item_count
  end

  def test_copy_item_flavors
    util_put

    flavors = @pb.copy_item_flavors 0

    assert_equal [Pasteboard::Type::PLAIN_TEXT, Pasteboard::Type::UTF_8],
      flavors[0, 2]

    assert flavors.all? { |flavor| flavor.encoding == Encoding::UTF_8 } if
      @encoding
  end

  def test_copy_item_flavor_data
    util_put

    data = @pb.copy_item_flavor_data 0, Pasteboard::Type::PLAIN_TEXT

    assert_equal 'pi', data
    assert_equal Encoding::BINARY, data.encoding if @encoding

    data = @pb.copy_item_flavor_data 0, Pasteboard::Type::UTF_8

    assert_equal 'π', data
    assert_equal Encoding::UTF_8, data.encoding if @encoding
  end

  def test_get_item_count
    assert_equal 0, @pb.get_item_count

    util_put

    assert_equal 1, @pb.get_item_count
  end

  def test_get_item_identifier
    util_put

    id = @pb.get_item_identifier 1

    assert_equal 0, id
  end

  def test_name
    assert_match %r%CFPasteboardUnique%, @pb.name
  end

  def test_put_item_flavor
    @pb.clear

    @pb.put_item_flavor 5, 'flavor', 'data'

    assert_equal 1, @pb.get_item_count
    assert_equal 5, @pb.get_item_identifier(1)
    assert_equal %w[flavor], @pb.copy_item_flavors(5)

    data = @pb.copy_item_flavor_data 5, 'flavor'
    assert_equal 'data', data
    assert_equal Encoding::BINARY, data.encoding if @encoding
  end

  def test_sync
    assert_equal 0, @pb.sync
  end

  def util_put
    @pb.put [
      [Pasteboard::Type::PLAIN_TEXT, 'pi'],
      [Pasteboard::Type::UTF_8,      'π'],
    ]
  end

end

