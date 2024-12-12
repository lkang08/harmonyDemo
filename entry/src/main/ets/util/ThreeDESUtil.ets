import CryptoJS from "@ohos/crypto-js"
import DesUtils from "./DesUtils"

export class ThreeDESUtil {
  static test() {
    //ThreeDESUtil.encrypt()
    let phone = '466F6B8A2D84F1DBD921EAA107076756F77FF01AB4C1E49B363301B1F9EC0739'
    let key = '64DAD50715CE6D6BEC67685801DCF86E435723C44FF72AE9'
    let key1 = key.substring(0, 16)
    let key2 = key.substring(16, 32)
    let key3 = key.substring(32, 48)

    // 使用hex格式解析密文，并转为Base64格式，如果密文已经是Base64格式则不需要转换

    /*let array = ThreeDESUtil.getKeyByStr(phone)
    DesUtils.decode1(array).then((s) => {
      console.info(`>>>>>> DesUtils plainText ${s}`)
    }).catch((re:object) => {
      console.error(`>>>>>> DesUtils plainText err:${re}`)
    })*/

    /*ThreeDESUtil.getKeyByStr(phone)
    let r1 = ThreeDESUtil.decrypt('D7B0CE94AD2FCC731BD82ADB8C3D8199','435723C44FF72AE9', '435723C44FF72AE9', '435723C44FF72AE9')
    console.info(`>>>>>> plainText:${r1.toString(CryptoJS.enc.Utf8)}`)*/
    //.toString(CryptoJS.enc.Utf8) // 将解密结果转为utf8格式才能正确显示

    let r2 = ThreeDESUtil.decrypt(phone,key1, key2, key3)
    let result = r2.toString(CryptoJS.enc.Hex)
    console.info(`>>>>>> plainText phone:${result}`)
  }

  static decrypt(input: string, keyString1: string,keyString2: string,keyString3: string) {
    let word: CryptoJS.lib.WordArray | string = CryptoJS.enc.Hex.parse(input)
    word = CryptoJS.enc.Base64.stringify(word)
    const key3: CryptoJS.lib.WordArray = CryptoJS.enc.Hex.parse(keyString3) // 使用Utf8格式解析密钥
    const iv3: CryptoJS.lib.WordArray = CryptoJS.enc.Hex.parse(keyString3) // 使用Utf8格式解析偏移量

    // DES解密，需要配置与加密一致的加密模式、填充方式和偏移量
    let desDecryptOutput = CryptoJS.DES.decrypt(word, key3, {
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7,
      iv: iv3
    })
    console.info(`>>>>>> plainText 3:${desDecryptOutput.toString(CryptoJS.enc.Hex)}`)

    word = CryptoJS.enc.Base64.stringify(desDecryptOutput)
    const key2: CryptoJS.lib.WordArray = CryptoJS.enc.Hex.parse(keyString2) // 使用Utf8格式解析密钥
    const iv2: CryptoJS.lib.WordArray = CryptoJS.enc.Hex.parse(keyString2)
    desDecryptOutput = CryptoJS.DES.decrypt(word, key2, {
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7,
      iv: iv2
    })
    console.info(`>>>>>> plainText 2:${desDecryptOutput.toString(CryptoJS.enc.Hex)}`)

    word = CryptoJS.enc.Base64.stringify(desDecryptOutput)
    const key1: CryptoJS.lib.WordArray = CryptoJS.enc.Hex.parse(keyString1) // 使用Utf8格式解析密钥
    const iv1: CryptoJS.lib.WordArray = CryptoJS.enc.Hex.parse(keyString1)
    desDecryptOutput = CryptoJS.DES.decrypt(word, key1, {
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7,
      iv: iv1
    })
    console.info(`>>>>>> plainText 1:${desDecryptOutput.toString(CryptoJS.enc.Utf8)}`)

    return desDecryptOutput
  }

  /*  let word: CryptoJS.lib.WordArray = CryptoJS.enc.Utf8.parse("hello world!!") // 使用Utf8格式解析明文
    let key: CryptoJS.lib.WordArray = CryptoJS.enc.Utf8.parse("key") // 使用Utf8格式解析密钥
    let iv: CryptoJS.lib.WordArray = CryptoJS.enc.Utf8.parse('iv') // 使用Utf8格式解析偏移量
    // DES加密，可以配置加密模式、填充方式和偏移量
    let desOutput CryptoJS.DES.encrypt(word, key, {
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7,
      iv: iv
    }).ciphertext.toString()*/

  static encrypt() {
    let word: CryptoJS.lib.WordArray = CryptoJS.enc.Utf8.parse("hello world!!")
    let key: CryptoJS.lib.WordArray = CryptoJS.enc.Utf8.parse("435723C44FF72AE9")
    let iv: CryptoJS.lib.WordArray = CryptoJS.enc.Utf8.parse('435723C4')
    let desOutput = CryptoJS.DES.encrypt(word, key, {
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7,
      iv: iv
    }).ciphertext.toString()
    console.info(`>>>>>> encrypt plainText:${desOutput}}`)
    ThreeDESUtil.decrypt2(desOutput)
  }

  static decrypt2(input: string) {
    let word: CryptoJS.lib.WordArray | string = CryptoJS.enc.Hex.parse(input)
    word = CryptoJS.enc.Base64.stringify(word)
    const key: CryptoJS.lib.WordArray = CryptoJS.enc.Utf8.parse('435723C44FF72AE9') // 使用Utf8格式解析密钥
    const iv: CryptoJS.lib.WordArray = CryptoJS.enc.Utf8.parse('435723C4') // 使用Utf8格式解析偏移量

    // DES解密，需要配置与加密一致的加密模式、填充方式和偏移量
    let desDecryptOutput = CryptoJS.DES.decrypt(word, key, {
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7,
      iv: iv
    })
    console.info(`>>>>>> decrypt2 plainText:${desDecryptOutput.toString(CryptoJS.enc.Utf8)}}`)

  }

  static getKeyByStr(str: string) {
    let array = new Uint8Array(str.length / 2)
    for (let i = 0; i < str.length / 2; i++) {
      let v = 16 * Number.parseInt(str.charAt(2 * i), 16) + Number.parseInt(str.charAt(2 * i + 1), 16)
      array[i] = v
    }
    return array
  }
}