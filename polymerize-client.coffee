##
# Defers Blaze.Render until after WebComponentsReady
# so that Polymer Icons render correctly
# See https://github.com/PolymerElements/iron-icons/issues/14
##
Meteor.startup ->
  #window.addEventListener "WebComponentsReady", ->
    #_.each document.querySelectorAll('[icon]'), (icon) ->
      #icon._updateIcon() if typeof icon._updateIcon is 'function'
      
  ready = new ReactiveVar false
  window.addEventListener "WebComponentsReady", ->
    ready.set true

  render = Blaze.render
  Blaze.render = ->
    renderArgs = arguments
    Tracker.autorun =>
      render.apply(@, renderArgs) if ready.get()

  destroyNode = Blaze._destroyNode 
  Blaze._destroyNode = ->
    node = arguments[0]
    destroyNode.apply(@, arguments)
    node.offsetParent.removeChild(node)
