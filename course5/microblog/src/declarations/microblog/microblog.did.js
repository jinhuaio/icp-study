export const idlFactory = ({ IDL }) => {
  const Follow = IDL.Record({ 'pid' : IDL.Text, 'author' : IDL.Opt(IDL.Text) });
  const Time = IDL.Int;
  const Message = IDL.Record({
    'msg' : IDL.Text,
    'time' : Time,
    'author' : IDL.Opt(IDL.Text),
  });
  const Microblog = IDL.Service({
    'follow' : IDL.Func([IDL.Principal, IDL.Text], [], []),
    'follows' : IDL.Func([], [IDL.Vec(Follow)], ['query']),
    'get_name' : IDL.Func([], [IDL.Opt(IDL.Text)], ['query']),
    'greet' : IDL.Func([IDL.Text], [IDL.Text], []),
    'post' : IDL.Func([IDL.Text, IDL.Text], [], []),
    'posts' : IDL.Func([Time], [IDL.Vec(Message)], ['query']),
    'set_name' : IDL.Func([IDL.Opt(IDL.Text)], [], []),
    'timeline' : IDL.Func([IDL.Text, Time], [IDL.Vec(Message)], []),
  });
  return Microblog;
};
export const init = ({ IDL }) => { return []; };
