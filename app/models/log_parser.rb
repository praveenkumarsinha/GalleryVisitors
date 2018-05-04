class LogParser

  attr_reader :log_data
  attr_reader :inference_hash

  # Step 00: Takes a file and reads number of lines to read from log file
  # Step 01: Makes a new object from array of arrays formed by reading set of lines
  # and splitting every line with continuous spaces as separator
  #
  # Usage:  LogParser.parse(File.open('public/example_logs/visitor_1.log'))
  def self.parse(log_file)
    unless log_file.is_a?(File)
      raise LogParserException.new(101), 'Log file is either corrupt or is un-readable. Please try with another log file'
    end

    log_lines = File.readlines(log_file)
    lines_to_fetch = log_lines.first.to_i

    if lines_to_fetch > 1
      new(log_lines[1..lines_to_fetch].collect {|log_line| log_line.split(/ +/).collect(&:chomp)})
    else
      raise LogParserException.new(102), 'Insufficient number of lines to read minimum 2 is required'
    end
  end


  # new object is initialized which is populated with array of arrays. Something like
  #
  # [[visitor_id, room_index, (I/O), minute_time_stamp][...][...]]
  def initialize(log_data)
    @log_data = log_data
    @inference_hash = {}

    process
  end

  # Assuming log_data is well formed
  # Step 00: Iterate over log data and generate a hash where room's index are keys while values are hash object
  # which has visitor_id as keys and its values are array of "in" and "out" time_stamp hash
  #
  # e.g inference_hash = {room_index: {visitor_id: [{in: ts, out: ts}, {in: ts, out: ts}]}}
  def process
    log_data.each do |i_log_data|
      next if i_log_data[0].try(:to_i) > 1023 or i_log_data[1].try(:to_i) > 99 or i_log_data[3].try(:to_i) > 1439

      @inference_hash[i_log_data[1]] ||= {}
      @inference_hash[i_log_data[1]][i_log_data[0]] ||= [{}]

      if @inference_hash[i_log_data[1]][i_log_data[0]].last.keys.length < 2
      else
        @inference_hash[i_log_data[1]][i_log_data[0]] << {}
      end

      if i_log_data[2] == 'I'
        @inference_hash[i_log_data[1]][i_log_data[0]].last.merge!({in: i_log_data[3].try(:to_f)})
      elsif i_log_data[2] == 'O'
        @inference_hash[i_log_data[1]][i_log_data[0]].last.merge!({out: i_log_data[3].try(:to_f)})
      end
    end
  end

  def formatted_inferences
    formatted_inferences = @inference_hash.sort.to_h.collect do |room_index, visitors_hash|
      "Room #{room_index}, #{(visitors_hash.values.flatten.collect {|in_out_log| in_out_log[:out] - in_out_log[:in]}.inject(&:+) / visitors_hash.keys.length.to_f).floor rescue 'N.A'} minute average visit, #{visitors_hash.keys.length} visitor(s) total"
    end

    formatted_inferences = ['Unable to device presentable inferences from logs'] if formatted_inferences.blank?

    formatted_inferences
  end

  def inferences_per_visitor
    _inference_hash_per_visitor = {}

    @inference_hash.each do |room_index_key, visitor_info_hash|
      visitor_info_hash.each do |visitor_id, in_out_array|
        _inference_hash_per_visitor[visitor_id] ||= {}
        (_inference_hash_per_visitor[visitor_id][room_index_key] ||= []) << ((in_out_array.collect {|in_out_log| in_out_log[:out] - in_out_log[:in]}.inject(&:+) / in_out_array.length.to_f) rescue 0.0)
      end
    end

    formatted_inferences = _inference_hash_per_visitor.collect do |visitor_id, average_time_in_rooms|
      "Visitor #{visitor_id}, spent #{((average_time_in_rooms.values.flatten.inject(&:+) / average_time_in_rooms.keys.length).floor rescue 'N.A')} minute(s) in #{average_time_in_rooms.keys.length} rooms."
    end

    formatted_inferences = ['Unable to device presentable inferences from logs'] if formatted_inferences.blank?

    formatted_inferences
  end

end