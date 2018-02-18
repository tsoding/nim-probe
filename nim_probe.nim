import dom
import math
import html5_canvas
import colors
import strutils

const RADIUS = 50.0

type Point = tuple[x: float, y: float]

type State = tuple[position: Point,
                   direction: Point]

proc addPoints(p1: Point, p2: Point): Point =
  (x: p1.x + p2.x, y: p1.y + p2.y)

proc scalePoint(p: Point, f: float): Point =
  (p.x * f, p.y * f)

proc testRect(ctx: CanvasRenderingContext2D) =
  ctx.fillStyle = rgb(colDarkGreen)
  ctx.fillRect(10, 10.5, 125.5, 125)

proc cleanCanvas(ctx: CanvasRenderingContext2D) =
  ctx.fillStyle = rgb(colWhite)
  ctx.fillRect(0, 0,
               float(ctx.canvas.width),
               float(ctx.canvas.height))

proc renderState(ctx: CanvasRenderingContext2D,
                 state: State) =
  cleanCanvas(ctx)

  ctx.beginPath()
  ctx.arc(state.position.x,
          state.position.y,
          RADIUS, 0,
          2.0 * Pi,
          false)
  ctx.fillStyle = rgb(colDarkGreen)
  ctx.fill()

proc bounceWalls(ctx: CanvasRenderingContext2D,
                 position: Point,
                 direction: Point): Point =
    if position.x - RADIUS < 0.0 or position.x + RADIUS > float(ctx.canvas.width):
      (-direction.x, direction.y)
    elif position.y - RADIUS < 0.0 or position.y + RADIUS > float(ctx.canvas.height):
      (direction.x, -direction.y)
    else:
      direction

proc updateState(ctx: CanvasRenderingContext2D,
                 deltaTime: float,
                 state: State): State =
  let nextDirection = bounceWalls(ctx, state.position, state.direction)
  (addPoints(state.position,
             scalePoint(nextDirection, deltaTime / 1000.0)),
   nextDirection)

proc loopIteration(ctx: CanvasRenderingContext2D,
                   prevTimestamp: float,
                   currentTimestamp: float,
                   state: State) =

  renderState(ctx, state)
  let nextState = updateState(ctx,
                              currentTimestamp - prevTimestamp,
                              state);

  discard dom.window.requestAnimationFrame(
    proc (timestamp: float) = loopIteration(ctx,
                                            currentTimestamp,
                                            timestamp,
                                            nextState))
  
proc startLoop(ctx: CanvasRenderingContext2D) =
  discard dom.window.requestAnimationFrame(
    proc (timestamp: float) = loopIteration(ctx,
                                            0,
                                            timestamp,
                                            ((100.0, 100.0),
                                             (100.0, 100.0))))

when isMainModule:
  let canvas = document.getElementById("ayaya").Canvas
  let ctx = canvas.getContext2D()
  startLoop(ctx)
