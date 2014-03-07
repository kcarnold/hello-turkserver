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

  Template.hello.colors = -> Colors.find()

  Template.hello.events =
    "submit form": (e, tmpl) ->
      e.preventDefault()
      Colors.insert
        color: tmpl.find("input").value

if Meteor.isServer
  console.log()

  Meteor.publish "colors", ->
    return Colors.find()