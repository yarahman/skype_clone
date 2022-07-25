import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utilities/universal_data.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_tile.dart';
import '../models/message.dart';
import '../resources/firebase_repository.dart';
import '../constants/string.dart';
import '../utilities/utilities.dart';
import '../providers/image_upload_provider.dart';
import '../enums/view_state.dart';
import '../screens/page/widgets/cached_image.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({this.reciver});
  final UserModel? reciver;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textController = TextEditingController();
  var isWriting = false;
  FirebaseRepository repo = FirebaseRepository();
  final firestore = FirebaseFirestore.instance;
  final scrollContoller = ScrollController();
  UserModel? sender;
  String? cureentUserId;
  var isShowEmojiPicker = false;
  ImageUploadProvider? imageUploadProvider;

// responsible for sending message ----------------------->
  void sendMessage() {
    var text = textController.text;
    Message message = Message(
      reciverId: widget.reciver!.uid,
      senderId: sender!.uid,
      type: 'text',
      timesStamp: Timestamp.now(),
      message: text,
    );

    setState(() {
      isWriting = false;
    });
    textController.clear();
    repo.sendingMessageToDb(message, sender!, widget.reciver!);
  }

  @override
  void initState() {
    var user = repo.getCurrentUser();
    cureentUserId = user.uid;

    setState(() {
      sender = UserModel(
          uid: user.uid, name: user.displayName, profilePhoto: user.photoURL);
    });
    super.initState();
  }

  void pickImage(ImageSource source) async {
    File image = await Utilities.pickImage(source);

    repo.uploadImageToStorage(
        image, cureentUserId!, widget.reciver!.uid!, imageUploadProvider!);
  }

  @override
  Widget build(BuildContext context) {
    imageUploadProvider = Provider.of<ImageUploadProvider>(
      context,
    );
    return Scaffold(
      backgroundColor: UniversalData.screenColor,
      appBar: customAppBar(),
      body: Column(
        children: [
          Flexible(child: messageList()),
          imageUploadProvider!.getViewState == ViewState.loading
              ? Container(
                  margin: const EdgeInsets.all(10.0),
                  alignment: Alignment.centerRight,
                  child: const CircularProgressIndicator(),
                )
              : Container(),
          chatController(context),
          isShowEmojiPicker
              ? AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  height: 400.0,
                  child: showEmojiPicker())
              : Container(),
        ],
      ),
    );
  }

  // widget methods ------------------------------------->

  Widget showEmojiPicker() {
    return EmojiPicker(
      config: const Config(
        bgColor: UniversalData.screenColor,
        indicatorColor: UniversalData.lightBule,
        columns: 7,
      ),
      onEmojiSelected: ((category, emoji) {
        setState(() {
          isWriting = true;
        });

        textController.text = textController.text + emoji.emoji;
      }),
      onBackspacePressed: () {},
    );
  }

  Widget messageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection(MESSAGE_FIELD)
          .doc(cureentUserId)
          .collection(widget.reciver!.uid!)
          .orderBy(TIMESSTAMP, descending: true)
          .snapshots(),
      builder: ((context, snapshot) {
        final documents = snapshot.data;
        if (snapshot.data == null) {
          return const Center(
              child: CircularProgressIndicator(
            color: UniversalData.whiteColor,
          ));
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          scrollContoller.animateTo(scrollContoller.position.minScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut);
        });
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          reverse: true,
          controller: scrollContoller,
          itemCount: documents == null ? 0 : documents.docs.length,
          itemBuilder: ((context, index) {
            return chatMessageItem(documents!.docs[index]);
          }),
        );
      }),
    );
  }

  PreferredSizeWidget customAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centertile: false,
        title: Text(widget.reciver!.name!),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone),
          ),
        ],
      ),
    );
  }

  Widget chatMessageItem(QueryDocumentSnapshot snapshot) {
    Message message = Message.formMap(snapshot.data() as Map<String, dynamic>);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        alignment: message.senderId == cureentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: message.senderId == cureentUserId
            ? senderLayout(message)
            : reciverLayout(message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = const Radius.circular(15.0);

    return Container(
      // margin: const EdgeInsets.only(top: 12.0),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalData.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: getMessage(message),
      ),
    );
  }

  Widget getMessage(Message message) {
    return message.type != 'image'
        ? Text(
            message.message!,
            style: const TextStyle(
                color: UniversalData.whiteColor, fontSize: 16.0),
          )
        : CachedImage(message.imageUrl!);
  }

  Widget reciverLayout(Message message) {
    Radius messageRadius = const Radius.circular(15.0);

    return Container(
      // margin: const EdgeInsets.only(top: 12.0),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalData.reciverColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomRight: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: getMessage(message),
      ),
    );
  }

  addMediaModel(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      child: const Icon(
                        Icons.close,
                      ),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contents & Tools',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: UniversalData.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  children: [
                    ModalTile(
                      title: 'Media',
                      subtitle: 'share photos & videos',
                      icon: Icons.image,
                      onTap: () => pickImage(ImageSource.gallery),
                    ),
                    const ModalTile(
                        title: 'Files',
                        subtitle: 'share files',
                        icon: Icons.file_copy_sharp),
                    const ModalTile(
                      title: 'Contact',
                      subtitle: 'share contact',
                      icon: Icons.contact_page_outlined,
                    ),
                    const ModalTile(
                        title: 'Location',
                        subtitle: 'share locations',
                        icon: Icons.location_city),
                    const ModalTile(
                      title: 'Sehedule Call',
                      subtitle: 'arrage a skype call and get remainder',
                      icon: Icons.shutter_speed_outlined,
                    ),
                    const ModalTile(
                      title: 'Create Poll',
                      subtitle: 'share polls',
                      icon: Icons.poll,
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget chatController(BuildContext context) {
    void setWriteTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: UniversalData.floatingButtonGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                addMediaModel(context);
              },
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          Expanded(
            child: TextField(
              onTap: () => setState(() {
                isShowEmojiPicker = false;
              }),
              controller: textController,
              onChanged: (val) {
                (val.isNotEmpty && val.trim() != '')
                    ? setWriteTo(true)
                    : setWriteTo(false);
              },
              decoration: InputDecoration(
                hintText: 'type a message',
                hintStyle: const TextStyle(color: UniversalData.greyColor),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                filled: true,
                fillColor: UniversalData.textFieldColor,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isShowEmojiPicker = !isShowEmojiPicker;
                    });
                  },
                  icon: const Icon(
                    Icons.face,
                    color: UniversalData.whiteColor,
                  ),
                ),
              ),
            ),
          ),
          isWriting
              ? Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: UniversalData.floatingButtonGradient,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                )
              : Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Icon(Icons.record_voice_over),
                    ),
                    GestureDetector(
                        onTap: () {
                          pickImage(ImageSource.camera);
                        },
                        child: const Icon(Icons.camera_alt)),
                  ],
                ),
        ],
      ),
    );
  }
}

class ModalTile extends StatelessWidget {
  const ModalTile({this.title, this.icon, this.subtitle, this.onTap});
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: CustomTile(
        onTap: onTap,
        mini: false,
        leading: Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.only(right: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalData.reciverColor,
          ),
          child: Icon(
            icon,
            color: UniversalData.greyColor,
            size: 38.0,
          ),
        ),
        subtitle: Text(
          subtitle!,
          style: const TextStyle(color: UniversalData.greyColor, fontSize: 14),
        ),
        title: Text(
          title!,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: UniversalData.whiteColor),
        ),
      ),
    );
  }
}
