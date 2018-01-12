# create and empty docker container 
# ---------------------------------------------------------------------------------------------
docker run --rm -v $(pwd):/usr/src -w /usr/src -ti ruby:2.4 bash ; cd my_app

# install rails 
# ---------------------------------------------------------------------------------------------
gem install rails                                            # install rails 
rails new --help                                             # verify rails exists 
rails new my_app --database=postgresql --skip-bundle         # create the new project 
exit                                                         # exit the container 
