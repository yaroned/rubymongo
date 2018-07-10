
require_relative 'WordCountParser_mongo'
# my_parser = WordCount.new()
# my_parser.countWordsDir("./books")

my_parser = WordCountParser_mongo.new("books/");

my_parser.form_dictionary()

#my_parser.sort_by("key")
my_parser.sort_by("value")
my_parser.print_dictionary_to_file("my_file.txt")


