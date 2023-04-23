import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/models.dart';

class ReplyTweetScreen extends ConsumerWidget {
  static route(TweetModel tweet) => MaterialPageRoute(
        builder: (context) => ReplyTweetScreen(
          tweet: tweet,
        ),
      );
  final TweetModel tweet;
  const ReplyTweetScreen({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tweet'),
        ),
        body: Column(
          children: [
            TweetCard(tweet: tweet),
            ref.watch(getRepliesProvider(tweet)).when(
                  data: (tweets) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: tweets.length,
                        itemBuilder: (BuildContext context, int index) {
                          final tweet = tweets[index];
                          return TweetCard(tweet: tweet);
                        },
                      ),
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          ],
        ),
        bottomNavigationBar: TextField(
          onSubmitted: (value) {
            ref.read(tweetControllerProvider.notifier).shareTweet(
              images: [],
              text: value,
              repliedTo: tweet.id,
              context: context,
            );
          },
          decoration: const InputDecoration(
            hintText: 'Tweet your reply',
          ),
        ),
      ),
    );
  }
}
