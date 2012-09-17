var AQE = (function ( $ ) {
  "use strict";

  //
  // HOMEPAGE MAP
  //

  var map;

  function initialize() {
    var mapOptions = {
      zoom: 3,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      scrollwheel: false
    };
    map = new google.maps.Map(document.getElementById('map_canvas'),
        mapOptions);
    handleNoGeolocation();
    
    if ( $(".dashboard-map").length && mapmarkers && mapmarkers.length ) {
      var dashpos = new google.maps.LatLng(mapmarkers[0].lat, mapmarkers[0].lng);
      map.setCenter(dashpos);
      map.setZoom(5);
    }
    // Try HTML5 geolocation
    else if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var pos = new google.maps.LatLng(position.coords.latitude,
                                          position.coords.longitude);

        map.setCenter(pos);
      });
    }

    if ( mapmarkers && mapmarkers.length ) {
      for ( var x = 0, len = mapmarkers.length; x < len; x++ ) {
        addMapMarker( mapmarkers[x].lat, mapmarkers[x].lng, mapmarkers[x].feed_id );
      }
    }
  }

  function handleNoGeolocation() {
    var pos = new google.maps.LatLng(30,-20);
    map.setCenter(pos);
  }

  function addMapMarker(lat, lng, id) {
    var myLatlng = new google.maps.LatLng(lat, lng);
    var feed_id = id;
    var marker = new google.maps.Marker({
      position: myLatlng,
      map: map,
      icon: '/assets/img/egg-icon.png'
    });
    google.maps.event.addListener(marker, 'click', function() {
      var target = '/egg/'+ feed_id;
      if ( window.location.pathname != target ) {
        window.location.pathname = target;
      }
    });
  }

  if ( $(".home-map").length || $(".dashboard-map").length ) {
    google.maps.event.addDomListener(window, 'load', initialize);
  }

  //
  // LOCATION PICKER
  //

  var locpic = new GMapsLatLonPicker(),
      locpicker = $(".gllpLatlonPicker").first(),
      locsearch = $(".gllpSearchField").first(),
      locsaved = parseInt($(".location-saved").first().val());

  if ( locpicker.length ) {

    locpic.init( locpicker );

    // search
    $(".gllpSearchField").keydown(function(event){
      if(event.keyCode == 13){
        locpic.performSearch( $(this).val(), false );
        event.preventDefault();
      }
    });

    // HTML5 geolocation
    if(!locsaved && navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        $(".gllpLatitude").val(position.coords.latitude);
        $(".gllpLongitude").val(position.coords.longitude);
        $(".gllpZoom").val(13);
        locpic.custom_redraw();
      });
    }

  }

  //
  // CLAIMING FIELD
  //

  $(".claiming-form").submit( function (event) {
    var $this   = $(this),
        $input  = $this.find(".claiming-input"),
        $error  = $(".claiming-error");

    if ( $input.val() === "" ) {
      event.preventDefault();
      $error.html("Please enter a serial number").removeClass("hidden");
    }
  });

  $(".claiming-input").blur( function (event) {
    $(".claiming-error").addClass("hidden");
  });

})( jQuery );

