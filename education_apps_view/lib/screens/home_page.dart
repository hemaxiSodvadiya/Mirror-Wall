import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? inAppWebViewController;

  final TextEditingController _controller = TextEditingController();

  String searchText = '';

  double progress = 0;

  late PullToRefreshController pullToRefreshController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  List<String> allBookMarks = [];

  void initState() {
    // TODO: implement initState
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.red),
      onRefresh: () async {
        if (Platform.isAndroid) {
          inAppWebViewController?.reload();
        }

        if (Platform.isIOS) {
          inAppWebViewController?.loadUrl(
              urlRequest:
                  URLRequest(url: await inAppWebViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("flutter_InAppWebView"),
      ),
      body: Column(
        children: [
          progress < 1.0
              ? LinearProgressIndicator(
                  value: progress,
                  color: Colors.blue,
                  minHeight: 5,
                )
              : Container(),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: _controller,
              onChanged: (val) async {
                searchText = val;
                Uri uri = Uri.parse(searchText);

                if (uri.scheme.isEmpty) {
                  uri = Uri.parse(
                      'https://www.google.com/search?q=' + searchText);
                }

                await inAppWebViewController!
                    .loadUrl(urlRequest: URLRequest(url: uri));
              },
              decoration: const InputDecoration(hintText: "search"),
            ),
          ),
          Expanded(
            flex: 14,
            child: InAppWebView(
              pullToRefreshController: pullToRefreshController,
              initialOptions: options,
              initialUrlRequest: URLRequest(
                url: Uri.parse('https://www.google.co.in'),
              ),
              onLoadStart: (controller, url) async {
                await pullToRefreshController.beginRefreshing();
                setState(() {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: const Text("Cancel"),
                        content: ElevatedButton(
                          onPressed: () {
                            print("+");
                          },
                          child: const Icon(Icons.cancel_outlined),
                        )),
                  );
                });
              },
              onWebViewCreated: (controller) {
                inAppWebViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController.endRefreshing();
                }
                setState(() {
                  this.progress = progress / 100;
                });
              },
              onLoadStop: (controller, url) async {
                await pullToRefreshController.endRefreshing();

                setState(() {});
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () async {
                await inAppWebViewController!.loadUrl(
                  urlRequest: URLRequest(
                    url: Uri.parse("https://www.google.co.in"),
                  ),
                );
              },
              icon: const Icon(Icons.home),
            ),
            label: "",
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () async {
                if (await inAppWebViewController!.canGoBack()) {
                  await inAppWebViewController!.goBack();
                }
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            label: "",
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () async {
                await inAppWebViewController!.reload();
              },
              icon: const Icon(Icons.refresh),
            ),
            label: "",
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () async {
                if (await inAppWebViewController!.canGoForward()) {
                  await inAppWebViewController!.goForward();
                }
              },
              icon: const Icon(Icons.arrow_forward_ios),
            ),
            label: "",
            backgroundColor: Colors.red,
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              Uri? uri = await inAppWebViewController!.getUrl();
              allBookMarks.add(uri.toString());
              print("${uri}");
            },
            mini: true,
            child: const Icon(Icons.bookmark_add_outlined),
          ),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Add bookmarks list"),
                  content: SizedBox(
                      height: 250,
                      width: 250,
                      child: ListView.separated(
                          itemBuilder: (context, i) {
                            return ListTile(
                              title: Text(allBookMarks[i]),
                              onTap: () async {
                                Navigator.of(context).pop();

                                await inAppWebViewController!.loadUrl(
                                  urlRequest: URLRequest(
                                    url: Uri.parse(allBookMarks[i]),
                                  ),
                                );
                                if (kDebugMode) {
                                  print(allBookMarks[i]);
                                }
                              },
                            );
                          },
                          separatorBuilder: (context, i) {
                            return const Divider(
                              color: Colors.black54,
                            );
                          },
                          itemCount: allBookMarks.length)),
                ),
              );
            },
            child: const Icon(Icons.bookmarks),
          ),
        ],
      ),
    );
  }
}
