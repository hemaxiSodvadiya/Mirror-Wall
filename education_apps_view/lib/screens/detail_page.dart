import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'models.dart';

class PageD extends StatelessWidget {
  final Name Page;

  PageD(this.Page);
  @override
  InAppWebViewController? inAppWebViewController;

  final TextEditingController _controller = TextEditingController();

  String searchText = '';

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
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff9c7454),
        title: Text(Page.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialOptions: options,
              initialUrlRequest: URLRequest(
                url: Uri.parse("${Page.url}"),
              ),
              onWebViewCreated: (controller) {
                inAppWebViewController = controller;
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
                    url: Uri.parse(Page.url),
                  ),
                );
              },
              icon: const Icon(Icons.home),
            ),
            label: "",
            backgroundColor: Color(0xff9c7454),
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
            backgroundColor: Color(0xff9c7454),
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () async {
                await inAppWebViewController!.reload();
              },
              icon: const Icon(Icons.refresh),
            ),
            label: "",
            backgroundColor: Color(0xff9c7454),
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
            backgroundColor: Color(0xff9c7454),
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
