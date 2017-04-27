$ ->
  Tic =
    data:
      turns: 0
      x: {}
      o: {}
      gameOver: false

    initialize: ->
      @data.gameOver = false
      @setPlayerNames()
      @assignRoles()
      @prepareBoard()
      @updateNotifications()
      @addListeners()

    setPlayerNames: ->
      @data.player1 = $("input[name='pl-1']").val()
      @data.player2 = $("input[name='pl-2']").val()

    getPlayerName: (symbol) ->
      name = if @data.rolep1 == symbol then @data.player1 else @data.player2
      return name

    prepareBoard: ->
      $("form").hide()
      $("#board").empty()
      $(".alerts").removeClass("welcome").show()
      $(".alerts").text("#{@getPlayerName("X")} Goes First")
      $("<div>", {class: "square"}).appendTo("#board") for square in [0..8]

    assignRoles: ->
      roles = ["X","O"].sort(->
        return 0.5 - Math.random()
      )
      @data.rolep1 = roles[0]
      @data.rolep2 = roles[1]

    updateNotifications: ->
      $(".notifications").empty().show()

    addNotification: (msg) ->
      $(".notifications").append($("<p>", {text: msg}))

    addListeners: ->
      $(".square").click ->
        if Tic.data.gameOver is no and not $(@).text().length
          if Tic.data.turns % 2 is 0 then $(@).html("X").addClass("x moved")
          else if Tic.data.turns % 2 isnt 0 then $(@).html("O").addClass("o moved")
          Tic.data.turns++
          Tic.checkEnd()
          if Tic.data.gameOver isnt yes and $(".moved").length >= 9 then Tic.checkTie("none")

    checkEnd : ->
      @data.x = {}
      @data.o = {}

      #diagonal check
      diagonals = [[0,4,8], [2,4,6]]
      for diagonal in diagonals
        for col in diagonal
          @checkField(col, 'diagonal')
        @checkWin()
        @emptyStorageVar('diagonal')
      for row in [0..2]
        start = row * 3
        end = (row * 3) + 2
        middle = (row * 3) + 1

      #vertical check
      @checkField(start, 'start')
      @checkField(middle, 'middle')
      @checkField(end, 'end')
      @checkWin()

      # horizontal check
      for column in [start..end]
        @checkField(column, 'horizontal')
      @checkWin()
      @emptyStorageVar('horizontal')


    checkField: (field, storageVar) ->
      if $(".square").eq(field).hasClass("x")
        if @data.x[storageVar]? then @data.x[storageVar]++ else @data.x[storageVar] = 1
      else if $(".square").eq(field).hasClass("o")
        if @data.o[storageVar]? then @data.o[storageVar]++ else @data.o[storageVar] = 1

    checkWin: ->
      for key,value of @data.x
        if value >= 3
          localStorage.x++
          $('#won').text("#{@getPlayerName("X")} wins")
          modal.style.display = "block";
          @data.gameOver = true
          @checkTie("X")
      for key,value of @data.o
        if value >= 3
          localStorage.o++
          $('#won').text("#{@getPlayerName("O")} wins")
          modal.style.display = "block";
          @data.gameOver = true
          @checkTie("O")

    checkTie: (winner) ->
      @data.turns = 0
      @data.x = {}
      @data.o = {}
      @data.gameOver = yes
      if winner is "none"
        $('#won').text("It's a tie!")
        modal.style.display = "block";
      @updateNotifications()
      $(".notifications").append "<a class='play-again'>Play Again?</a>"

    emptyStorageVar: (storageVar) ->
      @data.x[storageVar] = null
      @data.o[storageVar] = null

    showAlert: (msg) ->
      $(".alerts").text(msg).slideDown()

  $("form").on "submit", (evt) ->
    evt.preventDefault()
    $inputs = $("input[type='text']")

    namesNotEntered = $inputs.filter(->
      return @value.trim() isnt ""
    ).length isnt 2

    namesIndentical = $inputs[0].value is $inputs[1].value

    if namesNotEntered then Tic.showAlert("Player names cannot be empty")
    else if namesIndentical then Tic.showAlert("Player names cannot be identical")
    else Tic.initialize()

  $("body").on("click",".play-again", -> Tic.initialize())

  modal = document.getElementById('myModal')
  btn = document.getElementById("myBtn")
  span = document.getElementsByClassName("close")[0]

  span.onclick = ->
    modal.style.display = "none"

  window.onclick = (event) ->
    if event.target == modal
      modal.style.display = "none"
