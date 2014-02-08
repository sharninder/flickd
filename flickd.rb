require 'flickraw'
require 'yaml'
require 'open-uri'

# authenticate with flickr
config = YAML.load_file("config.yaml")['defaults']
FlickRaw.api_key = config['api_key']
FlickRaw.shared_secret = config['shared_secret']

token = flickr.get_request_token
auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'read')
puts "Open this url in your browser to complete the authentication process: #{auth_url}"
puts "Copy here the number given when you complete the process."
verify = gets.strip

flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)

#flickr.access_token = config['access_token']
#flickr.access_secret = config['access_secret']

#login = flickr.test.login
#puts "You are now authenticated as #{login.username}"

# get list of all sets
all_sets = flickr.photosets.getList()

all_sets.each do |set|
  puts "Set: #{set.title} id: #{set.id}"

  #get all photos in the set
  # TODO: Get list of photos not part of any set
  get_photos_in_sets  = flickr.photosets.getPhotos(:photoset_id => set.id)
  get_photos_in_sets.photo.each do |photo|
    puts "Donwloading #{photo.title} from #{set.title}"

    #get all sizes of photos
    flickr.photos.getSizes(:photo_id => photo.id).each do |size|
      if size.label == "Original"
        puts "Photo source: #{size.source}"
        # retrieve file extension assuming it is 3 chars
        ext = size.source[-3,3]
        
        # open file and write url to it 
        open("#{photo.id}.#{ext}","wb") do |file|
          file << open("#{size.source}").read
        end        
      end
    end 
  end
end
