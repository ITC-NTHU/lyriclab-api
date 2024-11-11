$(document).ready(function($) {
    $(".recommendation-button").click(function() {
      spotifyId = this.dataset.spotifyId;
      console.log(spotifyId);
      if (spotifyId) {
        window.location.href = `search/result/${spotifyId}`;
      }
    });
});

