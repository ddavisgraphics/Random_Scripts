require 'fileutils'
require 'pry'

# ruby cherry_picker.rb markel

# Ensure the script starts in the specified directory
# change to your path
desired_directory = '/Users/daviddavis/Desktop/boldpenguin/carrier-engine'

unless Dir.pwd == desired_directory
  puts "Changing directory to #{desired_directory}"
  Dir.chdir(desired_directory)
end

# Read the list of files from the YAML file
file_list = [
  'app/commands/pie/download_pdf_command.rb',
  'app/responses/pie/download_pdf_response.rb',
  'app/strategies/pie/quote_proposal_strategy.rb',
  'test/commands/pie/download_pdf_command_test.rb',
  'test/strategies/pie/quote_proposal_strategy_test.rb',
  'test/responses/pie/download_pdf_response_test.rb'
]

new_name = ARGV[0]

if new_name.nil? || new_name.empty?
  puts "Please provide a new name as a command line argument."
  exit 1
end

file_list.each do |file|
  # change the name and path of the file
  new_file = file.gsub('pie', new_name)
  FileUtils.mkdir_p(File.dirname(new_file))
  FileUtils.cp(file, new_file)

  # Read the file content, replace 'pie' with new_name, and write it back
  content = File.read(new_file)
  new_content = content.gsub('pie', new_name.capitalize)
  File.write(new_file, new_content)
end

puts "Files have been cherry-picked and renamed"