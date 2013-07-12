window.gmapInit = ->
  mapOptions =
    center: new google.maps.LatLng 49.61071, 30.121078
    zoom: 4
    mapTypeId: google.maps.MapTypeId.ROADMAP
  map = new google.maps.Map document.getElementById("map-canvas"), mapOptions
  window.map = map
  addGrid()

window.addMarker = (latlng, map)->
  map = map || window.map
  new google.maps.Marker
    map: map
    position: new google.maps.LatLng latlng[0], latlng[1]

window.setCenter = (latlng, map)->
  map = map || window.map
  map.setCenter new google.maps.LatLng latlng[0], latlng[1]

window.addGrid = ->
  addMarker coord for coord in window.grids

google.maps.event.addDomListener window, 'load', gmapInit
