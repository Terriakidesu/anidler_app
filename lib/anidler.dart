import 'package:chaleno/chaleno.dart';

class Anidler {
  String baseURL = "https://www1.gogoanime.pe";
  String popularURL =
      "https://ajax.gogo-load.com/ajax/page-recent-release-ongoing.html?page=1";
  String episodeListURL = "https://ajax.gogo-load.com/ajax/load-list-episode";

  Chaleno client = Chaleno();

  String _parseURL(String url, Map<String, dynamic>? params) {
    String parsedURL = url;

    if (params != null) {
      List<String> _params = [];
      parsedURL += "?";
      for (String key in params.keys) {
        String? value = params[key].toString();
        _params.add("$key=$value");
      }

      parsedURL += _params.join("&");
    }
    return parsedURL;
  }

  String _parseURLFromRoute(String route, Map<String, dynamic>? params) {
    return _parseURL(baseURL + route, params);
  }

  Future<Parser?> _request(String url) async {
    return await client.load(url);
  }

  Future<List<NewEpisode>> getNew(page) async {
    var parser = await _request(_parseURLFromRoute("/", {
      "page": page,
    }));

    List<Result> newList = parser!.querySelectorAll("div.last_episodes>ul>li");

    List<NewEpisode> result = newList.map((e) => NewEpisode(e)).toList();

    return result;
  }

  Future<List<TopEpisode>> getTop() async {
    var parser = await _request(popularURL);

    List<Result> topList =
        parser!.querySelectorAll("div.added_series_body.popular>ul>li");

    List<TopEpisode> result = topList.map((e) => TopEpisode(e)).toList();

    return result;
  }

  Future<List<SearchResult>> search(String keyword, int page) async {
    var parser = await _request(_parseURLFromRoute("//search.html", {
      "keyword": keyword,
      "page": page,
    }));

    List<Result> searchResult =
        parser!.querySelectorAll("div.last_episodes>ul>li");

    List<SearchResult> result =
        searchResult.map((e) => SearchResult(e)).toList();

    return result;
  }

  Future<Parser?> getEpisodeList(
      String id, String alias, String defaultEp, int epStart, int epEnd) async {
    return await _request(_parseURL(episodeListURL, {
      "id": id,
      "alias": alias,
      "default_ep": defaultEp,
      "ep_start": "$epStart",
      "ep_end": "$epEnd",
    }));
  }

  Future<AnimeCategory?> getCategory(String route) async {
    var parser = await _request(_parseURLFromRoute(route, {}));

    return AnimeCategory(parser);
  }
}

class AnimeCategory {
  String name = "";
  String type = "";
  String image = "";
  String sypnosis = "";
  String released = "";
  List<Genre> genres = [];
  String status = "";
  String otherNames = "";

  int startEpisode = 0;
  int lastEpisode = 0;

  int epStart = 0;
  int epEnd = 99;

  // ajax stuff
  String id = "";
  String defaultEp = "0";
  String alias = "";

  AnimeCategory(Parser? payload) {
    name = payload!.querySelector("anime_info_body_bg>h1").text!.trim();
    type = payload.querySelector("anime_info_body_bg>p:nth-child(1)>a").title!;
    sypnosis = payload
        .querySelector("anime_info_body_bg>p:nth-child(2)>span")
        .text!
        .trim();
    genres = payload
        .querySelectorAll("anime_info_body_bg>p:nth-child(3)>a")
        .map((e) => Genre(e))
        .toList();
    released = payload
        .querySelector("anime_info_body_bg>p:nth-child(4)>a")
        .text!
        .replaceFirst(RegExp("Released:"), "")
        .trim();
    status =
        payload.querySelector("anime_info_body_bg>p:nth-child(5)>a").title!;
    otherNames = payload
        .querySelector("anime_info_body_bg>p:nth-child(6)>a")
        .text!
        .replaceFirst(RegExp("Other name:"), "")
        .trim();

    var epList = payload.querySelectorAll("div.anime_video_body>ul>li");
    startEpisode = int.parse(epList[0].attr("ep_start")!);
    lastEpisode = int.parse(epList[epList.length - 1].attr("ep_end")!);

    // ajax
    id = payload
        .querySelector("div.anime_info_episodes_next>input#movie_id")
        .attr("value")!;
    defaultEp = payload
        .querySelector("div.anime_info_episodes_next>input#default_ep")
        .attr("value")!;
    alias = payload
        .querySelector("div.anime_info_episodes_next>input#alias_name")
        .attr("value")!;
  }
}

class SearchResult {
  String title = "";
  String href = "";
  String image = "";
  String released = "";

  SearchResult(Result payload) {
    title = payload.querySelector("p.name>a")!.text!.trim();
    href = payload.querySelector("div.img>a")!.href!;
    image = payload.querySelector("div.img>a>img")!.src!;
    released = payload.querySelector("p.released")!.text!.trim();
  }
}

class Genre {
  String name = "";
  String href = "";

  Genre(Result payload) {
    name = payload.title!;
    href = payload.href!;
  }
}

class TopEpisode {
  String title = "";
  String href = "";
  String image = "";
  List<Genre> genres = [];
  String genresText = "";
  String episode = "";
  String latestEpisodeHref = "";

  RegExp regex = RegExp(
      "((http|https)://)(www.)?[a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)");

  TopEpisode(Result payload) {
    title = payload.querySelector("a")!.title!;
    href = payload.querySelector("a")!.href!;
    genres =
        payload.querySelectorAll("p.genres>a")!.map((e) => Genre(e)).toList();
    genresText = genres.map((e) => e.name).toList().join(", ");
    episode = payload.querySelector("p:last-child>a")!.text!;
    latestEpisodeHref = payload.querySelector("p:last-child>a")!.href!;
    image = payload.querySelector("a>div")!.attr("style")!;

    image = regex.firstMatch(image)!.group(0)!;
  }
}

class NewEpisode {
  String title = "";
  String href = "";
  String image = "";
  String episode = "";

  NewEpisode(Result payload) {
    title = payload.querySelector("p.name>a")!.text!.trim();
    href = payload.querySelector("div.img>a")!.href!;
    image = payload.querySelector("div.img>a>img")!.src!;
    episode = payload.querySelector("p.episode")!.text!.trim();
  }
}
