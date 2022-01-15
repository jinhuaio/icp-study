export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const Message = IDL.Record({ 'msg' : IDL.Text, 'time' : Time });
  const Icblog = IDL.Service({
    'follow' : IDL.Func([IDL.Principal], [], []),
    'follows' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'greet' : IDL.Func([IDL.Text], [IDL.Text], []),
    'post' : IDL.Func([IDL.Text], [], []),
    'posts' : IDL.Func([Time], [IDL.Vec(Message)], ['query']),
    'receiveSubscribe' : IDL.Func([Message], [], []),
    'subscribe' : IDL.Func([Time], [IDL.Vec(Message)], []),
    'subscribes' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'timeline' : IDL.Func([Time], [IDL.Vec(Message)], []),
  });
  return Icblog;
};
export const init = ({ IDL }) => { return []; };
