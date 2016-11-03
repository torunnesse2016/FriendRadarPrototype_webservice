-module(geo_app_util).

-export([md5/1]).

md5(Bin) when is_binary(Bin) ->
  << A1:4, A2:4,  A3:4,  A4:4,  A5:4,  A6:4,  A7:4,  A8:4,
    A9:4,  A10:4, A11:4, A12:4, A13:4, A14:4, A15:4, A16:4,
    A17:4, A18:4, A19:4, A20:4, A21:4, A22:4, A23:4, A24:4,
    A25:4, A26:4, A27:4, A28:4, A29:4, A30:4, A31:4, A32:4
    >> = erlang:md5(Bin),
  << (hex(A1)), (hex(A2)),  (hex(A3)),  (hex(A4)),
    (hex(A5)),  (hex(A6)),  (hex(A7)),  (hex(A8)),
    (hex(A9)),  (hex(A10)), (hex(A11)), (hex(A12)),
    (hex(A13)), (hex(A14)), (hex(A15)), (hex(A16)),
    (hex(A17)), (hex(A18)), (hex(A19)), (hex(A20)),
    (hex(A21)), (hex(A22)), (hex(A23)), (hex(A24)),
    (hex(A25)), (hex(A26)), (hex(A27)), (hex(A28)),
    (hex(A29)), (hex(A30)), (hex(A31)), (hex(A32)) >>.

hex(X) ->
  element(X+1, {$0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $a, $b, $c, $d, $e, $f}).
