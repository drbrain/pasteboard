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

  def test_each
    util_put_many

    items = []

    @pb.each do |item|
      items << item[0, 2]
    end

    assert_equal [@item1, @item2], items
  end

  def test_each_enum
    enum = @pb.each

    enum_klass = defined?(Enumerator) ? Enumerator : Enumerable::Enumerator

    assert_kind_of enum_klass, enum
  end

  def test_each_flavor
    util_put_many

    items = []

    @pb.each Pasteboard::Type::UTF_8 do |item|
      items << item
    end

    assert_equal ['π', '0°'], items
  end

  def test_each_flavor_missing
    util_put_many

    items = []

    @pb.each Pasteboard::Type::JPEG do |item|
      items << item
    end

    assert_equal [nil, nil], items
  end

  def test_first
    util_put

    item = @pb.first

    assert_equal @item, item[0, 2]
  end

  def test_first_flavor
    util_put

    item = @pb.first Pasteboard::Type::UTF_8

    assert_equal 'π', item
  end

  def test_get
    util_put

    item = @pb.get(0)

    assert_equal @item, item[0, 2]
  end

  def test_get_flavor
    util_put

    assert_equal 'pi', @pb.get(0, Pasteboard::Type::PLAIN_TEXT)
  end

  def test_get_flavor_missing
    util_put

    assert_nil @pb.get(0, Pasteboard::Type::JPEG)
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

  def test_ids
    util_put

    assert_equal [0], @pb.ids
  end

  def test_index
    util_put

    item = @pb[0]

    assert_equal @item, item[0, 2]

    assert_nil @pb[1]
  end

  def test_index_flavor
    util_put

    item = @pb[0, Pasteboard::Type::UTF_8]

    assert_equal 'π', item

    assert_nil @pb[1, Pasteboard::Type::UTF_8]
  end

  def test_index_multi
    util_put_many

    assert_equal @item1, @pb[0][0, 2]

    assert_equal @item2, @pb[1][0, 2]
  end

  def test_inspect
    expected = '#<%s:0x%x %s>' % [Pasteboard, @pb.object_id, @pb.name]

    assert_equal expected, @pb.inspect
  end

  def test_name
    assert_match %r%CFPasteboardUnique%, @pb.name
  end

  def test_put
    util_put

    assert_equal 1, @pb.get_item_count
    assert_equal [Pasteboard::Type::PLAIN_TEXT, Pasteboard::Type::UTF_8],
                 @pb.copy_item_flavors(0)[0, 2]
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
    @item = [
      [Pasteboard::Type::PLAIN_TEXT, 'pi'],
      [Pasteboard::Type::UTF_8,      'π'],
    ]

    @pb.put @item
  end

  def util_put_many
    @item1 = [
      [Pasteboard::Type::PLAIN_TEXT, 'pi'],
      [Pasteboard::Type::UTF_8,      'π'],
    ]

    @item2 = [
      [Pasteboard::Type::UTF_8,      '0°'],
      [Pasteboard::Type::PLAIN_TEXT, '0 degrees'],
    ]

    @pb.put @item1, @item2
  end

end

