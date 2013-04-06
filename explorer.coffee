###
Folk Tune Finder tune explorer!

Code for drawing keyboards, typesetting staves, plotting melody trees.

Copyright Joe Wass 2011 - 2013
joe@afandian.com
###
ACCIDENTAL =
  SHARP: 's'
  FLAT: 'f'
  NATURAL: 'n'

MIDDLE_C = 60

# Some music theory.
class Theory

  constructor : () -> 
    # The order of preference for black note labelling (D sharp vs E flat) is based on only using black notes for minor scales.
    @DIATONIC_DEGREES =
      0:  [{degree: 0, accidental: ACCIDENTAL.NATURAL}], # C      
      1:  [{degree: 0, accidental: ACCIDENTAL.SHARP}, {degree: 1, accidental: ACCIDENTAL.FLAT}], # C# / Db
      2:  [{degree: 1, accidental: ACCIDENTAL.NATURAL}], # D      
      3:  [{degree: 2, accidental: ACCIDENTAL.FLAT}, {degree: 1, accidental: ACCIDENTAL.SHARP}], # D# / Eb
      4:  [{degree: 2, accidental: ACCIDENTAL.NATURAL}], # E      
      5:  [{degree: 3, accidental: ACCIDENTAL.NATURAL}], # F      
      6:  [{degree: 3, accidental: ACCIDENTAL.SHARP}, {degree: 4, accidental: ACCIDENTAL.FLAT}], # F# / Gb
      7:  [{degree: 4, accidental: ACCIDENTAL.NATURAL}], # G      
      8:  [{degree: 4, accidental: ACCIDENTAL.SHARP}, {degree: 5, accidental: ACCIDENTAL.FLAT}], # G# / Ab
      9:  [{degree: 5, accidental: ACCIDENTAL.NATURAL}], # A      
      10: [{degree: 6, accidental: ACCIDENTAL.FLAT}, {degree: 5, accidental: ACCIDENTAL.SHARP}], # A# / Bb
      11: [{degree: 6, accidental: ACCIDENTAL.NATURAL}] # B      

    @DIATONIC_NOTE_NAMES = ["C", "D", "E", "F", "G", "A", "B"]
  
  # For a given pitch, return the position within the scale starting on the relativeTo.
  # Both numbers are MIDI pitches.
  # Return object of:
  # chromaticDegree: chromatic degree within the scale.
  # accidental: Natural or accidental
  # diatonicDegree: Diatonic degree of scale (0 - 11)
  # diatonicRelative: Diatonic degree of scale relative to note, may be positive or negative.
  positionRelativeToPitch : (givenPitch, relativeTo) ->
      # We need to produce something with a valid absolute value when compared to relativeTo,
      # which it wouln't if it had a lower value.
      # This seems a really stupid way to do it, but it works.
      # Am I being stupid?
      absPitch = givenPitch

      while absPitch < relativeTo
        absPitch += 12

      # The degree within the scale, 0 to 11
      degree = Math.abs((relativeTo-absPitch) % 12)

      # There are sharp/flat alternatives, but for now just get the first one that comes.
      diatonicDegree = @DIATONIC_DEGREES[degree][0].degree
      diatonicAccidental = @DIATONIC_DEGREES[degree][0].accidental

      relativeOctave = Math.floor((givenPitch - relativeTo) / 12)
      diatonicRelative = relativeOctave * 7 + diatonicDegree

      octave = Math.floor(givenPitch / 12)
      
      chromaticDegree: degree
      chromaticAbsolute: givenPitch
      diatonicDegree: diatonicDegree
      diatonicAccidental: diatonicAccidental
      diatonicRelative: diatonicRelative
      octave: octave
  

  noteName : (pitch) ->
      contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C)

      # Ignore sharp or flat hinting for now, take the first option.
      name = @DIATONIC_NOTE_NAMES[contextualDegree.diatonicDegree]

      name = name + if contextualDegree.diatonicAccidental == ACCIDENTAL.SHARP
        "#"
      else if contextualDegree.diatonicAccidental == ACCIDENTAL.FLAT
        "b"
      else
        ""

      name

# TODO singleton. Static methods?
theory = new Theory

# Observes a keyboard, draws on a drawing adaptor.
class KeyboardDrawer
  constructor : (@keyboard) ->
    
  # Draw on the adaptor.
  draw : (adaptor) ->
    adaptor.range(@keyboard.LOWEST_PITCH, @keyboard.HIGHEST_PITCH)

    for pitch in [@keyboard.LOWEST_PITCH..@keyboard.HIGHEST_PITCH]
      adaptor.key(pitch)

# An adaptor that draws the keyboard.
class KeyboardAdaptor


# A keyboard adaptor that draws on a canvas.
class CanvasKeyboardAdaptor extends KeyboardAdaptor
  constructor : (@keyboardDrawer, @WHITE_NOTE_WIDTH, @BLACK_NOTE_WIDTH, @WHITE_NOTE_HEIGHT, @BLACK_NOTE_HEIGHT) -> 
    
    # Black note offset from corresponding white note, sharp and flat.
    @BLACK_NOTE_OFFSET_S = @WHITE_NOTE_WIDTH - @BLACK_NOTE_WIDTH / 2
    @BLACK_NOTE_OFFSET_F = - @BLACK_NOTE_WIDTH / 2

  # Set the keyboard range.
  range: (lowestPitch, highestPitch) ->
    @lowestPitch = lowestPitch
    @highestPitch = highestPitch

  draw : (graphicsContext) ->
    # Draw the keyboard. As the code is single-threaded, no need to create a context object,
    # context represented as properties on `this`.

    # TODO This assumes that the context may change. Depending on how I clear the canvas, 
    # we may have a persistent context object removing the need to store it each draw call.
    # Make the context available (may be different for each call).
    @graphicsContext = graphicsContext
    
    # Ask to be drawn twice. First time draw the white notes, second. 
    @drawCallbackmode = 0
    @keyboardDrawer.draw(this)
    @drawCallbackmode = 1
    @keyboardDrawer.draw(this)

  # Callback.
  key : (pitch) -> 
    # @graphicsContext set by draw()

    contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C)

    # Called twice. First time, drawCallbackmode == 0, draw white notes.
    # Next time draw black notes, on top.

    octaveOffset = (contextualDegree.octave * 7  * @WHITE_NOTE_WIDTH)
    if @drawCallbackmode == 0 && contextualDegree.diatonicAccidental == ACCIDENTAL.NATURAL 
      @graphicsContext.fillStyle = "rgba(240, 240, 240, 1)"
      @graphicsContext.strokeStyle = "rgba(10, 10, 10, 1)"
      @graphicsContext.lineWidth = 1

      x = octaveOffset + contextualDegree.diatonicDegree * @WHITE_NOTE_WIDTH
      @graphicsContext.fillRect(x, 0, @WHITE_NOTE_WIDTH, @WHITE_NOTE_HEIGHT)
      @graphicsContext.strokeRect(x, 0, @WHITE_NOTE_WIDTH, @WHITE_NOTE_HEIGHT)
    else if contextualDegree.diatonicAccidental == ACCIDENTAL.SHARP
      # Black note
      @graphicsContext.fillStyle = "rgba(10, 10, 10, 1)"
      @graphicsContext.strokeStyle = "rgba(40, 40, 40, 1)"
      @graphicsContext.lineWidth = 4

      x = octaveOffset + contextualDegree.diatonicDegree * @WHITE_NOTE_WIDTH
      @graphicsContext.fillRect(x + @BLACK_NOTE_OFFSET_S, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)
      @graphicsContext.strokeRect(x + @BLACK_NOTE_OFFSET_S, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)

    else if contextualDegree.diatonicAccidental == ACCIDENTAL.FLAT
      # Black note
      @graphicsContext.fillStyle = "rgba(10, 10, 10, 1)"
      @graphicsContext.strokeStyle = "rgba(40, 40, 40, 1)"
      @graphicsContext.lineWidth = 4

      x = octaveOffset + (contextualDegree.diatonicDegree  + 1) * @WHITE_NOTE_WIDTH
      @graphicsContext.fillRect(x + @BLACK_NOTE_OFFSET_F, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)
      @graphicsContext.strokeRect(x + @BLACK_NOTE_OFFSET_F, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)
    

###

# A keyboard adaptor that creates HTML elements.
class ElementKeyboardAdaptor extends KeyboardAdaptor
  constructor : (@keyboard, @$container, @WHITE_NOTE_WIDTH, @BLACK_NOTE_WIDTH, @WHITE_NOTE_HEIGHT, @BLACK_NOTE_HEIGHT) ->

    @$container.css("height", @WHITE_NOTE_HEIGHT)
    @$container.parent().css("height", @WHITE_NOTE_HEIGHT)

    @BLACK_HINT = 1
    @BLACK_NOTE_OFFSET = @WHITE_NOTE_WIDTH - (@BLACK_NOTE_WIDTH / 2)

  # Draw the keyboard!
  draw : () ->
    @x = 0
    @keyboard.draw(this)


  # Draw a key. Callback from draw().
  key : (pitch) -> 
        contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C)

        $key = $("<div></div>")
        $key.css("position", "absolute")
        $key.css("top", 0)
        $key.css("cursor", "hand")

        $key_label = $("<div></div>")
        $key_label.css("position", "absolute")
        $key_label.css("bottom", "0px")

        $key_label.css("-webkit-user-select", "none")
        $key_label.css("-khtml-user-select", "none")
        $key_label.css("-moz-user-select", "none")
        $key_label.css("-o-user-select", "none")
        $key_label.css("user-select", "none")

        $key_label.css("text-align", "center")
        $key_label.css("cursor", "hand")

        if contextualDegree.diatonicAccidental == ACCIDENTAL.NATURAL
          @x = @x + @WHITE_NOTE_WIDTH
          $key.css("background-color", "white")
          $key.css("color", "black")
          $key.css("border", "1px solid #e0e0e0")
          $key.css("height", @WHITE_NOTE_HEIGHT)
          $key.css("width", @WHITE_NOTE_WIDTH)
          $key.css("left", @x)
          $key.css("z-index", 1)

          $key_label.css("width", @WHITE_NOTE_WIDTH)
        else
          # Black note
          $key.css("background-color", "black")
          $key.css("color", "white")
          $key.css("border", "1px solid #a0a0a0")
          $key.css("height", @BLACK_NOTE_HEIGHT)
          $key.css("width", @BLACK_NOTE_WIDTH)

          $key.css("-webkit-border-bottom-right-radius", "4px")
          $key.css("-webkit-border-bottom-left-radius", "4px")
          $key.css("-moz-border-radius-bottomright", "4px")
          $key.css("-moz-border-radius-bottomleft", "4px")
          $key.css("border-bottom-right-radius", "4px")
          $key.css("border-bottom-left-radius", "4px")

          $key.css("z-index", 2)

          if contextualDegree.chromaticDegree == 6 || contextualDegree.chromaticDegree == 1
              $key.css("left", (@x + @BLACK_NOTE_OFFSET) + @BLACK_HINT)
          else if contextualDegree.chromaticDegree == 10 || contextualDegree.chromaticDegree == 3
              $key.css("left", (@x + @BLACK_NOTE_OFFSET) - @BLACK_HINT)
          else
              $key.css("left", @x + @BLACK_NOTE_OFFSET)

        $key_label.css("width", @BLACK_NOTE_WIDTH)

        $key_label.html(theory.noteName(pitch))
        $key.append($key_label)

        @$container.append($key)

###
  
# A keyboard
class Keyboard
  constructor: (@LOWEST_PITCH, @HIGHEST_PITCH) ->


class Context
  constructor: (@renderer) -> 
    @renderer.render

  run: () -> 
    @renderer.renderLoop()

  tick: () -> 
    

class CanvasRenderer
  constructor: (@canvas, @keyboardDrawAdaptor) ->
    @canvasSize()

    @requestFrame = (() -> 
      return window.requestAnimationFrame       ||
      window.webkitRequestAnimationFrame ||
      window.mozRequestAnimationFrame    ||
      () -> window.setTimeout(callback, 1000 / 60))()

  canvasSize: () -> 
    @canvas.width = window.innerWidth
    @canvas.height = window.innerHeight
    @context = @canvas.getContext("2d")

    window.addEventListener('resize', @canvasSize, false)

  render: () -> 
    # Clear context.
    # Unclear about efficiency of this vs width = width.
    @context.save();
    @context.setTransform(1, 0, 0, 1, 0, 0);
    @context.clearRect(0, 0, @canvas.width, @canvas.height);
    @context.restore();

    #@canvas.width = @canvas.width
    @keyboardDrawAdaptor.draw(@context)
    

  renderLoop: =>
    @render()
    @requestFrame.call(window, @renderLoop)

keyboard = new Keyboard(0, 127)
keyboardDrawer = new KeyboardDrawer(keyboard)

# For HTML element keyboard.
#$container = $("<div></div>")
#$("body").append($container)
#elementKeyboardDrawer = new ElementKeyboardAdaptor(keyboardDrawer, $container, 40, 25, 100, 50)
#elementKeyboardDrawer.draw()


# For canvas drawing.

canvas = document.getElementById("canvas")
adaptor = new CanvasKeyboardAdaptor(keyboardDrawer, 20, 8, 100, 50)
renderer = new CanvasRenderer(canvas, adaptor)
context = new Context(renderer)
context.run()