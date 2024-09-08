import { RouterPath } from '../constant/RouterPath';
import { DownloadManager } from '../download/DownloadManager';
import { DLog } from '../util/DLog';
import { faceDetector } from '@kit.CoreVisionKit';
import { common } from '@kit.AbilityKit';
import { statfs } from '@kit.CoreFileKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { it } from '@ohos/hypium';

const testUrl = 'https://www.python.org/ftp/python/3.12.5/python-3.12.5-amd64.exe' //26508648
const testUrl1 =
  'https://download.ifonts.com/app-installer/desktop/iFonts-Win-2.5.4.exe?attname=iFonts-Win-2.5.4-00ji9w.exe&v=3434994575&sign=5042e29ef3e2c43227faa8b6275676ab&t=66dd1551'//75294016
const MAX_DOWNLOAD = 2

@Component
@Entry({ routeName: RouterPath.DownloadPage })
export struct DownloadPage {
  private context = getContext()
  private manager = DownloadManager.getInstance()
  @State list: Array<Item> = new Array()
  @State isPause: boolean = false
  private index = 1

  aboutToAppear(): void {
  }

  init() {
    for (let i = this.index; i < this.index + 5; i++) {
      let item = new Item('task ' + i, testUrl, '')
      this.list.push(item)
    }
    this.index += 5
    this.startDownload()
  }

  startDownload() {
    for (let i = 0; i < MAX_DOWNLOAD; i++) {
      if (i < this.list.length) {
        this.downloadItem(this.list[i])
      }
    }
  }

  lastName = ''

  getPath() {
    let name = new Date().toLocaleTimeString()
    if (this.lastName == name) { //名字唯一
      name = name + ' 1'
    }
    this.lastName = name
    return getContext()!!.filesDir + '/download/' + name
  }

  downloadItem(item: Item) {
    if (item.isDownloading != undefined && item.isDownloading) {
      return
    }
    item.isDownloading = true
    item.path = this.getPath()
    item.name = item.name + ':' + item.path.substring(item.path.lastIndexOf('/') + 1, item.path.length)
    this.manager.download(this.context, item.url, item.path, (result: boolean, progress: request.agent.Progress) => {
      if (!result) {
        DLog.error('downloadItem error:' + item.name, 'DownloadManager')
        item.isDownloading = false
        item.isError = true
        this.downNext()
        return
      }
      item.curSize = progress.processed
      item.progress = item.curSize / item.totalSize * 100
      DLog.info(item.name + ' callback ' + item.curSize + ' ' + item.progress + ' ' + progress.sizes, 'DownloadManager')
      if (item.curSize >= item.totalSize) {
        let index = this.list.findIndex((value: Item) => {
          return value.name == item.name
        })
        item.isDownloading = false
        this.list.splice(index, 1)
        this.downNext()
      }
    }, false, true)
  }

  downNext() {
    for (let i = 0; i < this.list.length; i++) {
      let item = this.list[i]
      if (!item.isDownloading && !item.isError) {
        this.downloadItem(item)
        break
      }
    }
  }

  delTask() {
    if (this.list.length > 0) {
      this.manager.startOrPause(true)
      let item = this.list[0]
      this.manager.deleteTask(item.path)
      this.list.splice(0, 1)
      this.manager.startOrPause(false)
    }
    this.startDownload()
  }

  startOrPause() {
    this.manager.startOrPause(this.isPause)
  }

  private fontColor = Color.Black

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceEvenly }) {
        Text('Add')
          .fontSize(28)
          .fontColor(Color.Red)
          .onClick(() => {
            this.init()
          })

        Text('Del')
          .fontSize(28)
          .fontColor(Color.Red)
          .onClick(() => {
            this.delTask()
          })
      }

      Column() {
        Text(this.isPause ? '全部开始' : '全部暂停')
          .fontSize(16)
          .margin({ left: 12, top: 10 })
          .fontColor(this.fontColor)
          .onClick(() => {
            this.isPause = !this.isPause
            this.startOrPause()
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
    .padding({ top: 5, bottom: 5 })
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
    if (size > 1014 * 1024) {
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
        if (this.item.isDownloading) {
          Text(`缓存中: ${this.getSize(this.item.curSize)}/${this.getSize(this.item.totalSize)}`)
            .fontSize(12)
            .fontColor(Color.Gray)
        } else {
          Text(`等待下载...`)
            .fontSize(12)
            .fontColor(Color.Gray)
        }
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
  constructor(name: string, url: string, path: string) {
    this.name = name
    this.url = url
    this.path = path
  }

  path: string = ''
  name: string = ''
  url: string = ''
  totalSize: number = 26508648
  curSize: number = 0
  progress: number = 0
  isDownloading: boolean = false
  isError: boolean = false
}