import { RouterPath } from '../constant/RouterPath';
import { DownloadManager } from '../download/DownloadManager';
import { DLog } from '../util/DLog';

const  testUrl = 'http://www.cr-soft.top/softs/crvideomate.rar'
@Component
@Entry({ routeName: RouterPath.DownloadPage })
export struct DownloadPage {
  private context = getContext()
  private manager = new DownloadManager()
  @State list: Array<Item> = new Array()
  @State isPause: boolean = false
  private index = 1

  aboutToAppear(): void {
  }

  init() {
    for (let i = this.index; i < this.index + 15; i++) {
      let item = new Item('task ' + i, testUrl)
      this.list.push(item)
    }
    this.index += 15
    this.downloadItem(this.list[0])
    //this.downloadItem(this.list[1])
  }

  downloadItem(item: Item) {
    if (item.isDownloading != undefined && item.isDownloading) {
      return
    }
    item.isDownloading = true
    this.manager.download(this.context, item.url, (result: boolean, processed: number) => {
      if (!result) {
        DLog.error('error:' + item.name, 'DownloadManager')
        item.isDownloading = false
        this.downNext()
        return
      }
      item.curSize = processed
      item.progress = item.curSize / item.totalSize * 100
      //DLog.info('callback ' + item.curSize + ' ' + item.progress, 'DownloadManager')
      if (item.curSize >= item.totalSize) {
        let index = this.list.findIndex((value: Item) => {
          return value.name == item.name
        })
        item.isDownloading = false
        this.list.splice(index, 1)
        this.downNext()
      }
    })
  }

  downNext() {
    for (let i = 0; i < this.list.length; i++) {
      let item = this.list[i]
      if (!item.isDownloading) {
        this.downloadItem(item)
        break
      }
    }
  }

  private fontColor = Color.Black

  build() {
    Column() {
      Text('add down')
        .fontSize(28)
        .fontColor(Color.Red)
        .onClick(() => {
          this.init()
        })
      Column() {
        Text(this.isPause ? '全部开始' : '全部暂停')
          .fontSize(16)
          .margin({ left: 12, top: 10 })
          .fontColor(this.fontColor)
          .onClick(() => {
            this.isPause = !this.isPause
            this.manager.pauseTask(this.isPause)
          })
        List() {
          ForEach(this.list, (item: Item) => {
            ListItem() {
              ListItemComponent({
                item: item
              })
            }
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .backgroundColor(Color.White)
    }
    .backgroundColor('#f2d9d0d0')
    .padding({ top: 50 })
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }
}

@Component
struct ListItemComponent {
  @ObjectLink item: Item

  aboutToAppear(): void {
  }

  getSize(size: number): string {
    if (size > 2014 * 1024) {
      return Math.floor(size / 1024 / 1024) + 'M'
    } else if (size > 1024) {
      return Math.floor(size / 1024) + 'K'
    }
    return Math.floor(size) + 'B'
  }

  build() {
    Row() {
      Image($r('app.media.app_icon'))
        .width(80)
        .height(60)
        .margin({ right: 12 })
      Column() {
        Text(this.item.name)
          .fontSize(14)
          .fontColor(Color.Black)
        Blank().layoutWeight(1)
        Text(`缓存中: ${this.getSize(this.item.curSize)}/${this.getSize(this.item.totalSize)}`)
          .fontSize(12)
          .fontColor(Color.Gray)
        Progress({ value: this.item.progress, total: 100, type: ProgressType.Linear })
          .layoutWeight(1)
          .style({ enableSmoothEffect: false })
      }.alignItems(HorizontalAlign.Start)
      .height(60)
      .layoutWeight(1)
    }.width('100%')
    .height(80)
    .padding({ left: 12, right: 12 })
  }
}

@Observed
class Item {
  constructor(name: string, url: string) {
    this.name = name
    this.url = url
  }

  name: string = ''
  url: string = ''
  totalSize: number = 46820821
  curSize: number = 0
  progress: number = 0
  isDownloading: boolean = false
}