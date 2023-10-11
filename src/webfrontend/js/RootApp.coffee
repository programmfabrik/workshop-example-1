class WorkshopRootApp extends RootMenuApp
  @is_allowed: ->
    true

  @group: ->
    "workshop-group"

  @label: ->
    "workshop.app.label"

  @isStartApp: ->
    false

  @path: ->
    ["workshop"]

  allow_unload: ->
    CUI.confirm(text: "Do you want to close the Workshop App?")

  unload: ->
    ez5.rootLayout.empty("center")
    super()



  load: ->
    super()

    @__plugin = ez5.pluginManager.getPlugin("workshop-example-1")

    itemList = new CUI.ItemList
      class: "workshop-example-itemlist"
      items: [
        active: true
        loca_key: "workshop-example-1.item1"
        onClick: =>
          @showSimpleElements()
      ,
        loca_key: "workshop-example-1.item2"
        onClick: =>
          @showTemplate()
      ,
        loca_key: "workshop-example-1.item3"
        onClick: =>
          @showTemplateTwo()
      ,
        loca_key: "workshop-example-1.item4"
        onClick: =>
          @showMap()
      ]

    itemList.render()

    @__horizontalLayout = new CUI.HorizontalLayout
      left:
        class: "ez5-workshop-hl-left"
        content: itemList

    ez5.rootLayout.replace(@__horizontalLayout, "center")

    return CUI.resolvedPromise()



#Simple Lorem ipsum build with CUI elements.
  showSimpleElements: ->
    # In this method we create html elements using the CUI library.
    title = new CUI.Label
      text: "Hello world"
    text = new CUI.Label
      text: "Lorem Ipsum Dolor Sit amet"
      multiline: true
    verticalListLayout = new CUI.VerticalList
      class: "asdadsaas"
      content: [
        title
        text
      ]
    # We replace the content in the main Horizontal Layout to show our elements.
    @__horizontalLayout.replace(verticalListLayout, "center")



  showTemplate: ->
    # In this method we use a html template and we directly inject it in the horizontalLayout
    # this is a nice solution if you want to have better control of the rendered html.
    htmlTemplate = new CUI.Template
      name: "workshop-template-1"
    @__horizontalLayout.replace(htmlTemplate, "center")



  showTemplateTwo: ->
    inputData = {}
    htmlTemplate = new CUI.Template
      name: "workshop-template-2"
      map:
        slot1: true
        slot3: true
    htmlTemplate.map.slot1.append(new CUI.Label(text: "Lorem Ipsum"))
    htmlTemplate.map.slot3.append(new CUI.Button
      text: "A button"
      onClick: ->
        CUI.confirm(text: "Hello im a button!")
    )
    @__horizontalLayout.replace(htmlTemplate, "center")


  showMap: ->
    staticMarkers = [
      position:
        lat: 52.520645
        lng: 13.409779
      cui_onClick: (ev) -> alert(CUI.util.dump(ev.target.options.position))
    ,
      position:
        lat: 52.534078
        lng: 13.410464
      title: 'A'
      cui_onClick: (ev) -> alert(CUI.util.dump(ev.target.options.position))
    ,
      position:
        lat: 52.515691
        lng: 13.387249
      title: 'B'
      cui_onClick: (ev) -> alert(CUI.util.dump(ev.target.options.position))
    ]
    map = new CUI.LeafletMap
      class: "workshop-map"
      clickable: false,
      zoomToFitAllMarkersOnInit: true,
      onClick: =>
        console.log "Click"
      onReady: =>
        console.log "Map init"
    map.addMarkers(staticMarkers)
    @__horizontalLayout.replace(map, "center")
    @__searchForGeoObjects().done( (markers) =>
      if markers and markers.length > 0
        map.addMarkers(markers)

    )

  __searchForGeoObjects: ->
    #This method search in the db all objects
    #We create a deferred object so we can work async here.
    dfr = new CUI.Deferred()

    locationFieldByObjecttype = {} #Here we will store all the fields for location, the key will be the objecttype
    validObjecttypes = [] #Here we will store the objecttypes with one or more location fields

    #For each objecttype on the system we search for valid columns.
    console.log "Objecttypes with columns data:", ez5.schema.CURRENT._objecttype_by_name
    for objecttypeName, objecttype of ez5.schema.CURRENT._objecttype_by_name
      for column in objecttype.columns
        #We find fields that are of type of our custom data type "Location", this is a custom data type (plugin)
        if column.type == "custom:base.custom-data-type-location.location"
          if not locationFieldByObjecttype[objecttypeName]
            locationFieldByObjecttype[objecttypeName] = []
            validObjecttypes.push(objecttypeName)
          locationFieldByObjecttype[objecttypeName].push(column.name)

    #Now we have a js object with each objecttype that has a field for location and the name of these fields
    console.log locationFieldByObjecttype

    #All the api endpoints in ez5 and fylr live in ez5.api so we can use the search api for searching objects.
    ez5.api.search(
      data:
        debug: "WorkShopDebug" #This is dummy text added to the request so we can find easily using network tab.
      json_data:
        type: "object"
        objecttypes: validObjecttypes
        format: "long"
        offset: 0
        limit: 1000
        search: []
    ).done((data) =>
      #The search finished we can do something with the data and resolve the deferred object.
      if data?.count == 0
        dfr.resolve()

      markers = []
      # We iterate all the returned object and check the fields that we know that had location data.
      # maybe the objects returned dont have data in the field.
      for object in data.objects
        locationFields = locationFieldByObjecttype[object._objecttype]
        for locationField in locationFields
          #The field data is stored in a property with the name of the objecctype.
          location = object[object._objecttype][locationField]
          #If we found data from one field included in locationFieldByObjecttype then we have a location with geo data
          if location
            markers.push(location.mapPosition)

      dfr.resolve(markers)
    )

    #We return the promise of the deferred object
    return dfr.promise()


ez5.session_ready =>
  ez5.rootMenu.registerApp(WorkshopRootApp)