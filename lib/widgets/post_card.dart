import 'package:flutter/material.dart';
import 'package:instagram_clone/models/populated_post.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore.dart';
import 'package:instagram_clone/screens/comments.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final PopulatedPost post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final userLiked = widget.post.likes.contains(user.uid);

    void displayComments() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Comments(
            postId: widget.post.postId,
          ),
        ),
      );
    }

    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.post.profilePicture),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shrinkWrap: true,
                            children: [
                              'Delete',
                            ]
                                .map((e) => InkWell(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        child: Text(e),
                                      ),
                                      onTap: () {},
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.more_vert)),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.post.postId,
                user.uid,
                widget.post.likes,
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(
                    widget.post.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    smallLike: false,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              LikeAnimation(
                isAnimating: userLiked,
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(
                      widget.post.postId,
                      user.uid,
                      widget.post.likes,
                    );
                  },
                  icon: userLiked
                      ? const Icon(Icons.favorite, color: Colors.red)
                      : const Icon(
                          Icons.favorite_border_outlined,
                          color: Colors.white,
                        ),
                ),
              ),
              IconButton(
                onPressed: displayComments,
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${widget.post.likes.length} likes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.post.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${widget.post.description}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: displayComments,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      widget.post.numOfComments > 0
                          ? 'View all ${widget.post.numOfComments} comments'
                          : 'No comments yet',
                      style:
                          const TextStyle(fontSize: 16, color: secondaryColor),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    Jiffy.parseFromDateTime(widget.post.datePublished)
                        .fromNow(),
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}