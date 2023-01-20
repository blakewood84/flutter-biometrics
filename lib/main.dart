import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'dart:developer' as devtools;

import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _checkCanAuthenticate() async {
    final auth = LocalAuthentication();
    final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

    devtools.log('Can Authenticate: $canAuthenticate');
  }

  void _listAvailableBiometrics() async {
    final auth = LocalAuthentication();
    devtools.log('Checking Available Biometrics');
    final availableBiometrics = await auth.getAvailableBiometrics();
    devtools.log('Available Biometrics: $availableBiometrics');

    for (final biometric in availableBiometrics) {
      devtools.log('Biometric: $biometric');
    }
  }

  void _authenticate() async {
    try {
      final auth = LocalAuthentication();
      final didAuthenticate = await auth.authenticate(localizedReason: 'Please Authenticate');
      devtools.log('Did Authenticate: $didAuthenticate');
    } on PlatformException catch (error) {
      devtools.log('Error: $error');
    }
  }

  void _authenticateWithBiometrics() async {
    try {
      final auth = LocalAuthentication();
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please Authenticate',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      devtools.log('Did Authenticate: $didAuthenticate');
    } on PlatformException catch (error) {
      devtools.log('Error: $error');
    }
  }

  void _isNFCAvailable() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    devtools.log('Is NFC Available: $isAvailable');
  }

  void _startNFCScanSession() async {
    devtools.log('Starting Scan....');
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        devtools.log('Tag Detected');
        Ndef? ndef = Ndef.from(tag);

        if (ndef == null) {
          print('Tag is not compatible with NDEF');
          return;
        }
        // Do something with an NfcTag instance.
        devtools.log('Scanning... Tag: ${tag.data}');
        _stopNFCScanning();
      },
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      alertMessage: 'Session Started',
    );
  }

  void _stopNFCScanning() async {
    devtools.log('Stopping Scan...');
    NfcManager.instance.stopSession();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Testing Biometrics'),
          centerTitle: true,
        ),
        body: Scaffold(
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _checkCanAuthenticate();
                  },
                  child: const Text('Can Authenticate with Biometrics'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _listAvailableBiometrics();
                  },
                  child: const Text('Check Available Biometrics'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _authenticateWithBiometrics();
                  },
                  child: const Text('Authenticate'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _isNFCAvailable();
                  },
                  child: const Text('Is NFC Available'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _startNFCScanSession();
                  },
                  child: const Text('Start Scanning'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _stopNFCScanning();
                  },
                  child: const Text('Stop Scanning'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
