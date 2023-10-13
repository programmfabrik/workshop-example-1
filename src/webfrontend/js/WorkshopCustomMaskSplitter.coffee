class WorkshopCustomMaskSplitter extends CustomMaskSplitter

	isSimpleSplit: ->
		true

	renderField: (opts) ->
		data = opts.data
		console.log "WorkshopCustomMaskSplitter.renderField opts: ", opts
		return new CUI.VerticalList
			class: "workshop-custom-mask-splitter"
			content: [
				new CUI.Label(text: "This objects has and id of #{data._id} and the version is #{data._version}")
				new CUI.Label({
						text: "Unsplash random photo"
					})
				@__getRandomPhoto()
				@__getVanillaJsText()
			]

	__getRandomPhoto: ->
		# Get the href for a random photo from the Unsplash API
		photoSrc = "https://source.unsplash.com/random/800x600"
		# Create a new image element with the src using the CUI library
		img = CUI.dom.element("img", src: photoSrc)
		CUI.dom.addClass(img, "workshop-example-random-photo")
		# Return the image element
		return img

	__getVanillaJsText: ->
		


MaskSplitter.plugins.registerPlugin(WorkshopCustomMaskSplitter)

