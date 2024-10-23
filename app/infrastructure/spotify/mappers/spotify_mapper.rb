# frozen_string_literal: true

module SpotifyMapper
  require_relative './spotify/spotify_api'
  require_relative 'song_mapper'
  require_relative 'artist_mapper'
  require_relative 'album_mapper'
  require 'json'

  # initialize Spotify API information
  def self.initialize_api(client_id, client_secret)
    @spotify_api = LyricLab::Spotify::Api.new(client_id, client_secret)
    @song_mapper = LyricLab::Spotify::SongMapper.new(client_id, client_secret)
  end

  # get song information from Spotify API
  def self.map_song_from_spotify(search_string)
    song_entity = @song_mapper.find(search_string)
    parse_song(song_entity) if song_entity
  end

  # transfer spotify song JSON format into song_entity
  def self.parse_song(song_entity)
    {
      title: song_entity.title,
      spotify_id:song_entity.id,
      popularity:song_entity.popularity,
      preview_url:song_entity.preview_url,
      album_name:parse_album(song_entity.album_name)[:name],
      artist_name_string:song_entity.artist_name.map{|artist_data| parse_artist(artist_data)}.join(", "),
      cover_image_url_big:parse_album(song_entity.album_name)[:cover_image_url_big],
      cover_image_url_medium:parse_album(song_entity.album_name)[:cover_image_url_medium],
      cover_image_url_small:parse_album(song_entity.album_name)[:cover_image_url_small],

      #initialize lyric column
      lyric:""
    }
  end

  # transfer spotify song JSON format into artist_entity
  def self.parse_artist(artist_data)
    artist_entity = LyricLab::Spotify::ArtistMapper.build_entity(artist_data)
    artist_entity.name
  end

  # get album information from Spotify API
  def self.map_album_from_spotify(album_id)
    url = URI.parse("#{BASE_URL}/albums/#{album_id}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url.request_uri, get_auth_header(api_token))

    response = http.request(request)
    if response.code == "200"
      parse_album(JSON.parse(response.body))
    else
      puts "Error: Unable to fetch album from Spotify, Response Code: #{response.code}"
      nil
    end
  end

  # transfer spotify album JSON format into album_entity
  def self.parse_album(album_data)
    album_entity = LyricLab::Spotify::AlbumMapper.build_entity(album_data)
    {
      name: album_entity.name,
      cover_image_url_big: album_entity.cover_image_url_big,
      cover_image_url_medium: album_entity.cover_image_url_medium,
      cover_image_url_small: album_entity.cover_image_url_small
    }
  end
end
