-module(gameserver).
-author('lweiyan@gmail.com').

-behavior(gen_server).

-export([start_link/0, play/2, join/2]).

-export([init/1, handle_call/3, handle_info/2, handle_cast/2, terminate/2, code_change/3]).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
	
play(GameUUID, Attack) ->
	gen_server:call(?MODULE, {play, GameUUID, Attack}, infinity).
	
join(Name, GameUUID) ->
	gne_server:call(?MODULE, {join, Name, GameUUID}, infinity).
	
init([]) ->
	{ok, dict:new()}.

handle_call({play, GameUUID, Attack}, From, State) ->
	error_logger:info_msg("play: ~p ~p ~n", [GameUUID, Attack]),
	
	case dict:is_key(GameUUID, State) of
		false ->
			{noreply, dict:store(GameUUID,{From, Attack}, State)};
		
		true ->
			{OtherFrom, OtherAttack} = dict:fetch(GameUUID, State),
			{R1, R2} = stone_sci_clo_game:play(OtherAttack, Attack),
			gen_server:reply(OtherFrom, {R1, GameUUID, OtherAttack, Attack}),
			Result = {R2, GameUUID, Attack, OtherAttack},
			{reply, Result, dict:erase(GameUUID, State)}
	end.

handle_cast(_Msg, State) ->
	{noreply, State}.
	
handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
	
	

