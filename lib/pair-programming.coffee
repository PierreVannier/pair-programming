{CompositeDisposable} = require 'event-kit'
fs     = require 'fs'
path   = require 'path'
WebSocket = require('ws')
heroes  = require './utils'

module.exports =
  config:
    twitterHandle:
      type: 'string'
      default: "Enter your twitter name here if you don't want to have a silly name"
      description: "This will just allow us to have your name and picture :-)"

    githubName:
      type: 'string'
      default: "Do you really want to be called id-2390903 ?"
      description: "Aren't programmer supposed to have a github?"

  activate: (state) ->
    atom.workspaceView.command "pair-programming:turnOn", => @turnOn()
    atom.workspaceView.command "pair-programming:deactivate", => @deactivate()

  turnOn: ->
    console.log("Activate")
    @initSocket()
    @initEventListeners()
    @status = true
    @toggleStatusBarDecoration()
    @initIdentity()

  initIdentity: ->
    twit = atom.config.get('pair-programming.twitterHandle')
    git = atom.config.get('pair-programming.githubName')
    @twitterHandle = if twit == "Enter your twitter name here if you don't want to have a silly name" then @chooseDefaultStupidId() else twit
    @githubName = if git == "Aren't programmer supposed to have a github?" then @chooseDefaultStupidId() else git

  chooseDefaultStupidId: ->
    hero = heroes()[Math.floor((Math.random() * heroes().length))-1]
    console.log(hero)
    hero

  initEventListeners: ->
    @editorListeners = new CompositeDisposable
    @editorListeners.add atom.workspace.onDidChangeActivePaneItem (pane) =>
      @actForPaneChange(pane)
    for editor in atom.workspace.getTextEditors()
      @editorListeners.add editor.onDidChangeScrollTop (event) =>
        @actForViewPointChange(event)
      @editorListeners.add editor.buffer.onDidChange (event) =>
        @actForBufferChange(event)

  initSocket: ->
    @ws = new WebSocket("ws://gearhunt.net:8080/#{@randomName()}")
    @ws.on 'close', =>
      console.log("Server closed socket")
      @deactivate()
    @ws.on 'open', =>
      console.log("Connected")
    @ws.on 'error', (error) =>
      console.log("#{error}")
      @deactivate()
    @ws.on 'message', (message) =>
      @treatServerMessage(message)


  toggleStatusBarDecoration: ->
    atom.workspaceView.statusBar?.find('.watched-buffer').remove()
    atom.workspaceView.statusBar?.appendLeft('<span class="watched-buffer"><img src="atom://pair-programming/bundle/owl-16.png"/>&nbsp;Owl is watching...</span>') if @status


  randomName: ->
    console.log("In randomName")
    planet = ["Mercury",	"Venus", "Earth",	"Mars",	"Jupiter","Saturn", "Uranus", "Neptune"]
    randPlanet = planet[Math.floor((Math.random() * 7))]
    title = @activeTextEditor().getTitle()
    randPlanet

  treatServerMessage: (message) ->
    msg = JSON.parse(message)
    console.log(msg)

  activeTextEditor: ->
    atom.workspace.getActiveTextEditor()


  actForPaneChange: (pane) ->
    console.log("Change active pane")
    @sendData({grammar:@activeTextEditor().getGrammar().packageName.split("-")[1]
              , changeType: "text"
              , text: @activeTextEditor().buffer.getText()})

  actForBufferChange: (event) ->
    @sendData({grammar:@activeTextEditor().getGrammar().name
              , changeType: "text"
              , text: @activeTextEditor().buffer.getText()})


  actForViewPointChange: (event) ->
    totalHeightForBuffer = @activeTextEditor().pixelPositionForBufferPosition([@activeTextEditor().getLineCount(),0])
    totalHeightForBuffer = if totalHeightForBuffer.top == 0 then 1 else totalHeightForBuffer.top
    @sendData({changeType: "viewPoint", ratio: (event / totalHeightForBuffer) * 100})


  sendData: (data) ->
    @ws.send JSON.stringify data

  deactivate: ->
    console.log 'deactivate()'
    @status = false
    @toggleStatusBarDecoration()
    @editorListeners.dispose() if typeof @editorListeners != "undefined"
    @ws.close() if typeof @ws != "undefined" && @ws.readyState != WebSocket.OPEN
