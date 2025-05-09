require 'benchmark/ips'
require 'set'
require 'active_support/core_ext/enumerable'

# Setup test data
ARRAY_SIZE = 10_000
EMAIL = 'test999@example.com'

# Create test data structures
array_of_hashes = ARRAY_SIZE.times.map do |i|
  { email: "test#{i}@example.com", id: i }
end

# Create indexed hash
hash_lookup = array_of_hashes.index_by { |h| h[:email] }

# Create set for comparison
email_set = Set.new(array_of_hashes.map { |h| h[:email] })

Benchmark.ips do |x|
  x.config(warmup: 2, time: 5)

  x.report('Array#find') do
    array_of_hashes.find { |h| h[:email] == EMAIL }
  end

  x.report('Array#detect') do
    array_of_hashes.detect { |h| h[:email] == EMAIL }
  end

  x.report('Hash lookup') do
    hash_lookup[EMAIL]
  end

  x.report('Set#include?') do
    email_set.include?(EMAIL)
  end

  x.compare!
end