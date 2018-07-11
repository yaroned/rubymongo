# WordCountParser_mongo - the constructor accepts a directory path contains .txt files and save to mongoDB
# num_of_books - the number of .txt files in the directory
# names - array consists of the .txt files names in the directory
#
require 'mongo'
class WordCountParser_mongo
  @@num_of_books = 0
  @@names = Array.new
  @@WORDS_COUNT = {}
  @@COLLECTION_NAME = "_counts_"
  def initialize(dir_path)
    @dir_path = dir_path
    @table_name = '__counts'
    @db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'word_counts')
    @coll = @db["word_counts"]
  end


  def form_dictionary()
    Dir.foreach(@dir_path){|file|
      next if file == '.' or file == '..'
      @@names << file
      @@num_of_books +=1
    }
    @@names.each { |x| index_one(x) }
  end


  # Indexes a file to mongodb
  # Params:
  # +book_name+:: .txt file path in the directory path
  def index_one(book_name)

    file = File.open( @dir_path+book_name, "r")

    puts "Indexing #{book_name}"
    templine = 0;
    file.each_line do |line|
      tempword = 0
      words = line.split
      words.each do |word|
        #word = word.gsub(/[^a-zA-Z0-9-]+/i, "").downcase
        word = word.gsub(/[;.""...,()?!*]+/i, "").downcase
        doc = {
            "word" => word,
            "count" => 1,
            "location"=>{
                "file_name":book_name,
                "line":templine,
                "word":tempword
            }
        }

        @db[:"#{@@COLLECTION_NAME}"].update_one(
            {'word' => word},
            {

                    "$inc" => {'count' => 1},
                    "$push" => {
                        "location" => doc["location"]
                    }

            },
            {"upsert":true})
      tempword = tempword+1
      end
      templine = templine+1
    end

    puts "Indexed #{book_name}"
  end


end

