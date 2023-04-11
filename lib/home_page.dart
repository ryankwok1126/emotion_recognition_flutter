import 'package:flutter/material.dart';
import 'package:test_jitsi/lesson_page.dart';

int member_id = 0;
int lesson_id = 0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _memberIdController = TextEditingController();
  final _lessonIdController = TextEditingController();

  _login() {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _loginFormKey.currentState!.save();
      });
      member_id = int.parse(_memberIdController.text);
      lesson_id = int.parse(_lessonIdController.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LessonPage(),
        ),
      );
    }
  }

  _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _buildMemberId(),
          const SizedBox(height: 32.0),
          _buildLessonId(),
          const SizedBox(height: 40.0),
          _buildLoginBtn(),
        ],
      ),
    );
  }

  _buildMemberId() {
    return Container(
      height: 80.0,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(80.0)),
        color: Colors.white,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextFormField(
            controller: _memberIdController,
            cursorColor: Colors.green,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              hintText: 'Member Id',
              hintStyle: TextStyle(
                color: Color(0xffa0a0a0),
              ),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == '') {
                return 'Member Id cannot be null or empty.';
              }
            },
          ),
        ),
      ),
    );
  }

  _buildLessonId() {
    return Container(
      height: 80.0,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(80.0)),
        color: Colors.white,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextFormField(
            controller: _lessonIdController,
            cursorColor: Colors.green,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              hintText: 'Lesson Id',
              hintStyle: TextStyle(
                color: Color(0xffa0a0a0),
              ),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == '') {
                return 'Lesson Id cannot be null or empty.';
              }
            },
          ),
        ),
      ),
    );
  }

  _buildLoginBtn() {
    return GestureDetector(
      onTap: () => _login(),
      child: Container(
        height: 80.0,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        child: const Center(
          child: Text(
            'Login',
            style: TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
          child: _buildLoginForm(),
        ),
      ),
    );
  }
}
