# frozen_string_literal: true

module MarketRecommendation
  class RecommendationIndex
    INDEX_KEYS = %i[naics_desc state_cd product_desc].freeze

    attr_reader :csv_path, :state, :naics, :product, :raw_data

    # @param csv_path [String]
    # @param state [String] searched state
    # @param naics [String] Naics description
    # @param product [String] CL, GL, BOP, etc
    # @param search_criteria [Hash] # possible use for new filters
    def initialize(csv_path, state:, naics: nil, product: nil)
      @csv_path = csv_path
      @state = valid_state(state)
      @naics = naics
      @product = product
      @indexed_data = nil
      @raw_data = load_csv
    end

    # @return [Array<Hash>] An array of matching rows from the CSV.
    def call
      find(**query_builder)
    rescue StandardError => e
      log_error(error_debugging(e))
    end

    # @return [Hash] - Indexed data set
    def indexed_data
      @indexed_data ||= build_index(raw_data)
    end

    # @params query [Hash] builds the keys to search
    # @return [Array<Hash>] return matching rows
    def find(**query)
      query_keys = query.keys.map(&:to_sym).sort
      return [] unless query_keys.all? { |key| raw_data.first.key?(key) }

      values = index_key(query_keys, query)
      indexed_data[values] || []
    end

    private

    # @return [Hash]
    def query_builder
      {
        naics_desc: naics,
        state_cd: state,
        product_desc: product
      }.reject { |_key, value| value.to_s.strip.empty? }
    end

    # Builds keys and utilizes helper methods to create
    # a searchable index of hashses
    # @return [Hash]
    def build_index(data)
      index = {}
      data.each do |row|
        index_key_combinations.each do |keys_for_index|
          key = index_key(keys_for_index, row)
          next if key.any?(&:nil?) || key.any? { |v| v.to_s.strip.empty? }

          index[key] ||= []
          index[key] << row
        end
      end
      index
    end

    # This method takes the possible indexes and creates all
    # combinations of the index keys.
    # @return [Array<Symbol>]
    def index_key_combinations
      @index_key_combinations ||= (1..INDEX_KEYS.size).flat_map do |n|
        INDEX_KEYS.combination(n).to_a
      end.sort
    end

    # Create a new key out of the combinations of indexes
    # @return [Array]
    def index_key(keys, row)
      keys.sort.map { |k| row[k] }
    end

    # Reads and parses the CSV file into an array of hashes.
    # @return [Array<Hash>] An array of hashes, where keys are symbolized.
    def load_csv
      unless File.exist?(csv_path)
        raise Errno::ENOENT, "CSV file not found at path: #{csv_path}"
      end

      CSV.read(csv_path, headers: true, header_converters: :symbol).map(&:to_h)
    rescue CSV::MalformedCSVError => e
      error_string = "Malformed CSV error in #{csv_path}: #{e.message}"
      log_error(error_string)
    end

    def error_debugging(error)
      <<~ERROR_MESSAGES
        Error processing CSV data:
        - CSV Path: #{csv_path}
        - State: #{state}
        - NAICS: #{naics}
        - Product: #{product}
        - Error: #{error.message}
        - Backtrace: #{error.backtrace.join("\n")}
      ERROR_MESSAGES
    end

    # @param message [String] The error message to log.
    def log_error(message)
      timestamp = Time.now.zone.strftime('%Y-%m-%d %H:%M:%S')
      Rails.logger.error("[#{timestamp} | #{self.class}] #{message}")
    end

    # This ensures our user entered valid data for the state.
    # @return [String] The state code in uppercase.
    # @raise [ArgumentError] if the state identifier is blank or invalid.
    def valid_state(state)
      state = state.to_s.strip

      raise ArgumentError, 'State identifier cannot be blank.' if state.blank?

      valid_state = US_STATES.find do |k, v|
        k.casecmp?(state) || v.casecmp?(state)
      end

      if valid_state.present?
        valid_state.first.upcase
      else
        raise ArgumentError, "Invalid state identifier provided: #{state}"
      end
    end
  end
end
