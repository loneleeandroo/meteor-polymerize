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
    @dispatchEvent new Event('resize') # Manually trigger the resize event
    ready.set true

  ##
  # Allows use of iron-form by recreating them
  ##
  render = Blaze.render
  Blaze.render = ->
    render.apply(@, arguments)
    Tracker.afterFlush ->
      ironForms = document.querySelectorAll('form[is="iron-form"]')

      _.each ironForms, (oldForm) ->
        newForm = document.createElement('form', 'iron-form')

        # Copy all attributes
        _.each oldForm.attributes, (attribute) ->
          newForm.setAttribute attribute.name, attribute.value

        # Copy all child nodes
        while oldForm.childNodes.length > 0
          newForm.appendChild oldForm.childNodes[0]

        # Replace old form with new form
        oldForm.parentNode.replaceChild(newForm, oldForm)  

  # render = Blaze.render
  # Blaze.render = ->
  #   renderArgs = arguments
  #   Tracker.autorun =>
  #     render.apply(@, renderArgs) if ready.get()
              
  ##
  # Destroy node fix for ShadyDOM
  ##            
  # destroyNode = Blaze._destroyNode 
  # Blaze._destroyNode = ->
  #   node = arguments[0]
  #   destroyNode.apply(@, arguments)
  #   node.offsetParent.removeChild(node)