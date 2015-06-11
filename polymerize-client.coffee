##
# Update Icons when WebComponentsReady
# See https://github.com/PolymerElements/iron-icons/issues/14
##
Meteor.startup ->
  window.addEventListener "WebComponentsReady", ->
    _.each document.querySelectorAll('[icon]'), (icon) ->
      icon._updateIcon() if typeof icon._updateIcon is 'function'
      
  # Setup a reactive variable for WebComponents Ready
  #ready = new ReactiveVar false
  #window.addEventListener "WebComponentsReady", ->
    #ready.set true

  #Delay Blaze.render until WebComponentsReady
  #render = Blaze.render
  #Blaze.render = ->
    #renderArgs = arguments
    #Tracker.autorun =>
      #render.apply(@, renderArgs) if ready.get()      