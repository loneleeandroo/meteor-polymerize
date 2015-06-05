##
# Delay Blaze.render until WebComponentsReady
##
Meteor.startup ->

	# Store the Blaze.render function
	render = Blaze.render

	# Temporarily disable the Blaze.render function
	Blaze.render = -> return

	# When "WebComponentsReady" is fired
	window.addEventListener "WebComponentsReady", ->

		# Re-enable the Blaze.render function
		Blaze.render = render

		# Render Template.body to document
		Template.body.renderToDocument()