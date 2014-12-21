randomColor = ->
  "#" + Math.floor(Math.random() * 16777215).toString(16)

drawLineOnMap = (coordinates, map) ->
  prepearedCoordinates = coordinates.map (coords) ->
    new google.maps.LatLng(coords[0], coords[1]) # WTF array

  path = new google.maps.Polyline(
    path: prepearedCoordinates
    geodesic: false
    strokeColor: randomColor()
    strokeOpacity: 0.9
    strokeWeight: 3
  )

  path.setMap map

initialize = ->
  mapOptions =
    center: new google.maps.LatLng($('#map_canvas').data('lat'), $('#map_canvas').data('lng'))
    zoom: 13
    mapTypeId: google.maps.MapTypeId.ROADMAP

  map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)

  deviceId = $('#map_canvas').data('id')

  $.ajax(
    url: "/client_api/devices/#{deviceId}"
  ).done (data) ->
    for route in data
      drawLineOnMap(route.route, map)

$(document).ready ->
  initialize()
