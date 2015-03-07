{CompositeDisposable} = require 'event-kit'
fs     = require 'fs'
path   = require 'path'
WebSocket = require('ws')
heroes  = require './utils'

module.exports =
  config:
    handle:
      type: "string"
      default: ""
      description: "We choose this if you don't provide neither a twitter nor a github"

    twitter:
      type: "string"
      default: ""
      description: "Your twitter name"

    github:
      type: 'string'
      default: ""
      description: "Your GitHub name"

  #helper, just returns a timestamp for logging purpose
  now: ->
    (new Date()).toString().split(' ').splice(2,3).join(' ')

  activate: (state) ->
    atom.workspaceView.command "pair-programming:turnOn", => @turnOn()
    atom.workspaceView.command "pair-programming:turnOff", => @turnOff()

  #socket should be defined and connected to be online
  isOnline: ->
    typeof(@ws) != "undefined" && @ws.readyState == 1

  turnOn: ->
    console.log("#{@now()} Starting turnOn")
    @chooseHandle()
    @initSocket()
    @initEventListeners()
    @toggleStatusBarDecoration()

  convertToSlug: (text) ->
    rand = Math.floor((Math.random() * 100000))
    return text.toLowerCase().replace(" ","-").replace(/[^\w-]+/g,"")+"-"+rand

  chooseHandle: ->
    @handle = atom.config.get('pair-programming.twitter') unless @handle
    @handle = atom.config.get('pair-programming.github') unless @handle
    if @handle == ""
      @handle = @convertToSlug( heroes()[Math.floor((Math.random() * (heroes().length-1)))] )
    atom.config.set('pair-programming.handle', @handle)
    console.log("#{@now()} #{@handle}")

  initEventListeners: ->
    console.log("#{@now()} Creating/Adding listeners")
    @editorListeners = new CompositeDisposable
    @editorListeners.add atom.workspace.onDidChangeActivePaneItem (pane) =>
      @actForPaneChange(pane)
    for editor in atom.workspace.getTextEditors()
      @editorListeners.add editor.onDidChangeScrollTop (event) =>
        @actForViewPointChange(event)
      @editorListeners.add editor.buffer.onDidChange (event) =>
        @actForBufferChange(event)

  initSocket: ->
    console.log("#{@now()} Starting sockets and connections")
    channel = "ws://gearhunt.net:8080/#{@handle}"
    @ws = new WebSocket(channel)
    @ws.on 'close', =>
      console.log("#{@now()} Server closed socket")
      @deactivate()
    @ws.on 'open', =>
      console.log("#{@now()} Connected")
    @ws.on 'error', (error) =>
      console.log("#{@now()} #{error}")
      @deactivate()
    @ws.on 'message', (message) =>
      @treatServerMessage(message)

  toggleStatusBarDecoration: ->
    atom.workspaceView.statusBar?.find('.watched-buffer').remove()
    atom.workspaceView.statusBar?.find('.watchers').remove()
    atom.workspaceView.statusBar?.appendLeft('<span class="watched-buffer"><img src="atom://pair-programming/bundle/owl-16.png"/></span>') if @isOnline()

  treatServerMessage: (message) ->
    console.log("#{@now()} Got some messages from the server...")
    msg = JSON.parse(message)
    switch msg.changeType
      when "watchers"
        @updateWatchersCount(msg.watchers)
      when "hello"
        @actForPaneChange(0, {twitter: atom.config.get('pair-programming.twitter')
                              ,github: atom.config.get('pair-programming.github')})

  updateWatchersCount: (count) ->
    atom.workspaceView.statusBar?.find('.watchers').remove()
    atom.workspaceView.statusBar?.appendLeft('<span class="watchers">'+count+'</span>')

  activeTextEditor: ->
    atom.workspace.getActiveTextEditor()

  #TODO get twitter and github pic of user
  getPic: (options) ->
    image = ""
    if options.type == "github"
      true
    if options.type == "twitter"
      true
    image

  actForPaneChange: (pane, options={}) ->
    activeTextEditor = @activeTextEditor()
    twitterPic = @getPic({handle:options.twitter, type:"twitter"}) || ""
    githubPic = @getPic({handle:options.github, type:"github"}) || ""
    @sendData({grammar:activeTextEditor.getGrammar().packageName.split("-")[1]
              , changeType: "text"
              , text: activeTextEditor.buffer.getText()}) if typeof activeTextEditor != "undefined"

  actForBufferChange: (event) ->
    @sendData({grammar:@activeTextEditor().getGrammar().name
              , changeType: "text"
              , text: @activeTextEditor().buffer.getText()})


  actForViewPointChange: (event) ->
    totalHeightForBuffer = @activeTextEditor().pixelPositionForBufferPosition([@activeTextEditor().getLineCount(),0])
    totalHeightForBuffer = if totalHeightForBuffer.top == 0 then 1 else totalHeightForBuffer.top
    @sendData({changeType: "viewPoint", ratio: (event / totalHeightForBuffer) * 100})

  sendData: (data) ->
    @ws.send?( JSON.stringify(data) ) if @isOnline()

  deactivate: ->
    console.log("#{@now()} deactivate()")
    @turnOff()

  turnOff: ->
    console.log("#{@now()} TurnOff")
    @ws.close?()
    @editorListeners.dispose?()
    @toggleStatusBarDecoration()
