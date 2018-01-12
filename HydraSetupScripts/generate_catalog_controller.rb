## This generates the stuff for the catalog controller
## facets 
## search indexes
## 

$array_of_fields = ["identifier","date","sender","sender_location","recipient","recipient_location","extent","page_number","page_total","transcript","box_number","folder_number","item_number"]

# returns a string of facets
def create_facets(facet)
  "config.add_facet_field solr_name('#{facet}', :facetable), :label => '#{facet.capitalize}', :limit => 10\r"
end

# returns a string of index items to show in the base search
def create_indexes(facet)
  "config.add_index_field solr_name('#{facet}', :stored_searchable, type: :string), :label => '#{facet.capitalize}'\r"
end 

# returns a string of fields to show when the record is clcked 
def create_show(facet)
  "config.add_show_field solr_name('#{facet}', :stored_searchable, type: :string), :label => '#{facet.capitalize}'\r"
end 

# returns a string for the search fields.  
def create_search_indexes(facet)
  "config.add_search_field('#{facet}') do |field| \r
    \t#{facet}_field = Solrizer.solr_name('#{facet}', :stored_searchable) \r
    \tfield.solr_local_parameters = { \r
      \t\tqf: #{facet}_field, \r
      \t\tpf: #{facet}_field \r
    \t} \r
  end \n\r"
end 


puts "\r# Facets ---------------------------------------------------------------\r"
puts "# solr fields that will be treated as facets by the blacklight application\r # The ordering of the field names is the order of the display\r # :show may be set to false if you don't want the facet to be drawn in the\r # facet bar\r\r"

$array_of_fields.each do |field|
  puts create_facets field
end 

puts "\r# Browse Index ---------------------------------------------------------------\r"
puts "#solr fields to be displayed in the index (search results) view\r # The ordering of the field names is the order of the display\r\r"

$array_of_fields.each do |field|
  puts create_indexes field
end 

puts "\r# Show Fields ---------------------------------------------------------------\r"
puts "# solr fields to be displayed in the show (single result) view \r # The ordering of the field names is the order of the display\r\r"

$array_of_fields.each do |field|
  puts create_show field
end 

puts "\r# Search Fields ---------------------------------------------------------------\r"
puts "# Now we see how to over-ride Solr request handler defaults, in this \r
# case for a BL 'search field', which is really a dismax aggregate \r
# of Solr search fields.\r\r"

$array_of_fields.each do |field|
  puts create_search_indexes field
end 



