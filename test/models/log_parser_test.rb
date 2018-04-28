require 'test_helper'

class LogParserTest < ActiveSupport::TestCase

  test 'should not process invalid file' do
    assert_raises(LogParserException) do
      LogParser.parse("some thing invalid")
    end
  end

  test 'should have greater than 1 log line to read' do
    assert_raises(LogParserException) do
      LogParser.parse(File.open('test/fixtures/files/invalid_rows_to_read_from_log.log'))
    end
  end

  test 'should process valid file' do
    lp_obj_01 = LogParser.parse(File.open('test/fixtures/files/visitor_1.log'))

    assert_kind_of(LogParser, lp_obj_01)
    assert_equal({"9" => {"0" => [{:in => 510, :out => 560}]}, "0" => {"1" => [{:in => 520, :out => 560}]}},
                 lp_obj_01.inference_hash)
    assert_equal(["Room 0, 40 minute average visit, 1 visitor(s) total",
                  "Room 9, 50 minute average visit, 1 visitor(s) total"],
                 lp_obj_01.formatted_inferences)


    lp_obj_02 = LogParser.parse(File.open('test/fixtures/files/visitor_2.log'))
    assert_kind_of(LogParser, lp_obj_02)
    assert_equal({"0"=>{"0"=>[{:in=>540, :out=>560}], "1"=>[{:in=>540, :out=>560}]}},
                 lp_obj_02.inference_hash)
    assert_equal(["Room 0, 20 minute average visit, 2 visitor(s) total"],
                 lp_obj_02.formatted_inferences)
  end

end