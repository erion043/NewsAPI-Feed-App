import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:erion_news/functions/data.dart';
import 'package:erion_news/functions/tabs.dart';
import 'package:erion_news/functions/api_response.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialHome extends StatefulWidget {
  @override
  _MaterialHomeState createState() => _MaterialHomeState();
}

void main() {
  runApp(MaterialApp(
    home: MaterialHome(),
  ));
}

class _MaterialHomeState extends State<MaterialHome> {
  late Future<ApiResponse<List<Tabs>>> response;
  List<Tabs> myTabs = [];
  bool isLoading = false;
  String selectedCountry = 'us';

  @override
  void initState() {
    super.initState();
    setupLocator();
    fetchNotes();
  }

  void setupLocator() {
    GetIt.instance.registerLazySingleton(() => NewsList());
  }

  Future<void> fetchNotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      var initializer = GetIt.instance<NewsList>();
      response = initializer.getNewsList(selectedCountry);

      const timeoutDuration = Duration(seconds: 30);
      final apiResponse = await response.timeout(timeoutDuration);

      if (!apiResponse.error) {
        setState(() {
          myTabs = apiResponse.data;
          isLoading = false;
        });
      } else {
        print(apiResponse.errorMessage);
        setState(() {
          isLoading = false;
        });
      }
    } on TimeoutException {
      print('Timeout: Failed to fetch data');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "News API Feed",
          style: TextStyle(
            fontFamily: "LiberationSans",
            fontSize: 18,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 171, 234),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(0, 100, 0, 0),
              items: [
                PopupMenuItem(
                  child: const Text('United States'),
                  onTap: () {
                    setState(() {
                      selectedCountry = 'us';
                      fetchNotes();
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Great Britain'),
                  onTap: () {
                    setState(() {
                      selectedCountry = 'gb';
                      fetchNotes();
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Germany'),
                  onTap: () {
                    setState(() {
                      selectedCountry = 'de';
                      fetchNotes();
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Italy'),
                  onTap: () {
                    setState(() {
                      selectedCountry = 'it';
                      fetchNotes();
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('France'),
                  onTap: () {
                    setState(() {
                      selectedCountry = 'fr';
                      fetchNotes();
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                fetchNotes(); // Trigger a rebuild to refresh the news
              });
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: FutureBuilder<ApiResponse<List<Tabs>>>(
        future: response,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ignore: prefer_const_constructors
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final apiResponse = snapshot.data!;
            if (apiResponse.error) {
              return Center(
                child: Text(apiResponse.errorMessage),
              );
            } else {
              return ListView.separated(
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Color.fromARGB(255, 188, 188, 188),
                ),
                itemBuilder: (_, index) {
                  final currentTab = apiResponse.data[index];
                  if (currentTab.title != "[Removed]") {
                    return InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          children: [
                            if (currentTab.imageURL.isNotEmpty)
                              Image.network(
                                currentTab.imageURL,
                                width: 700,
                                height: 200,
                                fit: BoxFit.fitWidth,
                              )
                            else
                              const SizedBox.shrink(),
                            ListTile(
                              title: Text(
                                currentTab.title,
                                style: const TextStyle(
                                  fontFamily: "LiberationSans",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              subtitle: Text(
                                ("${currentTab.date.substring(11, 16)}  ${currentTab.date.substring(0, 10)}"),
                                style: const TextStyle(
                                  fontFamily: "LiberationSans",
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            Text(
                              currentTab.description,
                              style: const TextStyle(
                                fontFamily: "LiberationSans",
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        launchUrl(Uri.parse(currentTab.webpage));
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                itemCount: apiResponse.data.length,
              );
            }
          }
        },
      ),
    );
  }
}
