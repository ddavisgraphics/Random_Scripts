# benchmark_script.rb
require 'benchmark/ips'
require 'csv'
require 'tempfile'

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/enumerable'

# --- Data Setup ---
# IMPORTANT: Use a much larger dataset for real benchmarks!
# This uses the small sample data for structural demonstration only.
sample_data = [
  { carrier_id: 'a8013209', carrier_nm: 'Hiscox', product_desc: 'General Liability', state_cd: 'FL', naics_desc: 'Handyman', submissions_180days: 1800 },
  { carrier_id: '00b671e8', carrier_nm: 'Liberty Mutual', product_desc: 'General Liability', state_cd: 'FL', naics_desc: 'Pressure washing', submissions_180days: 1400 },
  { carrier_id: '096b1b1d', carrier_nm: 'Homesite', product_desc: 'General Liability', state_cd: 'TX', naics_desc: 'Handyman', submissions_180days: 1500 },
  { carrier_id: 'a8013209', carrier_nm: 'Hiscox', product_desc: 'General Liability', state_cd: 'CA', naics_desc: 'Janitorial Services', submissions_180days: 2000 }
  # Add many more rows for a real benchmark
]
headers = sample_data.first.keys

# --- Indexing (One-time setup before benchmark loop) ---

# 1. Current Combination Index
INDEX_KEYS = %i[naics_desc state_cd product_desc].freeze
index_key_combinations = (1..INDEX_KEYS.size).flat_map { |n| INDEX_KEYS.combination(n).to_a }.sort
index_combination = {}
sample_data.each do |row|
  index_key_combinations.each do |keys_for_index|
    key = keys_for_index.sort.map { |k| row[k] }
    next if key.any?(&:nil?) || key.any? { |v| v.to_s.strip.empty? }
    index_combination[key] ||= []
    index_combination[key] << row
  end
end

# 2. Linear Scan (Raw Data)
raw_data = sample_data

# 3. State-Only Index
index_by_state = sample_data.group_by { |row| row[:state_cd] }

# 4. Nested Index (State -> NAICS -> Product)
index_nested = {}
sample_data.each do |row|
  s = row[:state_cd]
  n = row[:naics_desc]
  p = row[:product_desc]
  next if [s, n, p].any?(&:blank?) # Basic check
  index_nested[s] ||= {}
  index_nested[s][n] ||= {}
  index_nested[s][n][p] ||= []
  index_nested[s][n][p] << row
end

# --- Search Criteria ---
# Use values guaranteed to exist in your (larger) test data
search_state = 'FL'
search_naics = 'Handyman'
search_product = 'General Liability'

puts "Benchmarking Lookup Strategies (Data Size: #{sample_data.size} rows)"
puts "\n"
puts "Combination Indexing: creates an index of all combinations of keys"
puts "Linear: iterates through the raw data to find matches"
puts "StateIdx: groups data by state and then filters by NAICS and Product"
puts "Nested: creates a nested hash structure for state, NAICS, and product"
puts "---"

Benchmark.ips do |x|
  x.warmup = 2 # Seconds to warm up JIT, etc.
  x.time = 5   # Seconds to run each benchmark

  # --- Scenario 1: Search by State Only ---
  x.report("Combination Indexing: State") do
    key = [search_state]
    index_combination[key] || []
  end

  x.report("Linear: State") do
    raw_data.select { |row| row[:state_cd] == search_state }
  end

  x.report("StateIdx: State") do
    index_by_state[search_state] || []
  end

  x.report("Nested: State") do
    (index_nested[search_state] || {}).values.flat_map(&:values).flatten
  end

  # --- Scenario 2: Search by State + NAICS ---
  x.report("Combination Indexing: State+NAICS") do
    key = [search_state, search_naics].sort
    index_combination[key] || []
  end

  x.report("Linear: State+NAICS") do
    raw_data.select { |row| row[:state_cd] == search_state && row[:naics_desc] == search_naics }
  end

  x.report("StateIdx: State+NAICS") do
    (index_by_state[search_state] || []).select { |row| row[:naics_desc] == search_naics }
  end

  x.report("Nested: State+NAICS") do
     # Requires iterating through the product level
    (index_nested[search_state]&.dig(search_naics) || {}).values.flatten
  end

  # --- Scenario 3: Search by State + NAICS + Product ---
  x.report("Combination Indexing: All 3") do
    key = [search_state, search_naics, search_product].sort
    index_combination[key] || []
  end

  x.report("Linear: All 3") do
    raw_data.select { |row| row[:state_cd] == search_state && row[:naics_desc] == search_naics && row[:product_desc] == search_product }
  end

  x.report("StateIdx: All 3") do
    (index_by_state[search_state] || []).select { |row| row[:naics_desc] == search_naics && row[:product_desc] == search_product }
  end

  x.report("Nested: All 3") do
    index_nested[search_state]&.dig(search_naics, search_product) || []
  end

  # Compare the iterations per second of each report
  x.compare!
end