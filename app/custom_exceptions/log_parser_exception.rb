class LogParserException < StandardError
  attr_reader :code

  def initialize(code)
    @code = code
  end

  def to_s
    "[#{code}] #{super}"
  end
end
