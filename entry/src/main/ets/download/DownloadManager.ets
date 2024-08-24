import { BusinessError, request } from '@kit.BasicServicesKit';
import { Context } from '@ohos.arkui.UIContext';
import { DLog } from '../util/DLog';

export class DownloadManager {
  private downloadingTask: Array<request.agent.Task> = []

  pauseTask(isPause: boolean) {
    this.downloadingTask.forEach((task) => {
      if (isPause) {
        task.pause((err: BusinessError) => {
          if (err) {
            this.log(`Failed to pause the download task, Code: ${err.code}, message: ${err.message}`);
            return;
          }
          this.log(`Succeeded in pausing a download task. `);
        });
      } else {
        task.resume((err: BusinessError) => {
          if (err) {
            this.log(`Failed to resume the download task, Code: ${err.code}, message: ${err.message}`);
            return;
          }
          this.log(`Succeeded in resuming a download task. `);
        });
      }
    })
  }

  log(msg: string) {
    DLog.debug(msg, 'DownloadManager')
  }

  download(context: Context, url: string, callback?: (result: boolean, processed: number) => void) {
    this.log('download begin')
    let config1: request.agent.Config = {
      action: request.agent.Action.DOWNLOAD,
      url: url,
      overwrite: true,
      method: 'GET',
      //保存的地址，默认为cache目录下，如果需要保存在子目录下需要提前手动创建。
      saveas: './',
      mode: request.agent.Mode.BACKGROUND,
      gauge: true, //false：代表仅完成或失败的通知
      priority: 0
    }
    request.agent.create(context, config1).then((task: request.agent.Task) => {
      console.log(task.tid)
      let createOnCallback2 = (progress: request.agent.Progress) => {
        //this.log('download task pro.' + progress.sizes + '/' + progress.processed);
        if (callback) {
          callback(true, progress.processed)
        }
      };

      let createOnCallback = (progress: request.agent.Progress) => {
        this.log('downloadTask complete,filesDir:');
        let index = this.downloadingTask.findIndex((value) => {
          return value.tid == task.tid
        })
        if (index >= 0) {
          this.downloadingTask.splice(index, 1)
        }
      };

      let createOnCallback1 = (progress: request.agent.Progress) => {
        this.log('download task failed.' + progress);
        let index = this.downloadingTask.findIndex((value) => {
          return value.tid == task.tid
        })
        if (index >= 0) {
          this.downloadingTask.splice(index, 1)
        }
        if (callback) {
          callback(false, 0)
        }
      };

      let responseCallback = (response: request.agent.HttpResponse) => {
        this.log('download task response.' + JSON.stringify(response) + JSON.stringify(response.headers));
      };
      task.on('progress', createOnCallback2);
      task.on('failed', createOnCallback1);
      task.on('completed', createOnCallback);
      task.on('response', responseCallback)
      this.downloadingTask.push(task)
      task.start((err: BusinessError) => {
        if (err) {
          console.error(`Failed to start the download task, Code: ${err.code}, message: ${err.message}`);
          return;
        }
        this.log(`Succeeded in starting a download task.`);
      });
      this.log(`Succeeded in start a download task. result: ${task.tid}`);
    }).catch((err: BusinessError) => {
      console.error(`Failed to create a download task, Code: ${err.code}, message: ${err.message}`);
    });
  }
}
