window.sharedVariables = {}

randomColor = ->
  "#" + Math.floor(Math.random() * 16777215).toString(16)

prepearCoordinates = (coordinates) ->
  prepearedCoordinates = coordinates.map (coords) ->
    new google.maps.LatLng(coords[0], coords[1]) # WTF array

  prepearedCoordinates

setInfoWindow = (object, latLng, content) ->
  infowindow = new google.maps.InfoWindow(content: content)
  google.maps.event.addListener object, "click", ->
    infowindow.setPosition latLng
    infowindow.open object.getMap()
    return

  infowindow

drawRouteOnMap = (coordinates, map, alerts) ->
  prepearedCoordinates = prepearCoordinates(coordinates)

  path = new google.maps.Polyline(
    path: prepearedCoordinates
    geodesic: false
    strokeColor: randomColor()
    strokeOpacity: 0.9
    strokeWeight: 3
  )

  pathPoints = path.getPath().getArray()
  pathCenter = pathPoints[Math.floor(pathPoints.length/2)]
  contentString = "<div id=\"content\">"
  contentString += alerts.map (alert) ->
    "<b>#{alert.alert.name}</b> | <i>#{alert.alerted_at}</i><br>"
  contentString += "</div>"

  path.infoWindow = setInfoWindow(path, pathCenter, contentString)

  path.setMap map

  path

drawAlertOnMap = (coordinates, map, alertName) ->
  prepearedCoordinates = prepearCoordinates(coordinates)

  polygon = new google.maps.Polygon(
    paths: prepearedCoordinates
    strokeColor: "#ffff00"
    strokeOpacity: 0.9
    strokeWeight: 5
    fillColor: "#ffff00"
    fillOpacity: 0.35
  )

  contentString = "<div id=\"content\">#{alertName}</div>"
  polygon.infoWindow = setInfoWindow(polygon, polygon.getBounds().getCenter(), contentString)

  polygon.setMap map

  polygon

initPolygonEditor = (map) ->
  drawingManager = new google.maps.drawing.DrawingManager(
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
    $("#control-buttons").show()

    $("#alert-save-btn").unbind('click').on 'click', ->
      coordinates = polygon.latLngs.getArray()[0].getArray()
      prepearedCoordinates = coordinates.map (coords) ->
        [ coords.lat(), coords.lng() ]

      alertName = $("#alert-name").val()
      if(alertName == "")
        alert("Enter alert name!")
        return

      alertEmails = $("#alert-emails").val()
      if(alertEmails == "")
        alert("Enter alert emails!")
        return

      $.post("/client_api/alerts",
        device_id: window.sharedVariables.deviceId
        name:      alertName,
        area:      prepearedCoordinates,
        emails:    alertEmails.split(',')
      ).done((data) ->
        $("#control-buttons").hide()
        alert("Saved!")
        return
      ).fail ->
        alert "Sometging going wrong, try to make zone without crossing lines"
        return


  drawingManager.setMap map

requestRoutes = (deviceId, map) ->
  window.sharedVariables.routes ||= []

  $.ajax(
    url: "/client_api/devices/#{deviceId}"
  ).done (data) ->
    for route in data
      window.sharedVariables.routes.push drawRouteOnMap(route.route, map, route.alert_notifications)

requestAlertAreas = (deviceId, map) ->
  window.sharedVariables.alerts = []
  $.ajax(
    url: "/client_api/alerts/?device_id=#{deviceId}"
  ).done (data) ->
    for area in data
      window.sharedVariables.alerts.push drawAlertOnMap(area.area, map, area.name)


initialize = ->
  return unless $('#map_canvas'); # return if no map canvas found

  window.sharedVariables.deviceId = $('#map_canvas').data('id')
  mapOptions =
    center: new google.maps.LatLng($('#map_canvas').data('lat'), $('#map_canvas').data('lng'))
    zoom: 13
    mapTypeId: google.maps.MapTypeId.ROADMAP

  map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)

  polygonEditor = initPolygonEditor(map)

  requestRoutes(window.sharedVariables.deviceId, map)
  requestAlertAreas(window.sharedVariables.deviceId, map)


$(document).ready ->

  google.maps.Polygon::getBounds = ->
    bounds = new google.maps.LatLngBounds()
    @getPath().forEach (element, index) ->
      bounds.extend element
      return

    bounds

  initialize()
