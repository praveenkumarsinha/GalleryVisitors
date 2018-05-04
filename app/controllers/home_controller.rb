class HomeController < ApplicationController

  def index
  end

  def parse

    begin
      if params.dig(:log, :file)
        log_parser = LogParser.parse(File.open(params[:log][:file].path))
        @inferences = log_parser.formatted_inferences
        @inferences_per_visitor = log_parser.inferences_per_visitor
      else
        @message = 'Log file not found. Please upload a valid log file.'
      end

    rescue LogParserException => e
      @message = e.message

    rescue Exception => e
      @message = 'Some thing went wrong. Please ask administrator to intervene'
    end

  end

end
