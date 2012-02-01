
views = NS "Pahvi.views"
helpers = NS "Pahvi.helpers"

roundNumber = (num, dec) ->
  Math.round(num*Math.pow(10,dec))/Math.pow(10,dec)

class views.Upload extends Backbone.View

  className: "uploadStatus"

  @allowedTypes = 
    "image/jpeg": true
    "image/png": true

  constructor: (options) ->
    super
    @$el = $ @el
    {@file} = options
    @status = "starting"

    source  = $("#uploadTemplate").html()
    @template = Handlebars.compile source

  start: ->

    # Small image. Show it immediately in browser
    if @file.size < 1400000
      reader = new FileReader()
      reader.onload = =>
        @model.set imgSrc: reader.result, { local: true }
        @_upload true
      reader.readAsDataURL @file
    else
      # Huge images can chrash the browser. Send it first to server
      console.log "Huge image! #{ @file.size }"
      @_upload false

  _upload: (delaySet) ->
    fd = new FormData
    fd.append "imagedata", @file
    xhr = new XMLHttpRequest

    started = Date.now()
    @status = "uploading"

    xhr.upload.onprogress = (e) =>
      @loaded = e.loaded / 1024
      @total = e.totalSize / 1024
      @speed = e.loaded / ((Date.now() - started) / 1000) / 1024

      if e.loaded >= e.totalSize - 1
        @status = "Resizing"
      console.log "Uploading image: #{ e.loaded } / #{ e.totalSize }", @speed
      @render()

    xhr.onreadystatechange = (e) =>
      if xhr.readyState is xhr.DONE
        res = JSON.parse xhr.response
        if res.error
          alert "Error while saving image: #{ res.error }"
          @error = res.error
          @trigger "uploaderror", @model, res.error, xhr
        else
          @trigger "uploaddone", @model, res.url
          if delaySet
            helpers.loadImage res.url,  =>
              @model.set imgSrc: res.url
          else
            @model.set imgSrc: res.url

    xhr.open "POST", "/upload"
    xhr.send fd

  render: ->
    @$el.html @template
      loaded: roundNumber @loaded, 2
      total: roundNumber @total, 2
      speed: roundNumber @speed, 2
      error: @error
      status: @status

  renderToBody: ->
    @render()
    @$el.appendTo "body"


