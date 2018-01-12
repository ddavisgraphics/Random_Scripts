## This generates the properties for the hydra heads assuming that they are DC
## most will be the same as the prop_name, but still will require customization
## albeit alot less manual work at the end.  

$array_of_fields = ["identifier","date","sender","sender_location","recipient","recipient_location","extent","page_number","page_total","transcript","box_number","folder_number","item_number"]

def create_property(prop_name, multiple)
  predicate_string = "property %prop_name%, predicate: ::RDF::Vocab::DC.%prop_name%, multiple: %multiple% do |index|\r\n\tindex.as :stored_searchable, :stored_sortable, :facetable\r\nend\r\n\r\n"

  predicate_string.gsub!('%prop_name%', prop_name).gsub!('%multiple%', multiple)
  predicate_string
end

$array_of_fields.each do |fields|
  puts create_property fields, false 
end 