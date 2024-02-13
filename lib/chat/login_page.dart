import 'package:associate_arena_groupchat_poc/app_manager.dart';
import 'package:associate_arena_groupchat_poc/firestore_service.dart';
import 'package:associate_arena_groupchat_poc/test/home_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                maxLength: 8,
                controller: numberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Number',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addUserFireStore();
                    addDataToSF(context);

                    // Navigate to another screen
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addUserFireStore() async {
    await FirestorService().saveUserData(
        numberController.text, nameController.text, "dummy@gmail.com");
  }

  addDataToSF(context) async {
    await AppManager.saveUserLoggedInStatus(true);
    await AppManager.saveEmployeeNumber(numberController.text);
    await AppManager.saveUserNameSF(nameController.text);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }
}
