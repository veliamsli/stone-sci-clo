-module(stone_sci_clo).
-author('lweiyan@gmail.com').

-behavior(application).

-export([start/2, stop/1]).

-export([start/0]).

start() ->
	application:start(stone_sci_clo).

start(_Type, _StartArgs) ->
	webserver:start(getport()).

getport() ->
	case init:get_argument(port) of
		{ok, Values} ->
			[Val | _] = lists:last(Values),
			Val;
		_ ->
			"8888"
	end.

stop(_State) ->
	ok.
