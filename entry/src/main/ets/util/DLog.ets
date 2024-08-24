import hilog from '@ohos.hilog'

/**
 * 日志打印工具类
 * */
export class DLog {
  protected static mTag: string = "SLinkApp"
  protected static mDomain: number = 0x0000
  protected static mClose: boolean = false
  protected static mHilog: boolean = true //默认使用hilog进行打印
  protected static mLogSize = 800 //打印的最大长度，默认是800

  /**
   * 设置日志开关
   * @param logEnable
   */
  static setEnable(logEnable: boolean) {
    DLog.mClose = !logEnable
  }

  /*
   * 日志输出级别
   * */
  static setDomain(domain: number) {
    DLog.mDomain = domain
  }

  //需要先调用isLoggable确认某个domain、tag和日志级别是否被禁止打印日志
  static isLoggable(level: hilog.LogLevel): boolean {
    return hilog.isLoggable(DLog.mDomain, DLog.mTag, level)
  }

  /*
  * console形式打印log日志,只支持console
 * */
  static logConsole(message: Object, tag: string = DLog.mTag) {
    console.log(DLog.getMessage(hilog.LogLevel.INFO, tag, message))
  }

  /*
* info日志
* */
  static info(message?: Object, tag: string = DLog.mTag) {
    DLog.log(hilog.LogLevel.INFO, tag, message)
  }

  /*
* debug日志
* */
  static debug(message?: Object, tag: string = DLog.mTag) {
    DLog.log(hilog.LogLevel.DEBUG, tag, message)
  }


  /*
* error日志,不带标签
* */
  static error(message?: Object, tag: string = DLog.mTag) {
    DLog.log(hilog.LogLevel.ERROR, tag, message)
  }


  /*
* warn日志
* */
  static warn(message: Object, tag: string = DLog.mTag) {
    DLog.log(hilog.LogLevel.WARN, tag, message)
  }

  /*
* fatal日志
* */
  static fatal(message: Object, tag: string = DLog.mTag) {
    DLog.log(hilog.LogLevel.FATAL, tag, message)
  }

  /*
   *统一输出日志
   * */
  protected static log(level: hilog.LogLevel, tag: string, message?: Object) {
    //如果关闭状态，则不打印日志
    if (DLog.mClose) {
      return
    }

    const content = DLog.getMessage(level, tag, message) //最终的内容展示

    const len = content.length / DLog.mLogSize
    for (let i = 0; i < len; i++) {
      let con = content.substring(i * DLog.mLogSize, (i + 1) * DLog.mLogSize)
      if (i != 0) {
        con = "|" + con
      }
      //打印日志
      if (DLog.mHilog) {
        //使用hilog
        switch (level) {
          case hilog.LogLevel.INFO: //info
            hilog.info(DLog.mDomain, tag, con)
            break
          case hilog.LogLevel.WARN: //WARN
            hilog.warn(DLog.mDomain, tag, con)
            break
          case hilog.LogLevel.DEBUG: //DEBUG
            hilog.debug(DLog.mDomain, tag, con)
            break
          case hilog.LogLevel.ERROR: //ERROR
            hilog.error(DLog.mDomain, tag, con)
            break
          case hilog.LogLevel.FATAL: //FATAL
            hilog.fatal(DLog.mDomain, tag, con)
            break
        }
      } else {
        //使用console
        switch (level) {
          case hilog.LogLevel.INFO: //info
            console.info(con)
            break
          case hilog.LogLevel.WARN: //WARN
            console.warn(con)
            break
          case hilog.LogLevel.DEBUG: //DEBUG
            console.debug(con)
            break
          case hilog.LogLevel.ERROR: //ERROR
            console.error(con)
            break
          case hilog.LogLevel.FATAL: //FATAL
            console.log(con)
            break
        }
      }

    }

  }

  /**
   * 获取输出内容
   * */
  protected static getMessage(level: hilog.LogLevel, tag: string, message?: Object): string {
    let log = "┌───────" + tag + "────────────────────────────────────────────────────────────────────────────────"
    log = log.substring(0, log.length - tag.length) + "\n"

    let isJson = false
    try {
      if (message != undefined) {
        let type = typeof message
        if (type == "object") {
          //是对象
          message = DLog.getObjectToJson(message)
          isJson = true
        } else if (type == "string") {
          //判断是否包含大括号
          const content = message + ""
          if (content.startsWith("{") && content.endsWith("}")) {
            //对象
            message = DLog.getObjectToJson(JSON.parse(content))
            isJson = true
          } else {
            message = content
          }
        }
      }

      if (!isJson) {
        return tag + ": " + message
      }

      log = log + "\n|   " + message
    } catch (e) {

    }
    log = log + "\n└───────────────────────────────────────────────────────────────────────────────────────"
    return log
  }

  /*
   *对象转Json
   * */
  protected static getObjectToJson(message: object): String {
    const json = JSON.stringify(message, null, 2)
    const endMessage = json.replace(new RegExp("/\n/g"), "\n|    ")
    return endMessage
  }
}