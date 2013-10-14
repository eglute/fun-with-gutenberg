require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

include Mongo

def validate_encoding(str, encoding='UTF-8')
  str.force_encoding(encoding).chars.collect do |c| 
    (c.valid_encoding?) ? c:'?'
  end.join 
end

db = MongoClient.new('localhost', 27017).db('gutenberg')
books = Grid.new(db)

count = 0

Dir.foreach("gutenberg") {|book| 
  if File.file?("gutenberg/#{book}") && !book.start_with?(".")
    title = " "
    author = " "
    release_date = " "
    language = " "
    encoding = " "
    content = ""
    puts book
    count = count + 1
    puts "Count: #{count}"
    File.foreach("gutenberg/#{book}") { |line|

      line = validate_encoding(line)
      
      content << line
      # begin
      if !line.empty?
        if line.start_with?("Title: ")
          title = line.sub("Title: ", "")
        elsif line.start_with?("Author: ")
          author = line.sub("Author: ", "")
        elsif line.start_with?("Release Date: ")
          release_date = line.sub("Release Date: ", "")
        elsif line.start_with?("Language: ")
          language = line.sub("Language: ", "")
        elsif line.start_with?("Character set encoding: ")
          encoding = line.sub("Character set encoding: ", "")
        end
      end
    }

    puts "*****"
    new_book = { :title => title,
      :content_type => "text",
      :author => author,
      :release_date => release_date,
      :language => language,
      :encoding => encoding,
      :original_file_name => book,
      :time => Time.now
    }    
    books.put(content, new_book)

  end
  
}


