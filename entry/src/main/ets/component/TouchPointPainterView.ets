@Component
export struct TouchPointPainterView {
  @Link @Watch('updateDraw') touchPoint: FingerInfo
  @Link videoHeight: number
  squareSize: number = 22
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  updateDraw() {
    this.context.clearRect(0, 0, 380, this.videoHeight)

    this.context.beginPath()
    this.context.strokeStyle = Color.White
    this.context.setLineDash([4, 8])
    this.context.lineWidth = 2

    let path2Db = new Path2D()
    path2Db.moveTo(this.touchPoint.localX, this.touchPoint.localY - this.squareSize / 2)
    path2Db.lineTo(this.touchPoint.localX, 0)
    path2Db.moveTo(this.touchPoint.localX, this.touchPoint.localY + this.squareSize / 2)
    path2Db.lineTo(this.touchPoint.localX, this.videoHeight)

    path2Db.moveTo(this.touchPoint.localX - this.squareSize / 2, this.touchPoint.localY)
    path2Db.lineTo(0, this.touchPoint.localY)
    path2Db.moveTo(this.touchPoint.localX + this.squareSize / 2, this.touchPoint.localY)
    path2Db.lineTo(380, this.touchPoint.localY)

    this.context.stroke(path2Db)
    this.context.setLineDash([4, 0])
    this.context.strokeRect(this.touchPoint.localX - this.squareSize / 2, this.touchPoint.localY - this.squareSize / 2,
      this.squareSize, this.squareSize)
  }

  build() {
    if (this.touchPoint.id != -1) {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.updateDraw()
        })
        .hitTestBehavior(HitTestMode.None)
    }
  }
}