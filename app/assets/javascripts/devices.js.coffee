window.sharedVariables = {}

randomColor = ->
  "#" + Math.floor(Math.random() * 16777215).toString(16)

prepearCoordinates = (coordinates) ->
  prepearedCoordinates = coordinates.map (coords) ->
    new google.maps.LatLng(coords[0], coords[1]) # WTF array

  prepearedCoordinates

drawLineOnMap = (coordinates, map) ->
  prepearedCoordinates = prepearCoordinates(coordinates)

  path = new google.maps.Polyline(
    path: prepearedCoordinates
    geodesic: false
    strokeColor: randomColor()
    strokeOpacity: 0.9
    strokeWeight: 3
  )

  path.setMap map

drawPolygonOnMap = (coordinates, map) ->
  prepearedCoordinates = prepearCoordinates(coordinates)

  polygon = new google.maps.Polygon(
    paths: prepearedCoordinates
    strokeColor: "#ffff00"
    strokeOpacity: 0.9
    strokeWeight: 5
    fillColor: "#ffff00"
    fillOpacity: 0.35
  )
  polygon.setMap map

initPolygonEditor = (map) ->
  drawingManager = new google.maps.drawing.DrawingManager(
    drawingMode: google.maps.drawing.OverlayType.POLYGON
    drawingControl: true
    drawingControlOptions:
      position: google.maps.ControlPosition.TOP_CENTER
      drawingModes: [
        google.maps.drawing.OverlayType.POLYGON
      ]

    circleOptions:
      fillColor: "#ffff00"
      fillOpacity: 1
      strokeWeight: 5
      clickable: true
      editable: true
      zIndex: 1
  )

  google.maps.event.addListener drawingManager, "polygoncomplete", (polygon) ->
    $("#save-area").show()

    $("#save-area").unbind('click').on 'click', ->
      coordinates = polygon.latLngs.getArray()[0].getArray()
      prepearedCoordinates = coordinates.map (coords) ->
        # { lat: coords.lat(), lng: coords.lng() }
        [ coords.lat(), coords.lng() ]

      console.log prepearedCoordinates
      $.post("/client_api/alerts",
        device_id: window.sharedVariables.deviceId
        area:      prepearedCoordinates,
        emails:    ["qwe@asd.aasd", "zxc@zxc.zxc"]
      ).done (data) ->
        $("#save-area").hide()
        return


  drawingManager.setMap map

initialize = ->
  mapOptions =
    center: new google.maps.LatLng($('#map_canvas').data('lat'), $('#map_canvas').data('lng'))
    zoom: 13
    mapTypeId: google.maps.MapTypeId.ROADMAP

  map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)
  window.sharedVariables.map = map;

  polygon = initPolygonEditor(map)
  window.sharedVariables.polygon = polygon;

  window.sharedVariables.deviceId = $('#map_canvas').data('id')

  $.ajax(
    url: "/client_api/devices/#{window.sharedVariables.deviceId}"
  ).done (data) ->
    for route in data
      drawLineOnMap(route.route, window.sharedVariables.map)

  $.ajax(
    url: "/client_api/alerts/?device_id=#{window.sharedVariables.deviceId}"
  ).done (data) ->
    for area in data
      drawPolygonOnMap(area.area, window.sharedVariables.map)

$(document).ready ->
  initialize()
