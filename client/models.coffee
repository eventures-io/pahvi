

models = NS "Pahvi.models"



class models.Boxes extends Backbone.Collection

  constructor: ->
    super

  comparator: (box) ->
    console.log "comparing"
    -1 * parseInt box.get "zIndex"


class LocalStore extends Backbone.Model

  constructor: ->
    super

    if localStorage[@get("name")]?
      @attributes = JSON.parse localStorage[@get("name")]

    @bind "change", => @save()

  save: ->
    localStorage[@get("name")] = JSON.stringify @attributes



class models.Settings extends Backbone.Model
  defaults:
    mode: "edit"
    hover: null

class models.TextBoxModel extends LocalStore

  type: "text"

  defaults:
    name: "Text Box"
    top: "100px"
    left: "100px"
    zIndex: 100
    text: "TextBox sample content"



