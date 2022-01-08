export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'greet' : IDL.Func([IDL.Text], [IDL.Text], []),
    'qsort' : IDL.Func([IDL.Vec(IDL.Int)], [IDL.Vec(IDL.Int)], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
