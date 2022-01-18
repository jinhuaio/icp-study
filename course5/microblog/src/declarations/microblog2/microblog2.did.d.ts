import type { Principal } from '@dfinity/principal';
export interface Message {
  'msg' : string,
  'time' : Time,
  'author' : [] | [string],
}
export interface Microblog {
  'follow' : (arg_0: Principal) => Promise<undefined>,
  'follows' : () => Promise<Array<Principal>>,
  'get_name' : () => Promise<[] | [string]>,
  'greet' : (arg_0: string) => Promise<string>,
  'post' : (arg_0: string) => Promise<undefined>,
  'posts' : (arg_0: Time) => Promise<Array<Message>>,
  'set_name' : (arg_0: [] | [string]) => Promise<undefined>,
  'timeline' : (arg_0: Time) => Promise<Array<Message>>,
}
export type Time = bigint;
export interface _SERVICE extends Microblog {}
