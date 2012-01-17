
models = NS "Example.models"
views = NS "Example.views"


requireMode = (mode) -> (method) -> ->
  if @settings.get("mode") is mode
    return method.apply @, arguments
  else
    undefined


class views.Layers extends Backbone.View

  className: "layers"

  constructor: ->
    super
    source  = $("#layersTemplate").html()
    @template = Handlebars.compile source

    @collection.bind "add", => @render()

  events:
    "sortupdate": "update"

  update: (e, ui) ->
    console.log "Short update", ui.item

    for cid, index in @sortable.sortable "toArray"
      model = @collection.getByCid cid
      if not model
        continue
      model.set zIndex: index + 1000

  render: ->
    $(@el).html @template
      boxes: @collection.map (m) ->
        cid: m.cid
        name: m.get "name"


    @sortable = @$("ul").sortable()



class views.TextBox extends Backbone.View


  className: "box textBox"

  constructor: ({@settings, position}) ->
    super

    source  = $("#textboxTemplate").html()
    @template = Handlebars.compile source

    @model.bind "change", => @render()

    @settings.bind "change:mode", =>
      if @settings.get("mode") is "presentation"
        @_endDrag()
        @_endEdit()
      if @settings.get("mode") is "edit"
        @startDrag()


    $(window).click (e) =>
      if $(e.target).has(@el).size() > 0
        @_offClick(e)

  events:
    "click .edit": "startEdit"
    "dblclick": "startEdit"
    "click .delete": "remove"
    "click": "zoom"
    "click button.up": "up"
    "click button.down": "down"
    "dragstop": "saveEdit"



  up: ->
    $(@el).css "z-index", parseInt(@getZIndex(), 10) + 1
    @saveEdit()

  down: ->
    $(@el).css "z-index", parseInt(@getZIndex(), 10) - 1
    @saveEdit()

  getZIndex: ->
    $(@el).css "z-index"


  zoom: requireMode("presentation") ->
    $(@el).zoomTo()


  _offClick: (e) ->
    console.log "off"

    if @settings.get("mode") is "edit"
      @startDrag()
      @saveEdit()

    if @settings.get("mode") is "presentation"
      $("body").zoomTo
        targetSize: 1.0


  startEdit: requireMode("edit") ->
    @_endDrag()
    # @edit.bind "halloactivated", -> console.log "ACTIVEW"
    # @edit.attr "contenteditable", true
    # alert 23234
    # @edit.hallo
    #   editable: true
    #   plugins:
    #     halloformat: {}

    $("span", @el).hallo
      editable: true
      plugins:
        halloformat: {}

    @edit.focus()
    console.log "Start edit", @edit

  _endEdit: ->
    # @edit.removeAttr "contenteditable"
    # @edit.hallo editable: false
    console.log "End edit"
    @edit.blur()
    $("span", @el).hallo
      editable: false
      plugins:
        halloformat: {}


  startDrag: requireMode("edit") ->
    @_endEdit()
    $(@el).draggable
      cursor: "pointer"

    console.log "Dragging"


  saveEdit: ->

    @model.set
      left: $(@el).css "left"
      top: $(@el).css "top"
      zIndex: @getZIndex()
      text: @$(".content span").html()
    ,
      silent: true

    @model.save()
    console.log "saved", @model.attributes


  _endDrag: ->
    $(@el).draggable("destroy")
    console.log "end drag"

  render: ->

    $(@el).html @template
      text: @model.get "text"

    $(@el).css "z-index",  @model.get "zIndex"
    $(@el).css
      left: @model.get "left"
      top: @model.get "top"

    @edit = @$(".content span")




class views.Menu extends Backbone.View

  events:
    "click button.modeToggle": "toggle"

  constructor: ({@settings}) ->
    super

    source  = $("#topmenuTemplate").html()
    @template = Handlebars.compile source

    @settings.bind "change:mode", => @render()


  toggle: ->
    if @settings.get("mode") is "edit"
      @settings.set mode: "presentation"
    else
      @settings.set mode: "edit"

  render: ->

    ob = modeName: "Unkown mode"

    if @settings.get("mode") is "edit"
      ob.modeName = "Switch to presentation mode"
      $("body").removeClass "presentation"
      $("body").addClass "edit"

    if @settings.get("mode") is "presentation"
      ob.modeName = "Switch to edit mode"
      $("body").addClass "presentation"
      $("body").removeClass "edit"


    $(@el).html @template ob



