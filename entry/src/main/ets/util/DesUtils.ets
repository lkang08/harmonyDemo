// DesUtils.ts
import cryptoFramework from '@ohos.security.cryptoFramework'
import util from '@ohos.util';
import { ThreeDESUtil } from './ThreeDESUtil';

export class DesUtils {
  async handle(opMode: cryptoFramework.CryptoMode, data: cryptoFramework.DataBlob) {
    let retEmpty: cryptoFramework.DataBlob = { data: new Uint8Array() }
    // 使用对称密钥的加解密操作
    // 1. 创建对称密钥生成器。
    let symKeyGenerator = cryptoFramework.createSymKeyGenerator('3DES192');
    if (symKeyGenerator == null) {
      return retEmpty;
    }
    let tempKey = '64DAD50715CE6D6BEC67685801DCF86E435723C44FF72AE9'
    let kArray = ThreeDESUtil.getKeyByStr(tempKey)
    // 2. 通过密钥生成器生成对称密钥。(写成16进制或10进制都行)
    /*let symKey = await symKeyGenerator.convertKey({ data: new Uint8Array([
      0xba, 0x3d, 0xc2, 0x71, 0x21, 0x1e, 0x30, 0x56,
      0xad, 0x47, 0xfc, 0x5a, 0x46, 0x39, 0xee, 0x7c,
      0xba, 0x3b, 0xc2, 0x71, 0xab, 0xa0, 0x30, 0x72
    ]) })*/
    let symKey = await symKeyGenerator.convertKey({ data: kArray })
    if (symKey == null) {
      return retEmpty;
    }
    // 3. 创建加解密生成器。
    let cipher = cryptoFramework.createCipher('3DES192|CBC|PKCS7');
    if (cipher == null) {
      return retEmpty;
    }
    let iv = ThreeDESUtil.getKeyByStr('435723C44FF72AE9')
    // 4. 通过加解密生成器加密或解密数据。(写成16进制或10进制都行)
    await cipher.init(opMode, symKey,
      {
        iv: { data: new Uint8Array(kArray/*[0xad, 0x47, 0xfc, 0x5a, 0x46, 0x39, 0xee, 0x7c]*/) },
        algName: "IvParamsSpec"
      } as cryptoFramework.IvParamsSpec);
    // 5. 开始处理加密或解密
    return await cipher.doFinal(data);
  }

  /**
   * des加密
   * @param data
   * @returns
   */
  async encode(data: string) {
    const textDecoder = new util.TextEncoder();
    const uint8Array = textDecoder.encodeInto(data);
    let dataBlob = await this.handle(cryptoFramework.CryptoMode.ENCRYPT_MODE, { data: uint8Array })
    let base64 = new util.Base64Helper();
    return base64.encodeToStringSync(dataBlob.data);
  }

  /**
   * des解密
   * @param data 加密的字符串
   * @returns 解密的字符串
   */
  async decode(data: string) {
    let base64 = new util.Base64Helper();
    let uint8Array = base64.decodeSync(data);
    let dataBlob = await this.handle(cryptoFramework.CryptoMode.DECRYPT_MODE, { data: uint8Array })
    const textDecoder = util.TextDecoder.create('utf-8');
    return textDecoder.decodeWithStream(dataBlob.data);
  }

  async decode1(array: Uint8Array) {
    let dataBlob = await this.handle(cryptoFramework.CryptoMode.DECRYPT_MODE, { data: array })
    const textDecoder = util.TextDecoder.create('utf-8');
    return textDecoder.decodeWithStream(dataBlob.data);
  }
}

const desUtils = new DesUtils()

export default desUtils as DesUtils