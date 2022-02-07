import 'package:flutter/material.dart';
import 'Anidler.dart';
import 'AnidlerGetter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extend;

class CategoryArguments {
  final String title;
  final String href;

  CategoryArguments(this.title, this.href);
}

// ignore: must_be_immutable
class CategoryWindow extends StatelessWidget {
  CategoryWindow({Key? key}) : super(key: key);

  CategoryArguments args = CategoryArguments("", "");

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as CategoryArguments;

    return _Category(args);
  }
}

class _Category extends StatefulWidget {
  final CategoryArguments args;
  const _Category(this.args);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<_Category> {
  String imageUrl =
      "https://via.placeholder.com/192x256.png/000000/FFFFFF?text=Image";
  Map<String, String> info = {
    "synopsis": "",
    "genres": "",
    "released": "",
    "status": "",
    "otherNames": ""
  };

  Map<String, dynamic> ajax = {
    "id": "",
    "alias": "",
    "default_ep": "",
    "ep_start": 0,
    "ep_end": 0
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    AnimeCategory? result = await anidler.getCategory(widget.args.href);

    imageUrl = result!.image;

    info["synopsis"] = result.synopsis;
    info["genres"] = result.genresText;
    info["released"] = result.released;
    info["status"] = result.status;
    info["otherNames"] = result.otherNames;

    ajax["id"] = result.id;
    ajax["alias"] = result.alias;
    ajax["default_ep"] = result.defaultEp;
    ajax["ep_start"] = result.epStart;
    ajax["ep_end"] = result.epEnd;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          body: extend.NestedScrollView(
            headerSliverBuilder: (BuildContext context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  title: Text(
                    widget.args.title,
                    style: const TextStyle(
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(192, 0, 0, 0),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                  ),
                  flexibleSpace: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: imageUrl,
                        progressIndicatorBuilder: (context, value, progress) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              Color.fromARGB(136, 0, 0, 0),
                              Color(0x00000000),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  pinned: true,
                  expandedHeight: 250.0,
                  bottom: const TabBar(
                    labelPadding: EdgeInsets.all(1.0),
                    indicatorWeight: 2.0,
                    indicatorColor: Colors.orange,
                    labelColor: Colors.orange,
                    unselectedLabelColor: Colors.white,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    tabs: [
                      Tab(
                        icon: FaIcon(FontAwesomeIcons.info),
                        text: "INFO",
                      ),
                      Tab(
                        icon: FaIcon(FontAwesomeIcons.list),
                        text: "EPISODES",
                      )
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                ListView(
                  children: info.keys
                      .map(
                        (e) => Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(5.0),
                            title: Text(
                              e.toUpperCase() == "OTHERNAMES"
                                  ? "OTHER NAME"
                                  : e.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(info[e]!),
                          ),
                        ),
                      )
                      .toList(),
                ),
                _EpisodeListWindow(ajax),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EpisodeListWindow extends StatefulWidget {
  const _EpisodeListWindow(this.ajax);

  final ajax;

  @override
  _EpisodeListState createState() => _EpisodeListState();
}

class _EpisodeListState extends State<_EpisodeListWindow> {
  Future<void> _refresh() async {}

  @override
  Widget build(BuildContext context) {
    print(widget.ajax);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        children: [Text("Some Text")],
      ),
    );
  }
}
