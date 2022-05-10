import type { Principal } from '@dfinity/principal';
export interface Icblog {
  'follow' : (arg_0: Principal) => Promise<undefined>,
  'follows' : () => Promise<Array<Principal>>,
  'greet' : (arg_0: string) => Promise<string>,
  'post' : (arg_0: string) => Promise<undefined>,
  'posts' : (arg_0: Time) => Promise<Array<Message>>,
  'receiveSubscribe' : (arg_0: Message) => Promise<undefined>,
  'subscribe' : (arg_0: Time) => Promise<Array<Message>>,
  'subscribes' : () => Promise<Array<Principal>>,
  'timeline' : (arg_0: Time) => Promise<Array<Message>>,
}
export interface Message { 'msg' : string, 'time' : Time }
export type Time = bigint;
export interface _SERVICE extends Icblog {}
