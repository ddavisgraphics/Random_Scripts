require 'fileutils'

# Regex for the first facade method (QuoteRequestFacade)
method_to_remove_regex_v1 = /^\s*def\s+facade\s*
  \s*@facade\s*\|\|=\s*
  \s*QuoteRequestFacade\.new\(\s*store\.answer_map_with_pools\s*,\s*parent:\s*store\s*\)\s*
  \s*end\s*$/x # x flag allows for multi-line regex and comments

# Regex for the second facade method (carrier.facade_class)
method_to_remove_regex_v2 = /^\s*def\s+facade\s*
  \s*@facade\s*\|\|=\s*
  \s*carrier\.facade_class\.new\(\s*store\.answer_map_with_pools\s*,\s*parent:\s*store\s*\)\s*
  \s*end\s*$/x # x flag allows for multi-line regex and comments

# Glob pattern for the files to process
glob_pattern = File.join('app', 'commands', '**', '*.rb') # More robust way to build path

puts "Searching for files in: #{File.expand_path(glob_pattern)}"

Dir.glob(glob_pattern).each do |file_path|
  content = File.read(file_path)
  original_content_length = content.length
  modified_content = content

  # Apply removal for the first version of the facade method
  modified_content = modified_content.gsub(method_to_remove_regex_v1, '')

  # Apply removal for the second version of the facade method on the already modified content
  modified_content = modified_content.gsub(method_to_remove_regex_v2, '')

  if modified_content.length < original_content_length
    puts "Modifying: #{file_path}"
    File.write(file_path, modified_content)
  else
    # Optional: print if file was checked but no change made
    # puts "No change needed for: #{file_path}"
  end
end

puts 'Script finished.'
