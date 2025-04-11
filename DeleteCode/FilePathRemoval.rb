# frozen_string_literal: true

require 'fileutils'

# FilePathRemoval searches for files containing a specific keyword
# and provides functionality to remove them with confirmation
class FilePathRemoval
  BASE_PATH = 'SET YOUR BASE PATH'

  # Available project paths that can be referenced by symbol
  # SETUP YOUR OWN PROJECT PATHS HERE
  PATHS = {
    CE: "#{BASE_PATH}/carrier-engine",
    PE: "#{BASE_PATH}/partner-engine",
    AUTH: "#{BASE_PATH}/authentication"
  }.freeze

  attr_reader :keyword, :file_path, :output_file

  # Initializes a new FilePathRemoval instance
  #
  # @param keyword [String] The keyword to search for in file paths
  # @param file_path [Symbol, String] Base directory to start search from.
  #   Can be :CE, :PE, :AUTH or a custom path
  # @param output_file [String] Path where found files will be logged
  def initialize(keyword, file_path: :CE, output_file: 'removed_paths.txt')
    @keyword = keyword.downcase
    @file_path = PATHS[file_path] || file_path
    @output_file = "#{BASE_PATH}/#{output_file}"
  end

  # Main execution method that performs search, logging, and removal
  #
  # @return [void]
  def perform
    paths = paths_that_contain_keyword
    log_keyword_paths(paths)
    remove_paths(paths)
  end

  private

  # Finds all file and directory paths containing the keyword
  #
  # @return [Array<String>] List of matching file paths
  def paths_that_contain_keyword
    paths = []
    Dir.glob("#{file_path}/**/*").each do |path|
      paths << path if path.downcase.include?(keyword)
    end
    paths
  end

  # Logs all found paths to the output file
  #
  # @param paths [Array<String>] List of matching file paths
  # @return [void]
  def log_keyword_paths(paths)
    File.open(output_file, 'w') do |file|
      paths.each do |path|
        file.puts path
      end
    end

    puts "Found #{paths_that_contain_keyword.count} paths containing '#{keyword}'"
    puts "Paths have been written to #{output_file}"
  end

  # Handles the removal process with user confirmation
  #
  # @param paths [Array<String>] List of file paths to potentially remove
  # @return [void]
  def remove_paths(paths)
    if confirmation_answer == 'y'
      paths.reverse_each { |path| delete_path(path) }
      puts "All paths containing '#{keyword}' have been removed"
    else
      puts "Operation cancelled. No files were removed"
    end
  end

  # Deletes a single file or directory
  #
  # @param path [String] Path to delete
  # @return [void]
  def delete_path(path)
    unless File.exist?(path)
      puts "Skipping (we may have already removed the parent directory):\n\t #{path} (not found)"
      return
    end

    if File.directory?(path)
      FileUtils.rm_rf(path)
    else
      File.delete(path)
    end
    puts "Removed: #{path}"
  end

  # Prompts the user for confirmation before deleting files
  #
  # @return [String] User's response ('y' or 'n')
  def confirmation_answer
    print 'Do you want to remove these paths? (y/n): '

    gets.chomp.downcase
  end
end

# Execute if this file is run directly
if __FILE__ == $PROGRAM_NAME
  remove_paths = FilePathRemoval.new('thimble', file_path: :PE)
  remove_paths.perform
end