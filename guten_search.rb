require 'rubygems'  
require 'mongo'
require 'elasticsearch'

include Mongo

phrase = ARGV[0]
if !phrase
  phrase = "Euroclydon"
end

client = Elasticsearch::Client.new host: 'localhost'#, log: true
db = MongoClient.new('localhost', 27017).db('gutenberg')
coll = db.collection("fs.files")

client.cluster.health
res = client.search q: phrase

took = res['took']
puts "\nElasticSearch + MongoDB Based Project Gutenberg Word Search"
puts "\nIt took #{took} ms to search #{coll.count} books for words '#{phrase}'!\n"
timed_out = res['timed_out']
if timed_out
  puts "The search time out!"
end

if !timed_out
  all_hits = res['hits']
  total_hits = all_hits['total']
  puts "Found #{total_hits} results\n"
  if all_hits['hits']
    all_hits['hits'].each { |hits| 
      hits.each { |key, value| 
        if key == "_id"
          book = coll.find({"_id" => BSON::ObjectId(value)})
          book.each { |item| 
            puts "\n-----------------------------------------------------------------\n"
            puts "Book: #{item['title']}"
            puts "By: #{item['author']}"
            puts "Release Date: #{item['release_date']}"
            puts "Language: #{item['language'].strip()}, original file name: #{item['original_file_name']}"
          }
          
        end
      }
  }
  end
end