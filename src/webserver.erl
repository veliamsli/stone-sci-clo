-module(webserver).
-author('lweiyan@gmail.com').

-export([start/1]).
-export([dispatch_requests/1]).

start(Port) ->
	error_logger:info_msg("Starting mochiweb on http://localhost:~s /~n", [Port]),
	gameserver:start_link(),
	uuid:start_link(),
	mochiweb_http:start([{port, Port},
				{loop, fun dispatch_requests/1}]).

dispatch_requests(Req) ->
	Path = string:tokens(Req:get(path), "/"),
	case Path of
		["static" | File] ->
			Req:serve_file(File, "./www");
		_ ->
			Method = Req:get(method),
			case (catch handle(Method, Path, Req)) of
				{'EXIT', _E} ->	
					Req:no_found();
				Resp ->
					Resp
			end
	end.


handle('GET', [] , Req) ->
	Req:serve_file("main.html", "./www");

handle('POST', [], Req) ->
	UUID = uuid:generate(),
	redirect(Req, UUID ++ "/");

handle('GET', [UUID], Req) ->
	case string:right(Req:get(path), 1) of
		"/" ->
			Req:serve_file("game.html", "./www");
		_ ->
			redirect(Req, UUID ++ "/")
	end;

handle('POST', [UUID, "join"], Req) ->
	Data = mochiweb_util:parse_qs(Req:recv_body()),
	Attack = proplists:get_value("attack", Data),
	{Result, Game, Attack1, Attack2} = gameserver:play(UUID, Attack),
	JSON = iolist_to_binary(mochijons2:encode({struct, [
			{"result", Result},
			{"game", list_to_binary(Game)},
			{"your-attack", list_to_binary(Attack1)},
			{"their-attack", list_to_binary(Attack2)}
		]})),
	Req:ok({"application/javascript", JSON}).

redirect(Req, Path) ->
	Location = "http://" ++ Req:get_header_value("host") ++ "/" ++ Path,
	Req:respond({302, [{"Location", Location}], "Redirecting to " ++ Path ++ "\n"}).

