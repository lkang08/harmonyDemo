import { RouterPath } from '../constant/RouterPath';
import { DownloadManager } from '../download/DownloadManager';
import { DLog } from '../util/DLog';
import { faceDetector } from '@kit.CoreVisionKit';
import { common } from '@kit.AbilityKit';
import { statfs } from '@kit.CoreFileKit';
import { BusinessError, request } from '@kit.BasicServicesKit';

const  testUrl = 'https://www.python.org/ftp/python/3.12.5/python-3.12.5-amd64.exe'
const testUrl1 = 'http://dl.ehome.21cn.com/oos/fileDownload?appKey=deviceCloud&timeStamp=1725416424686&version=v1.0&format=json&cid=1018&paras=2CE3F7C0044A37894211E01B91F097FAA92B6A788637A9ED3F8DEE3CAE6C6B778009139F27E21A666A9D75EAB0C0407DCEB1E1C14F6B2C9064C566B6AB2FAE11A3E5AFC714E1C1B0F9968F8054451B9DF230DBE878E3B763FFDE854C0B923FA139C82EC0EC5D6BBD4466C3CF157EB9C35448002AB161205E7BCA7E0DAE2FA383450FC85948504BB7D5E5C5BB&appSignature=iHZ309qjhRm0i0MsbP/bOLMqvmw='
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
    for (let i = this.index; i < this.index + 4; i++) {
      let item = new Item('task ' + i, testUrl)
      this.list.push(item)
    }
    this.index += 4
    this.downloadItem(this.list[0])
    //this.downloadItem(this.list[1])
    this.getSize()
  }

  getSize() {
    let context = getContext(this) as common.UIAbilityContext;
    let path = context.filesDir;
    statfs.getTotalSize(path).then((number: number) => {
      console.info("getTotalSize succeed, Size: " + number); //1009074044928
    }).catch((err: BusinessError) => {
      console.error("getTotalSize failed with error message: " + err.message + ", error code: " + err.code);
    });
    statfs.getFreeSize(path, (err: BusinessError, number: number) => {
      if (err) {
        console.error("getFreeSize failed with error message: " + err.message + ", error code: " + err.code);
      } else {
        console.info("getFreeSize succeed, Size: " + number); //987471425536
      }
    });
  }

  getPath() {
    let date = new Date()
    return getContext()!!.filesDir + '/download/' + date.toTimeString()
  }

  downloadItem(item: Item) {
    if (item.isDownloading != undefined && item.isDownloading) {
      return
    }
    item.isDownloading = true
    let path = this.getPath()
    this.manager.download(this.context, item.url, path, (result: boolean,  progress: request.agent.Progress) => {
      if (!result) {
        DLog.error('error:' + item.name, 'DownloadManager')
        item.isDownloading = false
        item.isError = true
        this.downNext()
        return
      }
      item.curSize = progress.processed
      item.progress = item.curSize / item.totalSize * 100
      DLog.info('callback ' + item.curSize + ' ' + item.progress + ' ' + progress.sizes, 'DownloadManager')
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

  private fontColor = Color.Black

  build() {
    Column() {
      Text('add down:')
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
            this.manager.startOrPause(this.isPause)
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
  constructor(name: string, url: string) {
    this.name = name
    this.url = url
  }

  name: string = ''
  url: string = ''
  totalSize: number = 60713155
  curSize: number = 0
  progress: number = 0
  isDownloading: boolean = false
  isError: boolean = false
}