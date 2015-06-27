Meteor.startup ->   
  ##
  # Write Local DOM using ShadowDOM instead of ShadyDOM
  ##
  @Polymer = @Polymer or {}
  @Polymer.dom = 'shadow'

  ##
  # Defers Blaze.Render until after WebComponentsReady
  # so that Polymer Icons render correctly
  # See https://github.com/PolymerElements/iron-icons/issues/14
  ##
  ready = new ReactiveVar false
  window.addEventListener "WebComponentsReady", ->
    ready.set true

  render = Blaze.render
  Blaze.render = ->
    renderArgs = arguments
    Tracker.autorun =>
      render.apply(@, renderArgs) if ready.get()
              
  ##
  # Destroy node fix for ShadyDOM
  ##            
  # destroyNode = Blaze._destroyNode 
  # Blaze._destroyNode = ->
  #   node = arguments[0]
  #   destroyNode.apply(@, arguments)
  #   node.offsetParent.removeChild(node)