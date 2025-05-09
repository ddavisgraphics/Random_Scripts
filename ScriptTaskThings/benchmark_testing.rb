require 'benchmark/ips'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'

agents = Array.new(10_000) { |i| { Email: "test#{i}@example.com" } }

Benchmark.ips do |x|
  x.report("each_with_object") do
    agents.each_with_object({}) do |agent, hash|
      email = agent.with_indifferent_access[:Email]&.strip
      next if email.blank?
      hash[email.downcase] = agent
    end
  end

  x.report("index_by") do
    agents.reject { |agent| agent[:Email].blank? }
          .index_by { |agent| agent[:Email].strip.downcase }
  end

  x.compare!
end