import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'anidler.dart';
import 'anidlerGetter.dart';
import 'Category.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Anidler',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
        ),
        themeMode: ThemeMode.dark,
        home: _Home(),
        initialRoute: "/",
        routes: {
          "/search": (context) => _SearchWindow(),
          "/category": (context) => CategoryWindow(),
        });
  }
}

class _Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text("Anidler"),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/search");
                },
                child: Icon(
                  Icons.search,
                  size: 32.0,
                  color: Colors.orange.shade500,
                ),
              )
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.orange.shade400,
            indicatorColor: Colors.orange.shade500,
            unselectedLabelColor: Colors.grey.shade500,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(Icons.new_releases_outlined),
                    SizedBox(width: 2.0),
                    Text("Latest"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(Icons.trending_up_outlined),
                    SizedBox(width: 2.0),
                    Text("Top"),
                  ],
                ),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LatestTab(),
            _TopTab(),
          ],
        ),
      ),
    );
  }
}

class _LatestTab extends StatefulWidget {
  @override
  _LatestTabState createState() => _LatestTabState();
}

class _LatestTabState extends State<_LatestTab>
    with AutomaticKeepAliveClientMixin {
  List<Widget> children = [];
  int page = 1;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => _refresh());
  }

  void setPage(int val) {
    if (!isLoading) {
      page += val;
      if (page > 337) {
        page = 337;
      }
      if (page < 1) {
        page = 1;
      }
      setState(() {
        isLoading = true;
      });
    }
  }

  Future<void> _refresh() async {
    List<NewEpisode> results = await anidler.getNew(page);

    children.clear();

    for (NewEpisode result in results) {
      Widget child = InkWell(
        onTap: () async {
          // Navigator.pushNamed(
          //   context,
          //   "/category",
          //   arguments: _CategoryArguments(
          //     result.title,
          //     await anidler.getCategory(result.href),
          //   ),
          // );
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(blurRadius: 5.0),
            ],
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: CachedNetworkImageProvider(result.image),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [
                    0.1,
                    0.7
                  ],
                  colors: [
                    Color.fromARGB(220, 50, 50, 50),
                    Colors.transparent,
                  ]),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                  constraints: const BoxConstraints(
                    minWidth: 110,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5.0,
                        color: Colors.grey.shade900,
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  child: Text(
                    result.episode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(
                      bottom: 5.0,
                      left: 2.5,
                      right: 2.5,
                    ),
                    child: Text(
                      result.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      setState(() {
        children.add(child);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _createNavigationButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
        onPressed: () {
          setPage(-5);
          _refresh();
        },
        child: const FaIcon(FontAwesomeIcons.angleDoubleLeft),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {
          setPage(-1);
          _refresh();
        },
        child: const Icon(Icons.navigate_before),
      ),
      const SizedBox(width: 30),
      Text("$page/337"),
      const SizedBox(width: 30),
      ElevatedButton(
        onPressed: () {
          setPage(1);
          _refresh();
        },
        child: const Icon(Icons.navigate_next),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {
          setPage(5);
          _refresh();
        },
        child: const FaIcon(FontAwesomeIcons.angleDoubleRight),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          isLoading ? const Spacer() : const SizedBox(height: 10),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                  flex: 4,
                  child: GridView.count(
                    childAspectRatio: 0.75,
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.5,
                    mainAxisSpacing: 2.5,
                    children: children
                        .map((child) => Center(
                              child: child,
                            ))
                        .toList(),
                  ),
                ),
          isLoading ? const Spacer() : const SizedBox(height: 7.5),
          Align(
            alignment: Alignment.bottomCenter,
            child: _createNavigationButtons(),
          ),
          const SizedBox(height: 7.5),
        ],
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class _TopTab extends StatefulWidget {
  @override
  _TopTabState createState() => _TopTabState();
}

class _TopTabState extends State<_TopTab> with AutomaticKeepAliveClientMixin {
  final List<Widget> _children = [];

  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      isLoading = true;
    });

    List<TopEpisode> results = await anidler.getTop();

    _children.clear();

    for (TopEpisode result in results) {
      Widget child = ListTile(
        horizontalTitleGap: 32,
        minLeadingWidth: 16,
        onTap: () async {
          Navigator.pushNamed(
            context,
            "/category",
            arguments: CategoryArguments(
              result.title,
              result.href,
            ),
          );
        },
        contentPadding: const EdgeInsets.all(1.0),
        leading: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 64,
            minHeight: 64,
          ),
          child: AspectRatio(
            aspectRatio: 0.75,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(result.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: Text(result.title),
        subtitle: Text(result.genresText),
        trailing: ElevatedButton(
          onPressed: () {
            print(result.latestEpisodeHref);
          },
          child: Column(
            children: [
              const Icon(Icons.play_arrow),
              Text(result.episode),
            ],
          ),
        ),
      );

      _children.add(child);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(5.0),
              children: _children.map((e) => e).toList(),
            ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class _SearchWindow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: _SearchBar(),
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  List<Widget> children = [];
  int page = 0;
  String keyword = "";
  bool isLoading = false;

  void setPage(int value) {
    page += value;
    if (page < 0) {
      page = 0;
    }
  }

  void _search(String keyword, int page) async {
    if (keyword.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Keyword must not be empty"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Dismiss"))
              ],
            );
          });

      return;
    }

    isLoading = true;
    setState(() {});

    List<SearchResult> searchResults = await anidler.search(keyword, page);

    children.clear();

    for (SearchResult result in searchResults) {
      Widget child = InkWell(
        onTap: () async {
          Navigator.pushNamed(
            context,
            "/category",
            arguments: CategoryArguments(
              result.title,
              result.href,
            ),
          );
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(blurRadius: 5.0),
            ],
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: CachedNetworkImageProvider(result.image),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [
                    0.1,
                    0.7
                  ],
                  colors: [
                    Color.fromARGB(220, 50, 50, 50),
                    Colors.transparent,
                  ]),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                  constraints: const BoxConstraints(
                    minWidth: 110,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5.0,
                        color: Colors.grey.shade900,
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  child: Text(
                    result.released,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(
                      bottom: 5.0,
                      left: 2.5,
                      right: 2.5,
                    ),
                    child: Text(
                      result.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      children.add(child);
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _createNavigationButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
        onPressed: () {
          setPage(-5);
          _search(keyword, page);
        },
        child: const Icon(Icons.skip_previous_rounded),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {
          setPage(-1);
          _search(keyword, page);
        },
        child: const Icon(Icons.navigate_before),
      ),
      const SizedBox(width: 30),
      Text("$page"),
      const SizedBox(width: 30),
      ElevatedButton(
        onPressed: () {
          setPage(1);
          _search(keyword, page);
        },
        child: const Icon(Icons.navigate_next),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {
          setPage(5);
          _search(keyword, page);
        },
        child: const Icon(Icons.skip_next_rounded),
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _controller,
                    onChanged: (String value) {
                      keyword = value;
                    },
                    onSubmitted: (String value) {
                      page = 1;
                      _search(value, page);
                    },
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Enter A Keyword",
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 5.0),
                constraints: const BoxConstraints(
                  minHeight: 50.0,
                  minWidth: 40.0,
                ),
                child: OutlinedButton(
                  onPressed: () {
                    _search(keyword, page);
                  },
                  child: const Icon(Icons.search),
                ),
              )
            ],
          ),
          (isLoading || children.isEmpty)
              ? const Spacer()
              : const SizedBox(height: 5),
          isLoading
              ? const CircularProgressIndicator()
              : children.isEmpty
                  ? const Center(child: Text("No Search Results Found."))
                  : Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 0.75,
                        children: children
                            .map(
                              (e) => Center(
                                child: e,
                              ),
                            )
                            .toList(),
                      ),
                    ),
          (isLoading || children.isEmpty)
              ? const Spacer()
              : const SizedBox(height: 5),
          _createNavigationButtons(),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
