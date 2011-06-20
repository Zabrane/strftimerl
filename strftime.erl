-module(strftime).
-export([f/2]).

-include_lib("eunit/include/eunit.hrl").


f({_MegaSec,_Sec,_MicroSec}=Tm, FormatStr) when is_list(FormatStr) ->
  Res = [do_f(Tm, FPart) || FPart <- re:split(FormatStr,"([%][^%])")],
  binary_to_list(list_to_binary(Res)).

do_f(Tm, <<"%d">>) ->
  {{_YY,_MM,DD},_} = calendar:now_to_local_time(Tm),
  f2(DD);

do_f(Tm, <<"%m">>) ->
  {{_YY,MM,_DD},_} = calendar:now_to_local_time(Tm),
  f2(MM);

do_f(Tm, <<"%y">>) ->
  {{YY,_MM,_DD},_} = calendar:now_to_local_time(Tm),
  f2(YY);

do_f(Tm, <<"%Y">>) ->
  {{YY,_MM,_DD},_} = calendar:now_to_local_time(Tm),
  f4(YY);

do_f(Tm, <<"%H">>) ->
  {_,{H,_M,_S}} = calendar:now_to_local_time(Tm),
  f2(H);

do_f(Tm, <<"%M">>) ->
  {_,{_H,M,_S}} = calendar:now_to_local_time(Tm),
  f2(M);

do_f(Tm, <<"%S">>) ->
  {_,{_H,_M,S}} = calendar:now_to_local_time(Tm),
  f2(S);

do_f(Tm, <<"%p">>) ->
  {_,{H,_M,_S}} = calendar:now_to_local_time(Tm),
  case H < 12 of
    true -> "AM";
    false -> "PM"
  end;

do_f(Tm, <<"%P">>) ->
  {_,{H,_M,_S}} = calendar:now_to_local_time(Tm),
  case H < 12 of
    true -> "am";
    false -> "pm"
  end;

do_f({_,_,MicroSec}, <<"%N">>) -> integer_to_list(MicroSec);

do_f(Tm, <<"%D">>) -> f(Tm, "%m/%d/%y");
do_f(Tm, <<"%F">>) -> f(Tm, "%Y-%m-%d");
do_f(Tm, <<"%T">>) -> f(Tm, "%H:%M:%S");
do_f(Tm, <<"%R">>) -> f(Tm, "%H:%M");

do_f(_Tm,Str) -> Str.

f2(N) -> io_lib:format("~2.2.0w",[(N rem 100)]).
f4(N) -> io_lib:format("~4.4.0w",[(N rem 10000)]).

% 2011-06-19 19:07:50.46425 -0500
test_tm() -> {1308,528470,46435}.

%D test
f_D_test() ->
  ?assertEqual("06/19/11", f(test_tm(), "%D")),
  ?assertEqual("fooey06/19/11fooey", f(test_tm(), "fooey%Dfooey")).

%F test
f_F_test() ->
  ?assertEqual("2011-06-19", f(test_tm(), "%F")),
  ?assertEqual("fooey2011-06-19fooey", f(test_tm(), "fooey%Ffooey")).

%y test
f_y_test() ->
  ?assertEqual("11", f(test_tm(), "%y")),
  ?assertEqual("fooey11", f(test_tm(), "fooey%y")).

%m test
f_m_test() ->
  ?assertEqual("06", f(test_tm(), "%m")),
  ?assertEqual("fooey06", f(test_tm(), "fooey%m")).

%d test
f_d_test() ->
  ?assertEqual("19", f(test_tm(), "%d")),
  ?assertEqual("fooey19", f(test_tm(), "fooey%d")).

f_Y_test() ->
  ?assertEqual("2011", f(test_tm(), "%Y")),
  ?assertEqual("fooey2011", f(test_tm(), "fooey%Y")).

f_H_test() -> ?assertEqual("19", f(test_tm(), "%H")).
f_M_test() -> ?assertEqual("07", f(test_tm(), "%M")).
f_S_test() -> ?assertEqual("50", f(test_tm(), "%S")).
f_T_test() -> ?assertEqual("19:07:50", f(test_tm(), "%T")).
f_R_test() -> ?assertEqual("19:07", f(test_tm(), "%R")).
f_p_test() -> ?assertEqual("PM", f(test_tm(), "%p")).
f_P_test() -> ?assertEqual("pm", f(test_tm(), "%P")).
f_N_test() -> ?assertEqual("46435", f(test_tm(), "%N")).

literal_percent_test() -> 
  ?assertEqual("%%19:07:50%%", f(test_tm(), "%%%T%%")).


