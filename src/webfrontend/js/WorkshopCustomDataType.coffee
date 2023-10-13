
###

  Sample custom data type for Workshop, this is a super simple example
  where the user can enter two numbers on editor mode
  and the sum of them is displayed in detail mode.

###

class WorkshopCustomDataType extends CustomDataType

	getCustomDataTypeName: ->
		"custom:workshop.custom.data.type"

	getCustomDataOptionsInDatamodelInfo: (custom_settings) ->
		[]

	initData: (data) ->
		if not data[@name()]
			data[@name()] = {}

	renderDetailOutput: (data, top_level_data, opts) ->
		cdata = data[@name()]
		value = cdata.field_one + cdata.field_two

		new CUI.Label
			text: value

	renderEditorInput: (data, top_level_data, opts) ->
		@initData(data)
		cdata = data[@name()]

		form = new CUI.Form
			data: cdata
			fields: [
				form:
					label: "Numeric value 1"
				type: CUI.NumberInput
				name: "field_one"
			,
				form:
					label: "Numeric value 2"
				type: CUI.NumberInput
				name: "field_two"
			]
			onDataChanged: =>
				CUI.Events.trigger
					node: form
					type: "editor-changed"
		return form.start()

	getSaveData: (data, save_data, opts) ->
		cdata = data[@name()]
		save_data[@name()] = CUI.util.copyObject(cdata, true)
		return

CustomDataType.register(WorkshopCustomDataType)


