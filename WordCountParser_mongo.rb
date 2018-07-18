# WordCountParser_mongo - the constructor accepts a directory path contains .txt files
# names - array consists of the .txt files names in the directory
#
require 'mongo'
class WordCountParser_mongo

  COLLECTION_NAME = "_counts_" #the collection to insert documents / new collection to create

  def initialize(dir_path)
    @names = Array.new
    @dir_path = dir_path
    @db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'word_counts')
    @coll = @db["word_counts"]
  end


  def form_dictionary()
    Dir.foreach(@dir_path){|file|
      next if file == '.' or file == '..'
      @names << file
    }
    @names.each { |x| index_one(x) }
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
        word = word.gsub(/[;.""...,()?!*]+/i, "").downcase
        doc = {
            "word" => word,
            "count" => 1,
            "location"=>{
                "file_name":"#{@dir_path}/"+book_name,
                "line":templine,
                "word":tempword
            }
        }

        @db[:"#{COLLECTION_NAME}"].update_one(
            {'word' => word},
            {
                    "$inc" => {'count' => 1},
                    "$push" => {
                        "location" => doc["location"]
                    },
                    "$currentDate":
                        {lastModified: true,
                    "createdAt":
                        { "$type": "timestamp" }
            },
            },
            {"upsert":true}) #create new document if one does not already exist

      tempword = tempword+1
      end
      templine = templine+1
    end

    puts "Indexed #{book_name}"
  end



  # fetches all docs from mongodb collection word_count
  # Params:
  def fetch_all()
        puts "fetching"
        m =  @db[:"#{COLLECTION_NAME}"].find({})
        puts "fetched..."
    return m
  end


  # given a word, it return the number of documents this word appear in. (should not return more than 1)
  # Params:
  def count_appearances(word)
    count =  @db[:"#{COLLECTION_NAME}"].find({"word":word}).count()
    return count
  end

end

