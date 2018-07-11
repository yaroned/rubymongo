
require_relative 'WordCountParser_mongo'

my_parser = WordCountParser_mongo.new("books/");
my_parser.form_dictionary()
