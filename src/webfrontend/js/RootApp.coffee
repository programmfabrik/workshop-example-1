class WorkshopRootApp extends RootMenuApp

	# Return true if the user is allowed to use this app.
	@is_allowed: ->
		true

	# Return the group name of the app. Used to group apps in the menu.
	@group: ->
		"workshop-group"

	# Return the label of the app. Used in the menu. See loca files, icon and text are defined there.
	@label: ->
		"workshop.app.label"

	# Should execute the app at start?
	@isStartApp: ->
		false

	# Return the path of the app. Used to build the url.
	@path: ->
		["workshop"]

	# Called when trying to unload the app. Here we can ask the user if he wants to close the app.
	# Or maybe we want to save some data before closing the app, or clean up some stuff.
	allow_unload: ->
		CUI.confirm(text: "Do you want to close the Workshop App?")

	# Called when the app is unloaded.
	unload: ->
		# We remove the content of the center slot of the rootLayout of the app.
		ez5.rootLayout.empty("center")
		super()


	load: ->
		super()
		# We get the plugin object from the pluginManager.
		@__plugin = ez5.pluginManager.getPlugin("workshop-example-1")

		itemList = new CUI.ItemList
			class: "workshop-example-itemlist"
			items: [
				active: true
				loca_key: "workshop-example-1.item1"
				onClick: =>
					@__showSimpleElements()
			,
				loca_key: "workshop-example-1.item2"
				onClick: =>
					@__showTemplate()
			,
				loca_key: "workshop-example-1.item3"
				onClick: =>
					@__showTemplateTwo()
			,
				loca_key: "workshop-example-1.item4"
				onClick: =>
					@__showConfig()
			]


		@__horizontalLayout = new CUI.HorizontalLayout
			left:
				class: "ez5-workshop-hl-left"
				content: itemList.render()

		ez5.rootLayout.replace(@__horizontalLayout, "center")

		return CUI.resolvedPromise()



	#Simple Lorem ipsum build with CUI elements.
	__showSimpleElements: ->
	# In this method we create html elements using the CUI library.
		title = new CUI.Label
			text: "Hello world"
		text = new CUI.Label
			text: "Lorem Ipsum Dolor Sit amet"
			multiline: true
		verticalListLayout = new CUI.VerticalList
			content: [
				title
				text
			]
		# We replace the content in the main Horizontal Layout to show our elements.
		@__horizontalLayout.replace(verticalListLayout, "center")



	__showTemplate: ->
	# In this method we use a html template and we directly inject it in the horizontalLayout
	# this is a nice solution if you want to have better control of the rendered html.
		htmlTemplate = new CUI.Template
			name: "workshop-template-1"
		@__horizontalLayout.replace(htmlTemplate, "center")



	__showTemplateTwo: ->
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

	__showConfig: ->
		config = ez5.session.getBaseConfig("plugin", "fylr-plugin-workshop")
		configDump = new CUI.ObjectDumper(object: config)
		@__horizontalLayout.replace(configDump, "center")




# This is the entry point of the app.
ez5.session_ready =>
	ez5.rootMenu.registerApp(WorkshopRootApp)
