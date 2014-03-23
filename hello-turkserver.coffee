Colors = new Meteor.Collection("colors")

TurkServer.partitionCollection(Colors)

if Meteor.isClient
  Router.map ->
    @route('hello', {path: '/'})
    @route('exitsurvey')

  # Automatic paths for task
  Deps.autorun ->
    Router.go("/") if TurkServer.inExperiment()

  Deps.autorun ->
    Router.go("/exitsurvey") if TurkServer.inExitSurvey()

  Deps.autorun ->
    group = TurkServer.group()
    Meteor.subscribe("colors", group)

  Template.hello.prompt = ->
    switch TurkServer.treatment()
      when 'wording1' then "What are some colors you like?"
      when 'wording2' then "List 5 of the best colors."

  Template.hello.colors = -> Colors.find()

  Template.hello.events =
    "submit form": (e, tmpl) ->
      e.preventDefault()
      Colors.insert
        color: tmpl.find("input").value
    "click button": (e, tmpl) ->
      e.preventDefault()
      Meteor.call 'finish'

  Template.exitsurvey.events =
    "submit form": (e, tmpl) ->
      e.preventDefault()

      getValue = (name) -> tmpl.find("[name=#{name}]").value

      results =
        like: getValue('like')
        comments: getValue('comments')

      tmpl.find("button[type=submit]").disabled = true # Prevent multiple submissions

      TurkServer.submitExitSurvey(results)


if Meteor.isServer
  console.log()

  Meteor.publish "colors", ->
    return Colors.find()

  Meteor.methods
    finish: ->
      TurkServer.finishExperiment()
