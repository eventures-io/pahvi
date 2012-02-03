
views = NS "Pahvi.views"



class views.Menu extends Backbone.View


  constructor: ({@settings}) ->
    super
    @$el = $ @el

    @settings.bind "change:mode", => @render()


  events:
    "click button.modeToggle": "toggle"


  toggle: ->
    if @settings.get("mode") is "edit"
      @settings.set mode: "presentation"
    else
      @settings.set mode: "edit"

  render: ->

    ob = modeName: "Unkown mode"

    if @settings.get("mode") is "edit"
      ob.modeName = "Switch to presentation mode"

    if @settings.get("mode") is "presentation"
      ob.modeName = "Switch to edit mode"

    @$el.html @renderTemplate "topmenu", ob



