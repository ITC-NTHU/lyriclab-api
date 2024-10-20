# LyricLab

A web service that helps users learn new vocabulary from Chinese (TW) songs.

## Overview

LyricLab pulls **song data** (title, artist, popularity, album, and etc.) as well as **lyrics** from the Spotify and LrcLib APIs.

Users can select one of the difficulty levels and search for a song. LyricLab will then generate a vocabulary list based on the selected level. Afterward, users can select specific words. LyricLab will provide translations, pinyin, and examples of how each word is used in a sentence.

*Disclaimer: This service is still a work in progress. Currently, LyricLab only supports the search function and displays song data along with lyrics.*

We hope LyricLab will become an essential tool that helps people build confidence in their Chinese language skills.

## Setup

- Create personal Spotify API CLIENT_ID and CLIENT_SECRET
- Copy config/secrets_example.yml to config/secrets.yml and update information
- Ensure correct version of Ruby install (see .ruby-version for rbenv)
- Run bundle install

## Running Tests

To run tests:

```
rake spec
```