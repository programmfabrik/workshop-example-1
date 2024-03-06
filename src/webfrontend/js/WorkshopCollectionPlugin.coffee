class WorkshopCollectionPlugin extends CollectionPlugin

  # This is the only method we have to override on CollectionPlugin class
  # This method is executed every time we change the selection of objects, or if we
  # deselect the current selection.
  getCurrentTools: (collection) ->
    try
      objects = collection.getObjects()


    catch e
      console.warn("Get Objects fail", e)
    if not objects or objects?.length == 0
       # We dont have any object selected, we dont show the tool (context menu option)
       # so we return an empty array.
      return []
    tools = []

    exampleOne = new ToolboxTool
      group: collection.getToolGroup()
      name: "example-plugin-tool" # Internal name of the tool, this is used for localization of the label and icon , see l10n/example-filepicker-example.csv for example.
      sort: "I:1" # Allow sorting the different tools.
      favorite: true # This make the tool visible on the toolbox on the top of the main search. IF false then the tool is only visible on the context menu
      run: =>
        # This function is called when the tool is executed.
        # The $$ is our localization method shortcut, in this case I send an object with the number of objects, see the csv for see how this value is used in the string localized
        # On our documentation you can find all the variations for localize strings.
        CUI.alert(text: $$("example-plugin-tool-msg", object_number: objects.length))
    tools.push(exampleOne)

    # In this second example we can see how we can add tools to a tool coverting this in a group tool, for this we
    # simply need to add the subtools in the tools property.
    exampleTwo = new ToolboxTool
      group: collection.getToolGroup()
      name: "example-plugin-tool-group"
      sort: "I:2"
      favorite: true
      tools: [
        # We return an array with two tools
        new ToolboxTool
          name: "example-plugin-tool-group-1"
          run: =>
            # This one execute an alert
            CUI.alert(text:"This is an example of a custom tool inside another tool, you have selected #{objects.length} objects.")
      ,
        new ToolboxTool
          name: "example-plugin-tool-group-2"
          run: =>
            # In this one we show a modal window so as we need a lot more code we use a class method for running this tool.
            @__runModalExample(objects)
      ,
        new ToolboxTool
          name: "example-plugin-tool-group-3"
          run: =>
            @__runModalEASExample(objects)
      ]
    tools.push(exampleTwo)

    return tools

  # This method is used to show an example of how to build a simple modal window when we call this method.
  __runModalExample: (objects) ->

    # Local function for construct a table with the uuids of the objects selected.
    getTableContent = =>
      table = new CUI.Table
        class: "ez5-metadata-browser-group"
        flex: true
        key_value: true
      # The objects array contain each element selected but this elements are wrapped in a CollectionObject class
      for collectionObject in objects
        object = collectionObject.getObject()
        table.addRow(
          key: "UUID"
          value: object._uuid
        )
      return table

    # We create the cancel button for the modal window
    _cancelButton = new CUI.Button
      text: "Cancel"
      onClick: =>
        _modal.destroy()

    # Send Button, this button will execute an XHR request to an api endpoint.
    _sendButton = new CUI.Button
      text: "Send"
      primary: true
      onClick: =>
        _cancelButton.disable()
        _sendButton.disable()

        apiXHR = new CUI.XHR
          method: "POST"
          url: "https://run.mocky.io/v3/c61c3f9c-0edf-4eaa-b090-57f9400e42a8"
        # Once the xhr is done we show an alert with the message given by the server, the response contain a JSON
        # object with all the json data returned by the server.
        apiXHR.start().done( (response) =>
          alert = new CUI.Alert(text: "Server response: #{response.message}")
          alert.open().done( =>
            # When we click ok in the alert we close the modal.
            _modal.destroy()
          )
        )

    # We create the modal window.
    _modal = new CUI.Modal
      pane:
        header_left: new LocaLabel(loca_key: "example-modal-title")
        content: [
          new CUI.Label(text: "Here is a list of the uuid's of the selected objects:")
        ,
          getTableContent()
        ]
        footer_right: [
          _cancelButton
        ,
          _sendButton
        ]
    _modal.show()

  __runModalEASExample: (collectionObjects) ->
    # This method is used to show an example of how to build a simple modal with the objects images from standard
    _modal = new CUI.Modal
      pane:
        header_left: new LocaLabel(loca_key: "example-modal-title")
        content: [
          new CUI.Label(text: "Here is an example on how to load images from the objects:")
        ]
        footer_right: [
           new CUI.Button
            text: "Done"
            onClick: =>
              _modal.destroy()
        ]
    _modal.show()

    # Here we start to load the images from the objects

    easIds = [] # Variable to store the images ids
    for collectionObject in collectionObjects
      # WE have a group of collectionObjects we need to get the object from each one
      object = collectionObject.getObject()
      # We get the standard images from the object, if any, this are the images that are configured to be shown in the object thumbnail
      standardImages = object?._standard?.eas?[1]
      for image in standardImages
        # WE make sure they are images
        if image.class == "image"
          # We store the id of the image
          easIds.push(image._id)
    # Now we have the ids of all standard images we are going to use the EAS api to get the urls of the images.
    # On the standard data we have already the preview and small versions, but if we want bigger versions we need to get
    # the data from the EAS api.
    ez5.api.eas(
      type: "GET"
      data:
        ids: JSON.stringify(easIds)
        format: "long"
    ).done( (data) =>
      # We have the data from the EAS api, now we are going to create the img elements and append them to the modal window.
      # for each image we create a new AssetPlain object and get the img element from it.
      # This method handle the creation of the img element and the url for the image. including token and other stuff for authentication.
      # But inside the data we have all the image information, including the urls so feel free to use the data in other ways.
      for id, value of data
        assetPlain = new AssetPlain(value: value)
        wrapperDiv = new CUI.dom.div("example-image-wrapper")
        imgElement = assetPlain.getImgElement(null, "original")
        CUI.dom.append(wrapperDiv, imgElement)
        _modal.append(wrapperDiv)
      return
    )
    return



# We register the plugin when the app is initialized
ez5.session_ready ->
  Collection.registerPlugin(new WorkshopCollectionPlugin())
