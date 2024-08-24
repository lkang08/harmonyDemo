import { DLog } from '../util/DLog';

let nextId = 0;

@Observed
export class ObservedArray<T> extends Array<T> {
  constructor(args: T[]) {
    console.log(`ObservedArray: ${JSON.stringify(args)} `)
    if (args instanceof Array) {
      super(...args);
    } else {
      super(args)
    }
  }
}

@Observed
export class Address {
  street: string;
  zip: number;
  city: string;

  constructor(street: string,
    zip: number,
    city: string) {
    this.street = street;
    this.zip = zip;
    this.city = city;
  }
}

@Observed
export class Person {
  id_: string;
  name: string;
  address: Address;
  //phones: ObservedArray<string>;
  phones: ObservedArray<string>;
  constructor(name: string,
    street: string,
    zip: number,
    city: string,
    phones: string[]) {
    this.id_ = `${nextId}`;
    nextId++;
    this.name = name;
    this.address = new Address(street, zip, city);
    this.phones = new ObservedArray<string>(phones);
  }
}


export class AddressBook {
  me: Person = new Person('', '', 0, '', [])
  contacts: ObservedArray<Person> = new ObservedArray<Person>([])

  init(callback?: (p: Person) => void) {
    setTimeout(() => {
      this.me = new Person("Gigi", "Itamerenkatu 9", 180, "Helsinki", ["1823423", "18123222", "1832342"])
      this.contacts = [
        new Person("Oly", "Itamerenkatu1 9", 181, "Helsinki1", ["181", "182"]),
        new Person("Sam", "Itamerenkatu2 9", 182, "Helsinki2", ["183", "184"]),
        new Person("Vivi", "Itamerenkatu3 9", 183, "Helsinki3", ["185", "186"]),
      ]
      if (callback) {
        callback(this.me)
      }
      DLog.log('init end')
    }, 2000)
  }
}