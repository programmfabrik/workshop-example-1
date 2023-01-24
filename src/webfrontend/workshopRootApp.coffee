class WorkshopRootApp extends RootMenuApp
  @is_allowed: ->
  true

  @group: ->
    "zzz_zexample"

  @label: ->
    "example.app.label"

  @isStartApp: ->
    false

  @path: ->
    ["example"]

  allow_unload: ->
  CUI.confirm(text: "Do you want to close the Workshop App?")

  unload: ->
    ez5.rootLayout.empty("center")
    super()

  load: ->
    super()

    @__plugin = ez5.pluginManager.getPlugin("workshop-example-1")

    itemList = new CUI.ItemList
      items: [
        active: true
        loca_key: "workshop-example-1.item1"
        onclick: =>
          console.log "Foo"
      ,
        loca_key: "workshop-example-1.item1"
        onclick: =>
          console.log "Var"
      ]

    itemList.render()

    @__hl = new CUI.HorizontalLayout
      left:
        class: "ez5-workshop-hl-left"
        content: itemList

    ez5.rootLayout.replace(@__hl, "center")

    return CUI.resolvedPromise()

ez5.session_ready =>
  ez5.rootMenu.registerApp(WorkshopRootApp)