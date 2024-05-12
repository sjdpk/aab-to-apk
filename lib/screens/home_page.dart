import 'package:apptools/Service/extract_service.dart';
import 'package:apptools/widget/input_select_field.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  reset() {
    setState(() {
      aabPath = null;
      destPath = null;
    });
  }

  resetAdvanced() {
    setState(() {
      releaseKeyStorePath = null;
    });
  }

  setLoading(bool value) {
    setState(() {
      isExtracting = value;
    });
  }

  // isReleasedModeApk set state
  setIsReleasedModeApk(bool value) {
    setState(() {
      isReleasedModeApk = value;
    });
  }

  toogleKeyStorePassword() {
    setState(() {
      showKeyStorePassword = !showKeyStorePassword;
    });
  }

  toogleStorePassword() {
    setState(() {
      showStorePassword = !showStorePassword;
    });
  }

  String? aabPath;
  String? destPath;
  bool isExtracting = false;
  bool isReleasedModeApk = false;
  String? releaseKeyStorePath;
  bool showKeyStorePassword = false;
  bool showStorePassword = false;
  final TextEditingController storePasswordCtr = TextEditingController();
  final TextEditingController keyPasswordCtr = TextEditingController();
  final TextEditingController keyAliasCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AAB Extractor',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // select aab file field
            BuildSelectEnterField(
              onTap: () async {
                await AABExtractService.selectAABFile().then((value) {
                  setState(() => aabPath = value);
                });
              },
              hintText: aabPath ?? 'Select .aab Path',
              suffixIcon: const Icon(Icons.android),
            ),

            const SizedBox(height: 10),

            // select output directory field
            BuildSelectEnterField(
              onTap: () async {
                await AABExtractService.getOutputDirectory().then((value) {
                  setState(() => destPath = value);
                });
              },
              hintText: destPath ?? 'Select Output Directory',
              suffixIcon: const Icon(Icons.folder_copy_outlined),
            ),

            // custom keystore setup
            const SizedBox(height: 10),
            CheckboxListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              enableFeedback: false,
              splashRadius: 0,
              value: isReleasedModeApk,
              onChanged: (value) {
                setIsReleasedModeApk(value!);
                if (!value) resetAdvanced();
              },
              title: const Text('Advanced Setup'),
            ),

            if (isReleasedModeApk) ...[
              // select keystore file field
              const SizedBox(height: 10),
              BuildSelectEnterField(
                  onTap: () async {
                    await AABExtractService.selectKeyStoreFilePath()
                        .then((value) {
                      setState(() => releaseKeyStorePath = value);
                    });
                  },
                  hintText: releaseKeyStorePath ?? 'Select Keystore Path',
                  suffixIcon: const Icon(Icons.security),
                  validator: (value) {
                    if (value == null) return 'Keystore path is required';
                    return null;
                  }),

              // key alias field
              const SizedBox(height: 10),
              BuildSelectEnterField(
                isEnabled: true,
                controller: keyAliasCtr,
                hintText: 'Enter Key Alias',
                validator: (value) {
                  if (value!.isEmpty) return 'Key Alias is required';
                  return null;
                },
              ),

              // keystore password field
              const SizedBox(height: 10),
              Row(
                children: [
                  // store password field
                  Flexible(
                    child: BuildSelectEnterField(
                      isEnabled: true,
                      controller: storePasswordCtr,
                      hintText: 'Enter store Password',
                      isPassword: showStorePassword,
                      suffixIcon: IconButton(
                        onPressed: () => toogleStorePassword(),
                        icon: Icon(
                          showStorePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Store Password is required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: BuildSelectEnterField(
                      isEnabled: true,
                      controller: keyPasswordCtr,
                      hintText: 'Enter Key Password',
                      isPassword: showKeyStorePassword,
                      suffixIcon: IconButton(
                        onPressed: () => toogleKeyStorePassword(),
                        icon: Icon(
                          showKeyStorePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Key Password is required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // container for the submit button
            GestureDetector(
              onTap: () async {
                if (!_formKey.currentState!.validate()) return;
                setLoading(true);
                if (aabPath != null) {
                  await AABExtractService.extractAAB(
                    aabPath: aabPath!,
                    destPath: destPath,
                    fileName: aabPath?.split("/").last.split(".").first,

                    // For release mode apk
                    keystorePath: releaseKeyStorePath,
                    keyAlias: keyAliasCtr.text,
                    keystorePassword: storePasswordCtr.text,
                    keyPassword: keyPasswordCtr.text,

                    onLoading: (value) => setLoading(value),
                    onSucess: () {
                      reset();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(10),
                          backgroundColor: Colors.blue,
                          content: Text('Apk generated successfully'),
                        ),
                      );
                    },
                    onError: (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          backgroundColor: Colors.red,
                          content: Text('Error: $error'),
                        ),
                      );
                    },
                    onFinally: () {
                      setLoading(false);
                      if (isReleasedModeApk) resetAdvanced();
                    },
                  );
                } else {
                  setLoading(false);
                  // show snackbar user cancel
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(10),
                      backgroundColor: Colors.red,
                      content: Text('Please select aab file'),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isExtracting ? "" : 'Extract AAB',
                            style: const TextStyle(color: Colors.white),
                          ),
                          if (isExtracting)
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: aabPath != null || destPath != null,
                    child: GestureDetector(
                      onTap: () => reset(),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, left: 10),
                        child: const Icon(
                          Icons.refresh_outlined,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
