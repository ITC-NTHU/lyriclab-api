# frozen_string_literal: true

require 'httparty'
require 'json'
require 'yaml'

BASE_URL = 'https://lrclib.net/api/get'

def call_api(song_title, artist_name)
  url = BASE_URL.to_s
  query = {
    track_name: song_title,
    artist_name:
  }

  HTTParty.get(url, query:)
end

def get_lyrics(received)
  result = JSON.parse(received)
  return result['plainLyrics'] if result && result['plainLyrics']

  "No lyrics found for #{song_title} by #{artist_name}."
end

song_title = '好不容易'
artist_name = '告五人'

response = call_api(song_title, artist_name)
if response.code == 200
  puts get_lyrics(response.body)
else
  puts "Error: #{response.body}"
end

File.write('spec/fixtures/lyrics.yml', response.body.to_yaml)
