import 'package:flutter/material.dart';
import 'anidler.dart';
import 'anidlerGetter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
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
                    forceElevated: innerBoxIsScrolled,
                    bottom: const TabBar(
                      labelPadding: EdgeInsets.all(5.0),
                      indicatorColor: Colors.orange,
                      tabs: [
                        Tab(icon: FaIcon(FontAwesomeIcons.info)),
                        Tab(icon: FaIcon(FontAwesomeIcons.list))
                      ],
                    ),
                  ),
                )
              ];
            },
            body: TabBarView(
              children: [
                ListView(
                  children: info.keys
                      .map(
                        (e) => Card(
                          child: ListTile(
                            title: Text(
                              e.toUpperCase(),
                              style: const TextStyle(color: Colors.orange),
                            ),
                            subtitle: Text(info[e]!),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const Text("Tab 2"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
