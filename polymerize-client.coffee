##
# Delay Blaze.render until WebComponentsReady
##
Meteor.startup ->

  # Setup a reactive variable for WebComponents Ready
  ready = new ReactiveVar false
  window.addEventListener "WebComponentsReady", ->
    ready.set true

  # Rerun Blaze.render when WebComponents is ready
  render = Blaze.render
  Blaze.render = ->
    renderArgs = arguments
    Tracker.autorun =>
      render.apply(@, renderArgs) if ready.get()