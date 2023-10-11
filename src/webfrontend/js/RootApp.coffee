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

		itemList.render()

		@__horizontalLayout = new CUI.HorizontalLayout
			left:
				class: "ez5-workshop-hl-left"
				content: itemList

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
