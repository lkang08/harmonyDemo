import { AddressBook, Person } from '../model/Model';
import { AddressBookView } from './MyComponent';
import taskpool from '@ohos.taskpool';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { SearchSwiper } from '../component/SearchSwiper';

@Concurrent
function serviceHandle(pars: number): number {

  hilog.info(0x0000, 'testTag', 'start ServiceHandle:%{public}d', pars);
  let t: number = Date.now();
  // 业务处理过程,并将结果返回
  while ((Date.now() - t) < 1000) {
    hilog.info(0x0000, 'testTag', 'time:%{public}d', Date.now());
    continue;

  }
  let result = 0;

  return result;

}

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @Provide addrBook: AddressBook = new AddressBook();
  @State selectedPerson: Person = new Person("", "", 0, "", []);

  aboutToAppear(): void {
    this.addrBook.init((p: Person) => {
      this.selectedPerson = p
    })
  }

  test() {
    let task = new taskpool.Task(serviceHandle, 22)
    taskpool.execute(task, taskpool.Priority.LOW).then(() => {
      hilog.info(0x0000, 'testTag', 'taskpool end');
      promptAction.showToast({ message: 'taskpool end:' + Date.now() })
    })
  }

  build() {
    Column() {
      /*AddressBookView({
        me: this.addrBook.me,
        contacts: this.addrBook.contacts,
        selectedPerson: this.selectedPerson
      })
      Column() {
        Text(this.message).fontSize(14).backgroundColor(Color.Red).height(40)
      }.justifyContent(FlexAlign.Center).height(50).backgroundColor(Color.Gray).width('100%')*/

      Blank().height(5)
      Column() {
        Text(this.message).fontSize(14).backgroundColor(Color.Red).height(40).onClick(()=>{
          this.test()
        })
      }
      .alignItems(HorizontalAlign.Start)
      .height(50)
      .backgroundColor(Color.Gray)
      .width('100%')
      .justifyContent(FlexAlign.End)

      SearchSwiper().width('100%')
      Blank().height(5)
      Column() {
        Text(this.message).fontSize(14).backgroundColor(Color.Red).height(40)

      }.height(50).backgroundColor(Color.Gray).width('100%').justifyContent(FlexAlign.SpaceAround)

      Blank().height(5)
    }
  }
}