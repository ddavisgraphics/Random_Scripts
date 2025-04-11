# frozen_string_literal: true

require 'csv'

# This class parses a CSV file and extracts specific information from messages
class AgentContactIdLogParser
  attr_reader :input_path, :output_path, :parsed_data

  # @param input_path [String] Path to the input CSV file
  # @param output_path [String] Path where the output CSV will be written
  def initialize(input_path, output_path = nil)
    @input_path = input_path
    @output_path = output_path || generate_default_output_path
    @parsed_data = []
  end

  # @return [Boolean] True if processing was successful
  def process
    parse_input_csv
    extract_message_data
    export_to_csv
    true
  rescue StandardError => e
    puts "Error processing CSV: #{e.message}"
    false
  end

  private

  # @return [Array<Hash>] Parsed CSV data
  def parse_input_csv
    data = CSV.read(input_path, headers: true).map(&:to_h)
    @parsed_data = data.map { |row| { 'Message' => row['Message'] } }
    @parsed_data.reject! { |row| row['Message'].nil? }
    @parsed_data
  end

  # @return [Array<Hash>] Enhanced data with extracted information
  def extract_message_data
    processed = @parsed_data.map do |row|
      message = row['Message'].to_s

      # Extract simple email format
      email_match = message.match(/email:\s*([^\s]+@[^\s]+)/)
      email = email_match ? email_match[1] : ''

      # Extract from structured message format
      if message.include?('No agent contact ID when fetching')
        brokerage = extract_field(message, 'Brokerage:')
        carrier = extract_field(message, 'Carrier:')
        enrollment_id = extract_uuid(message, 'Enrollment ID:')
        email = extract_email(message, 'Owner Email:') || email
        quote_number = extract_field(message, 'Quote Number:')
      else
        brokerage = ''
        carrier = ''
        enrollment_id = ''
        quote_number = ''
      end

      row.merge({
                  'Brokerage' => brokerage,
                  'Carrier' => carrier,
                  'Enrollment ID' => enrollment_id,
                  'Email' => email,
                  'Quote Number' => quote_number
                })
    end

    # Remove empty/blank values and deduplicate
    unique_records = {}
    processed.each do |row|
      # Create a key based on all fields for deduplication
      key = [row['Enrollment ID'], row['Email']].join('|')
      next if key.strip.empty? # Skip records with no meaningful data

      # Only keep the first occurrence of each unique record
      unique_records[key] ||= row
    end

    @parsed_data = unique_records.values
  end

  # Helper method to extract a field value from a structured message
  #
  # @param message [String] The message text to parse
  # @param field_prefix [String] The field name/prefix to look for
  # @return [String] Extracted field value or empty string
  def extract_field(message, field_prefix)
    pattern = /#{Regexp.escape(field_prefix)}\s*([^-\n]+)/
    match = message.match(pattern)
    match ? match[1].strip : ''
  end

  # @return [String] Extracted UUID from the message
  def extract_uuid(message, field_prefix)
    uuid_pattern = /#{Regexp.escape(field_prefix)}\s*([\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12})/i
    match = message.match(uuid_pattern)
    match ? match[1].strip : ''
  end

  def extract_email(message, field_prefix)
    email_pattern = /#{Regexp.escape(field_prefix)}\s*([\w.%+-]+@[\w.-]+\.[A-Za-z]{2,})/i
    match = message.match(email_pattern)
    return match ? match[1].strip : ''
  end

  # @return [Integer] Number of rows written
  def export_to_csv
    headers = ['Brokerage', 'Carrier', 'Enrollment ID', 'Email', 'Quote Number']

    CSV.open(output_path, 'wb') do |csv|
      csv << headers

      @parsed_data.each do |row|
        csv << headers.map { |header| row[header] || '' }
      end
    end

    puts "Exported #{@parsed_data.size} rows to #{output_path}"
    @parsed_data.size
  end

  # Generate a default output path based on the input path
  #
  # @return [String] The default output path
  def generate_default_output_path
    input_dir = File.dirname(input_path)
    input_basename = File.basename(input_path, '.*')
    "#{input_dir}/#{input_basename}_processed.csv"
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts 'Usage: ruby agent_contact_id_log_parser.rb input.csv [output.csv]'
    exit(1)
  end

  input_path = ARGV[0]
  output_path = ARGV[1] if ARGV.size > 1

  parser = AgentContactIdLogParser.new(input_path, output_path)
  parser.process
end
