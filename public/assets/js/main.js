var AQE = (function ( $ ) {
  "use strict";

  //
  // HOMEPAGE MAP
  //

  var map;

  function initialize() {
    var mapOptions = {
      zoom: 6,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById('map_canvas'),
        mapOptions);
    handleNoGeolocation();

    // Try HTML5 geolocation
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var pos = new google.maps.LatLng(position.coords.latitude,
                                          position.coords.longitude);

        map.setCenter(pos);
      });
    }

    if ( mapmarkers && mapmarkers.length ) {
      for ( var x = 0, len = mapmarkers.length; x < len; x++ ) {
        addMapMarker( mapmarkers[x].lat, mapmarkers[x].lng );
      }
    }
  }

  function handleNoGeolocation() {
    var pos = new google.maps.LatLng(51.51333,-0.088947);
    map.setCenter(pos);
  }

  function addMapMarker(lat, lng) {
    var myLatlng = new google.maps.LatLng(lat, lng);
    var marker = new google.maps.Marker({
      position: myLatlng,
      map: map
    });
  }

  if ( $(".home-map").length ) {
    google.maps.event.addDomListener(window, 'load', initialize);
  }

})( jQuery );

