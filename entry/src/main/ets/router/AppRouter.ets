import { router } from '@kit.ArkUI';
import { DLog } from '../util/DLog';

export class AppRouter {
  /**
   * 跳转命名路由
   * @param url
   * @param params
   */
  static pushNamedPage(url: string, params?: Object) {
    router.pushNamedRoute({
      name: url,
      params: params
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        DLog.error(`pushNamedPage: "${url}" failed, code: ${err.code}, message: ${err.message}`);
        return;
      }
      DLog.info('pushNamedPage success: "' + url + '"');
    })
  }

  /**
   * 跳转命名路由,销毁当前页
   * @param url
   * @param params
   */
  static replaceNamedPage(url: string, params?: Object) {
    router.replaceNamedRoute({
      name: url,
      params: params
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        DLog.error(`pushNamedPage: "${url}" failed, code: ${err.code}, message: ${err.message}`);
        return;
      }
      DLog.info('pushNamedPage success: "' + url + '"');
    })
  }

  /**
   * 跳转路径路由
   * @param url
   * @param params
   */
  static pushUrlPage(url: string, params?: object) {
    router.pushUrl({
      url: url,
      params: params
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        DLog.error(`pushUrlPage: "${url}" failed, code: ${err.code}, message: ${err.message}`);
        return;
      }
      DLog.info('pushUrlPage success: "' + url + '"');
    })
  }

  /**
   * 跳转路径路由,销毁当前页面
   * @param url
   * @param params
   */
  static replaceUrlPage(url: string, params?: object) {
    router.replaceUrl({
      url: url,
      params: params
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        DLog.error(`pushUrlPage: "${url}" failed, code: ${err.code}, message: ${err.message}`);
        return;
      }
      DLog.info('pushUrlPage success: "' + url + '"');
    })
  }

  /**
   * 返回上一页面或指定的页面
   * @param url
   * @param params
   */
  static back(url?: string, params?: object) {
    router.back(url ? {
      url: url,
      params: params
    } : undefined)
  }

  /**
   * 清空历史页面，只保留当前页
   */
  static clear() {
    router.clear()
  }
}