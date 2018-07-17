
require_relative '../WordCountParser_mongo'

describe WordCountParser_mongo do
	wcp = WordCountParser_mongo.new("books/")
	
	it "more than 0 book" do
		wcp.form_dictionary()
		wcp.instance_variable_get(:@names).length.should >0
	end
	
	it "a specific word should not be indexed exactly once" do
		s = wcp.fetch_all
		s.each do |i|
   		  count =  wcp.count_appearances(i["word"])
   		  expect(count). to eq 1
   		end
   	end
   
end
