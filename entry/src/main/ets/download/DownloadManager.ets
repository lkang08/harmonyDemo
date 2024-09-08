import { BusinessError, request } from '@kit.BasicServicesKit';
import { Context } from '@ohos.arkui.UIContext';
import { DLog } from '../util/DLog';

class DownloadTask {
  task: request.agent.Task
  path: string

  constructor(path: string, task: request.agent.Task) {
    this.path = path
    this.task = task
  }
}

export class DownloadManager {
  private downloadingTask: Array<DownloadTask> = [] //支持取消的task

  private constructor() {
  }

  private static instance: DownloadManager = new DownloadManager()

  static getInstance() {
    return DownloadManager.instance
  }

  log(msg: string) {
    DLog.debug(msg, 'DownloadManager')
  }

  deleteTask(path: string) {
    if (path.length == 0) {
      return
    }
    let index = this.downloadingTask.findIndex((task) => {
      return path == task.path
    })
    if (index >= 0) {
      this.log('deleteTask ' + path)
      let del = this.downloadingTask.splice(index, 1)
      del[0].task.stop((err: BusinessError) => {
        if (err) {
          this.log(`deleteTask fail,tid=${del[0].task?.tid} Code: ${err.code}, message: ${err.message}`);
          return;
        }
        this.log(`deleteTask Succeeded tid:${del[0].task?.tid}}`);
      })
    }
  }

  startOrPause(isPause: boolean) {
    this.log('startOrPause isPause=' + isPause + ' ' + this.downloadingTask.length)
    this.downloadingTask.forEach((ts) => {
      if (isPause) {
        ts.task?.pause((err: BusinessError) => {
          if (err) {
            this.log(`startOrPause fail,tid=${ts.task?.tid} Code: ${err.code}, message: ${err.message}`);
            return;
          }
          this.log(`startOrPause Succeeded in pausing a download task. `);
        });
      } else {
        ts.task?.resume((err: BusinessError) => {
          if (err) {
            this.log(`startOrPause fail,tid=${ts.task?.tid} Code: ${err.code}, message: ${err.message}`);
            return;
          }
          this.log(`startOrPause Succeeded in resuming a download task. `);
        });
      }
    })
  }

  /**
   *
   * @param context
   * @param url
   * @param callback
   * @param gauge false代表仅完成或失败的通知 true发出每个进度已完成或失败的通知
   * @param canPause 是否可以暂停，云存中的下载任务可以暂停
   */
  download(context: Context, url: string, path: string,
    callback?: (result: boolean, progress: request.agent.Progress) => void,
    gauge: boolean = false, canPause: boolean = false) {
    this.log('download begin path:' + path)
    let config: request.agent.Config = {
      action: request.agent.Action.DOWNLOAD,
      url: url,
      overwrite: true,
      method: 'GET',
      //保存的地址，默认为cache目录下，如果需要保存在子目录下需要提前手动创建。
      //saveas: './',
      saveas: path,
      mode: request.agent.Mode.BACKGROUND,
      gauge: gauge,
      priority: 0
    }
    let name=path.substring(path.lastIndexOf('/') + 1, path.length)
    request.agent.create(context, config).then((task: request.agent.Task) => {
      console.log(task.tid)
      let progressCallback = (progress: request.agent.Progress) => {
        this.log('##Manager name:' + name+ ' ,progress:' + progress.processed + '/' + progress.sizes + ' ,tid:' + task.tid);
        if (callback) {
          callback(true, progress)
        }
      };

      let completedCallback = (progress: request.agent.Progress) => {
        let index = this.downloadingTask.findIndex((value) => {
          return value.task!.tid == task.tid
        })
        if (index >= 0) {
          this.downloadingTask.splice(index, 1)
        }
      };

      let failedCallback = (progress: request.agent.Progress) => {
        this.log('download task failed: ' + progress);
        let index = this.downloadingTask.findIndex((value) => {
          return value.task!.tid == task.tid
        })
        if (index >= 0) {
          this.downloadingTask.splice(index, 1)
        }
        if (callback) {
          callback(false, progress)
        }
      };
      task.on('progress', progressCallback);
      task.on('failed', failedCallback);
      task.on('completed', completedCallback);
      if (canPause) {
        this.downloadingTask.push(new DownloadTask(path, task))
      }
      task.start((err: BusinessError) => {
        if (err) {
          this.log(`Failed to start the download task, Code: ${err.code}, message: ${err.message}`);
          return;
        }
        this.log(`Succeeded in starting a download task tid:${task.tid}`);
      });
    }).catch((err: BusinessError) => {
      this.log(`Failed to create a download task, Code: ${err.code}, message: ${err.message}`);
    });
  }
}