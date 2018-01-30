# frozen_string_literal: true

class TableClient
  attr_reader :client

  def initialize client
    @client = client
  end

  def read_rows; end

  def read_row; end
end
