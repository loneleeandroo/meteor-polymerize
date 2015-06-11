##
# Update Icons when WebComponentsReady
# See https://github.com/PolymerElements/iron-icons/issues/14
##
Meteor.startup ->
  window.addEventListener "WebComponentsReady", (e) ->
    _.each document.querySelectorAll('[icon]'), (icon) ->
      icon._updateIcon() if typeof icon._updateIcon is 'function'